# Avaliação DEA - pacote Benchmarking
install.packages("Benchmarking")
library(Benchmarking)

#Usaremos a função "dea" desse pacote e seus padrões (default)
#dea(X, Y, RTS="vrs", ORIENTATION="in", XREF=NULL, YREF=NULL,
##    FRONT.IDX=NULL, SLACK=FALSE, DUAL=FALSE, DIRECT=NULL, param=NULL,
##    TRANSPOSE=FALSE, FAST=FALSE, LP=FALSE, CONTROL=NULL, LPK=NULL)

#X Matriz de insumos das firmas que serão analisadas, 
## matriz de ordem K x m, sendo m insumos e k firmas

# Y - matriz dos produtos incluídos na análise. 
## ordem k x n, sendo n produtos e k firmas.

# RTS :texto ou número definindo o modelo DEA a ser estimado/retornos à escala
## 0 fdh : Free disposability hull, não é assumido convexidade;
## 1 vrs : Retornos variáveis à escala, convexidade e free disposability
## 2 drs : Retornos descrescentes à escala, convexidade, down-scaling e
## "free disposability" (disponibilidade fraca);
## 3 crs : Retornos constantes à escala, convexidade e free disposability
## 4 irs : Retornos crescentes à escala, 
## (up-scaling, mas não down-scaling), convexidade e free disposability
## 5 irs2: Retornos crescentes à escala
## (up-scaling, mas não down-scaling), additividade e  free disposability
# 6 add : Aditividade (scaling up e down, mas apenas com inteiros), 
## e free disposability; também conhedico uma replicabilidade e free disposability, 
## a free disposability e replicability hull (frh) – não é assumido convexidade
# 7 fdh+: Combinação de "free disposability" e restrito ou retornos constantes à
## escala local
#10 vrs+ :Retornos variáveis à escala, mas não há restrição sobre os 
## lambdas individuais via param

# ORIENTATION: insumo  "in" (1), produto "out" (2), e gráfico da eficiência "graph"

#XREF: Insumos das firmas determinando a tecnologia, default (padrão): X

#YREF: Produtos das firmas determinando a tecnologia,default: Y

#FRONT.IDX: Indices das firmas determinando a tecnologia

#SLACK: Calcula a as folgas dos insumos/produtos na etapa 2 via função slack.

configs()       # executa função configurações 
#Importando
library(readxl)
gast_educ <- read_xlsx ("Gastos_educ_x_ideb.xlsx")

#Montando a matriz de insumos. Perceba que você deve combinar todos os insumos via
## função cbind. "x1" e "x2" são os nomes dos insumos. Você pode mudar os nomes
## de acordo com a sua base de dados e incluir quandos desejar, acrescentando
## ", variável"
x <- as.matrix(with(gast_educ, Gasto_med_educ_por_aluno))


#Nesse caso temos apenas um produto. Se tiver mais de um, utilizar o mesmo 
## procedimento utilizado dos insumos
y <- as.matrix( with(gast_educ, cbind(IDEB_2023_F1, IDEB_2023_F2)))



#Estimiando a eficiência.
## Retornos constantes à escala e orientação insumo
eci <- dea(x,y, RTS="crs", ORIENTATION = "in")
## Retornos constantes à escala e orientação produto
eco <- dea(x,y, RTS="crs", ORIENTATION = "out")
## Retornos variáveis à escala e orientação insumo
evi <- dea(x,y, RTS="vrs", ORIENTATION = "in")
## Retornos variáveis à escala e orientação produto
evo <- dea(x,y, RTS="vrs", ORIENTATION = "out")

#Combinando os resultados em um banco de dados
#Observe que em "crs_i = eci$eff", estamos criando uma variável de nome crs_i 
## (você pode utilizar outros nomes), selecionando os escores de eficiência (eff)
## dentro do objeto "eci"
res <- data.frame(crs_i = eci$eff, crs_o = eco$eff, vrs_i = evi$eff, vrs_o = evo$eff,
                  crs_1o = 1/eco$eff, vrs_1o = 1/evo$eff)

writexl::write_xlsx(res, "res_dea.xlsx")

#Veja o que tratamos teoricamente no vídeo teórico, 
## Os escores de eficiência sobre a pressuposição de retornos constantes com orientação
### insumo e produto são iguais, o que não ocorre sobre a pressuposição de retornos
### variáveis;
## Os escores de eficiência com a pressuposição de retornos variáveis são maiores
### do que os calculados sobre a orientação de retornos variáveis.


#Podemos traçar a isoquanta para essa função com dois insumos 
dea.plot.isoquant(tone$x1, tone$x2, RTS="vrs", txt=T)
#Podemos obter a fronteira de possibilidades de produção
## sobre a pressuposição de retornos consntantes, 
dea.plot.frontier(x, y, RTS="crs", txt=T)
## sobre a pressuposição de retornos variáveis, 
dea.plot.frontier(x, y, RTS="vrs", txt=T)




#####################################################
##########             VÍDEO 3           ############
##########                               ############
#####################################################


#Importando
library(readxl)
tone <- read_excel("Gastos_educ_x_ideb.xlsx")


####    Pacote Eficiência nonparaeff
install.packages("nonparaeff")
library(nonparaeff)
rt <- sbm.tone(tone) # , noutput = 1)


writexl::write_xlsx(rt, "rt.xlsx")

