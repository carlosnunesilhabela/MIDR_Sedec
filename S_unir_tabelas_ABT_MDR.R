########################################

configs()

# Carrega Pacotes
{ load_packages()

library(tidyverse)  #pacote para manipulacao de dados
library(cluster)    #algoritmo de cluster
library(dendextend) #compara dendogramas
library(factoextra) #algoritmo de cluster e visualizacao
library(fpc)        #algoritmo de cluster e visualizacao
library(gridExtra)  #para a funcao grid arrange
library(readxl)
library(ggplot2)
library(stringr)
library(dplyr)
library(sparklyr)
library(writexl)
library(readxl)
}
          
# DTB x Municipios de Interesse Turistico SP
{
  DTB <- read_xlsx("Tabelas/DTB_Divisao_Territorial_Brasileira_2022.xlsx")
  MunTur <- read_xlsx("Tabelas/Municípios de Interesses Turisticos - SP.xlsx")
  DTB <- rename(DTB, CD_MUN = `Código Município Completo` )
  DTB <- as_tibble(DTB) # transformando em tibble (não é necessário)
  MunTur <- as_tibble(MunTur) # transformando em tibble (não é necessário)
  MunTur2 <- dplyr::rigth_join(MunTur, DTB, by = "municipio")
  writexl::write_xlsx(MunTur2, "Municípios de Interesses Turisticos - SP.xlsx") #grava data frame em formato *.xlsx
}

#Junta ICM com base de indicadores do IDSC-br
{
IDSC <- read_xlsx("IDSCbr_Base_de_Dados_MDR_PNUD.xlsx")
ICM <- read_xlsx("ICM_ListaABCD_junho2024.xlsx") 

# Full Join: cria um novo dataset contendo todas as informações de X e Y
# Ou seja, pode estar em X e não estar em Y e vice-versa

ABT <- sparklyr::full_join(ICM, IDSC, by = "cod_mun_ibge")
}

#Junta IPS - TemS2ID e MCR
{
IPS <- read_xlsx("IPS_Brasil_RMVALE.xlsx") 
ABT2 <- sparklyr::full_join(ABT, IPS, by = "cod_mun_ibge")

TEMS2ID <- read_xlsx("lista_S2iD.xlsx") 
ABT2<- read_xlsx("ABT_MDR_PNUD.xlsx")

ABT3 <- sparklyr::full_join(ABT2, TEMS2ID, by = "cod_mun_ibge")


MCR <- read.csv(file = "lista_mcr2030_junho.csv", sep = ";", header = T, encoding = "latin1")
ABT3<- read_xlsx("ABT_MDR_PNUD.xlsx")

ABT4 <- sparklyr::full_join(ABT3, MCR, by = "cod_mun_ibge")
}

# Coloca o codigo SIAFI
{
SIAFI <- read_xlsx("receita_siaf_2022.xlsx")
ABT4 <- read_xlsx("ABT_MDR_PNUD.xlsx")

ABT5 <- sparklyr::full_join(ABT4, SIAFI, by = "cod_mun_ibge")

MunTur$municipio <- tolower(MunTur$Município)       # coloca tudo em lowercase - para Uppercase seria toupper(str_origem) 
MunTur$municipio <- rm_accent(MunTur$municipio)     # Remove todas acentuações 
MunTur$municipio <- str_replace_all(MunTur$municipio, "[^[:alnum:]]", "") # remove non alphanumeric characters

ABT5 <- read_xlsx("ABT_MDR_PNUD.xlsx")
SIAFI <- read_xlsx("Tabelas/Codigo_IBGE_SIAFI_Municipios.xlsx")

ABT5$CD_MUN <- as.character(ABT5$CD_MUN)

ABT <- read_xlsx("ABT_MDR_PNUD.xlsx")

ABT7 <- sparklyr::full_join(ABT5, SIAFI, by = "CD_MUN")
}

#SNIS - join dados de saneamento
{
ABT <- read_xlsx("ABT_MDR_PNUD.xlsx")
SNIS_2022 <- read_xlsx("SNIS_todosmunicipios_so_esgoto.xlsx")

SNIS_2022$CD_MUN <- as.character(SNIS_2022$CD_MUN)

ABT8 <- sparklyr::full_join(ABT, SNIS_2022, by = "CD_MUN")
}

