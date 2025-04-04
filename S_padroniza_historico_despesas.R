# SCRIPT: Standardização do histórico das despesas (retirada de caracteres especiais, numeros e uppercase)

load_packages()    # executa FUNÇÃO: carregar pacotes

configs()       # função setar configurações

dsname <- "despesas-sao-jose-dos-campos-2023-2024.xlsx" # Substituir DSN do arquivo de despesas a ser trabalhado 
 
std_histdesp(dsname)
dsname

