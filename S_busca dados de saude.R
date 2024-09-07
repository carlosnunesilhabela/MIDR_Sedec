########### Script para baixar dados de Saúde ########################

configs()
load_packages()

devtools::install_github('https://github.com/joaohmorais/rtabnetsp', force=TRUE)

# https://github.com/abraji/APIs/blob/master/rsiconfi/gastos_estaduais_SP_com_saude_2018.R


library(rtabnetsp)  # Manual: http://scielo.iec.gov.br/scielo.php?script=sci_arttext&pid=S1679-49742021000100085

indicator_list(url= 'http://portal.saude.sp.gov.br/links/matriz')   # retrieve a list of available indicators
indicator_search('dengue', url = 'http://portal.saude.sp.gov.br/links/matriz') # search for indicators containing "dengue" in its name

ds <- fetch_all(region = 'Município', url = 'http://portal.saude.sp.gov.br/links/matriz', timeout = 1)

ds <- filter(ds, Município == 'Ilhabela'            |
                 Município == 'Bertioga'            |
                 Município == 'Caraguatatuba'       | 
                 Município == 'São Sebastião'       |
                 Município == 'São José dos Campos' |
                 Município == 'Ubatuba' )

ds <- filter(ds, Ano == '2023')

leitos = "Leitos.SUS.por.1.000(mil).habitantes.na.populacao.SUS.dependente_Leitos.SUS"
uti = "Percentual.de.Leitos.SUS.de.UTI.(Adulto,.Infantil.e.Neonatal)_Perc.Leitos.UTI.(%)"

ds1 <-  filter(ds, Indicador == leitos)
ds2 <-  filter(ds, Indicador == uti)

ds3_df <- shp_municipiossc_df %>% 
  sparklyr::left_join(dados_sc, by = "CD_GEOCMU")
writexl::write_xlsx(ds2, "Dados_saude_leitos.xlsx") #grava data frame em formato *.xlsx

# save(ds, file = "Dados_saude_sp.Rdata") # Salva em formato RData
