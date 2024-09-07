# Atlas_Danos

# Carrega Pacotes
{ 
  configs()
  
  load_packages()
  
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
  library(magrittr)
}

url <- "C:/Users/carlo/Desktop/144968 - Projeto BRA12017 - Sistema de Análise - Perfil Municipal-Defesa Civil/Bases de Dados/Atlas Digital de Desastres/BD_Atlas_1991_2023_v1.0_2024.04.29.xlsx"
mapa_danos <- read_xlsx(url)

mapa_danos_2012_2023 <- dplyr::filter(mapa_danos, year(Data_Registro) >= "2012")


# Sumarização por municpipio

danos_sum <- mapa_danos_2012_2023 %>% group_by(Cod_IBGE_Mun) %>% 
    summarise(Danos_Humanos_total = sum(DH_total_danos_humanos),
              Num_total_mortes = sum (DH_MORTOS),
              Danos_Materiais_total = sum(DM_total_danos_materiais),
              Perdas_setor_publico = sum (PEPL_total_publico),
              Perdas_setor_privado = sum (PEPR_total_privado),
              Total_perdas = sum(PE_PLePR),
              Num_ocorrencias = n(),
              num_anos_rep = n_distinct(year(Data_Registro)))

    
    cod_ <- mapa_danos %>% group_by(Cod_IBGE_Mun,Cod_Cobrade) %>% 
      summarise(ncod_cobrad =  n_distinct())
    
    cod_ <- arrange(cod_, Cod_IBGE_Mun, desc(ncod_cobrad))
    
    cod2 <-cod_[!duplicated(cod_[c("Cod_IBGE_Mun")]),]
    
    cod2 <- rename(cod2, Cod_Cobrade_mais = Cod_Cobrade)
     
    danos_sum_joined <- sparklyr::left_join(danos_sum, cod2, by = "Cod_IBGE_Mun")
  
    writexl::write_xlsx(danos_sum_joined, "Atlas_Danos_sumarizados_2012_2023.xlsx") #grava data frame em formato *.xlsx
  