# join IVS (IPEA) 2010
{
ABT <- read_xlsx("ABT_MDR_PNUD.xlsx")
IVS_2010 <- read_xlsx("IVS_dados2010.xlsx")

IVS_2010$CD_MUN <- as.character(IVS_2010$CD_MUN)

ABT9 <- sparklyr::full_join(ABT, IVS_2010, by = "CD_MUN")
}

# join Municipios prioritarios
{
  ABT <- read_xlsx("ABT_MDR_PNUD.xlsx")
  Mun_prio <- read_xlsx("lista_municipios_prioritarios_1972.xlsx")
  
  Mun_prio$CD_MUN <- as.character(Mun_prio$CD_MUN)
  
  ABT10 <- sparklyr::full_join(ABT, Mun_prio, by = "CD_MUN")
  
  writexl::write_xlsx(ABT, "ABT_MDR_PNUD10.xlsx") #grava data frame em formato *.xlsx
}

# Leitos e Numero de estabelecimentos saude
{
leitos <- read_xlsx("Qtde_leitos.xlsx")
  leitos$COD_MUN <- as.character(leitos$COD_MUN)
estabsaude <- read_xlsx("Cad_Nacional_Estabelecimentos_Saude.xlsx")
  estabsaude$COD_MUN <- as.character(estabsaude$COD_MUN)
  
ABT <- read_xlsx("ABT_MDR_caracterizacao_municipios.xlsx")

ABT14 <- sparklyr::full_join(ABT, leitos, by = "COD_MUN")
ABT14 <- sparklyr::full_join(ABT14, estabsaude, by = "COD_MUN")
}

# Join ABT com dados sumarizados do Atlas de Desastres
{
url <- "C:/Users/carlo/Desktop/144968 - Projeto BRA12017 - Sistema de Análise - Perfil Municipal-Defesa Civil/Bases de Dados/ABT_Componentes/ABT_MDR_caracterizacao_municipios.xlsx"

ABT <- read_xlsx(url)

#padrononiza nome da coluna para join
danos_sum_joined <- rename(danos_sum_joined, COD_MUN = Cod_IBGE_Mun)
danos_sum_joined$COD_MUN <- as.numeric(danos_sum_joined$COD_MUN)

ABT15 <- sparklyr::full_join(ABT, danos_sum_joined, by = "COD_MUN")
}

#Insere código SIAFI 
{
ABT5 <- read_xlsx("ABT_MDR_PNUD.xlsx")
SIAFI <- read_xlsx("Tabelas/Codigo_IBGE_SIAFI_Municipios.xlsx")

ABT5$CD_MUN <- as.character(ABT5$CD_MUN)

ABT <- read_xlsx("ABT_MDR_PNUD.xlsx")
}

# Join IDHM e GINI
{
ABT16 <- read_xlsx("Info_Mun.xlsx", sheet = "ABT")    
IDHM <- read_xlsx("IDHM_Municipios_2010.xlsx", sheet = "IDHM")
GINI  <- read_xlsx("ginibr.xlsx", sheet = "ginibr")   

IDHM$municipio_std <- tolower(IDHM$Municipio)       # coloca tudo em lowercase - para Uppercase seria toupper(str_origem) 
IDHM$municipio_std <- rm_accent(IDHM$municipio_std)     # Remove todas acentuações 
IDHM$municipio_std <- str_replace_all(IDHM$municipio_std, "[^[:alnum:]]", "") # remove non alphanumeric characters

ABT17 <- sparklyr::full_join(ABT16, IDHM, by = "municipio_std") 

ABT17 <- sparklyr::full_join(ABT17, GINI, by = "COD_MUN6")

ABT17 <- read_xlsx("ABT_17.xlsx") 
ABT   <- read_xlsx("ABT_MDR_caracterizacao_municipios.xlsx")

ABT18 <- sparklyr::full_join(ABT, ABT17, by = "COD_MUN")
}

writexl::write_xlsx(ABT18, "ABT_MDR_caracterizacao_municipios.xlsx") #grava data frame em formato *.xlsx

# save(ABT, file = "ABT_MDR_PNUD.RData") # grava data frame em formato RData
# load("ABT_MDR_PNUD.RData")
# remove(ABT15)

