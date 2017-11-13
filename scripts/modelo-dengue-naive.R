# Load librarys
library(class)
library(tidyverse)


# Set random
set.seed(1)

# Load datasets
dengue.2016 <- read.csv("/Users/joffily/Desktop/TCC/datasets/dengue-2016.csv")
dengue.2016.filter <- subset(dengue.2016, NAUSEA != "NA")
dengue.2016.filter <- subset(dengue.2016, !is.na(FEBRE))
dengue.2016.filter$VOMITO <- ifelse(dengue.2016.filter$VOMITO == 1, TRUE, FALSE)


# GET Labels
#labels(dengue.2016.filter, with = NULL, abbreviate = FALSE)[[2]][42:59]

# Select interesting labels
#dengue.2016.filtered <- select(dengue.2016.filter, DT_NOTIFIC, SEM_NOT, ID_MUNICIP,
#                               DT_NASC, FEBRE, MIALGIA, CEFALEIA, EXANTEMA,
#                               VOMITO, NAUSEA, DOR_COSTAS, CONJUNTVIT, ARTRITE,
#                               ARTRALGIA, PETEQUIA_N, LEUCOPENIA, LACO, DOR_RETRO,
#                               DIABETES, HEMATOLOG, HEPATOPAT, RENAL, DT_OBITO)

dengue.2016.filtered <- select(dengue.2016.filter, FEBRE, MIALGIA, CEFALEIA, EXANTEMA,
                               VOMITO, NAUSEA, DOR_COSTAS, CONJUNTVIT, ARTRITE,
                               ARTRALGIA, PETEQUIA_N, LEUCOPENIA, LACO, DOR_RETRO,
                               DIABETES, HEMATOLOG, HEPATOPAT, RENAL, DT_OBITO)

# Transform our data in logical values of interest
for (coluna in c("FEBRE", "MIALGIA", "CEFALEIA", "EXANTEMA", "VOMITO", "NAUSEA", "DOR_COSTAS", "CONJUNTVIT", "ARTRITE", "ARTRALGIA", "PETEQUIA_N", "LEUCOPENIA", "LACO", "DOR_RETRO", "DIABETES", "HEMATOLOG", "HEPATOPAT", "RENAL")) {
    dengue.2016.filtered[, coluna] <- ifelse(dengue.2016.filtered[, coluna] == 1, TRUE, FALSE)
}

dengue.2016.filtered[, "DT_OBITO"] <- ifelse(!is.na(dengue.2016.filtered[, "DT_OBITO"]), TRUE, FALSE)

# Check if filters worked well
# nrow(dengue.2016.filtered[dengue.2016.filtered$DT_OBITO == TRUE, ]) == 55
# nrow(dengue.2016.filtered[dengue.2016.filtered$VOMITO == TRUE, ]) == 3418

# write.csv(dengue.2016.filtered, "./datasets/dengue-2016-filtered.csv")


attr_group_to_case <- function(LACO, VOMITO, DT_OBITO, ARTRALGIA, CEFALEIA, DOR_RETRO) {
  # Sinais gerais (na ausência de mais sintomas podemos dizer que este é um grupo A)
  # ARTRALGIA (Dores articulares) && CEFALEIA (Dores de cabeça) && DOR_RETRO (Dores ao redor dos olhos)

  # A ideia por trás é caracterizar nosso dataset com a classificação de risco provida pelo ministério da saúde
  # Os sintomas chaves permitirão a classificação dos paciêntes para o treinamento do algorítimo,
  # sendo assim será possível identificar casos (probabilidade com nível de confiança) de outros paciêntes sem a utilização
  # de todo o conjunto de dados

  if (DT_OBITO) {
    group <- "D"
  } else if (VOMITO) {
    group <- "C"
  } else if (LACO && !VOMITO) {
    group <- "B"
  } else if (!LACO && !VOMITO && !DT_OBITO) { # Não tem sintomas de alarme / choque
    group <- "A"
  } else if (ARTRALGIA && CEFALEIA && FEBRE ||(ARTRALGIA && CEFALEIA) ||
             (CEFALEIA && FEBRE) || (ARTRALGIA && FEBRE)) { # Tem sintomas comuns porém com pelo menos duas combinações
    group <- "A"
  } else { # Se tiver o laço e nenhum dos sintomas acima então é caracterizado como B
    group <- "B"
  }

    return (group)
}


# Apply our function to dataset
# We must try improve this function
dengue.2016.filtered$GRUPO <- apply(dengue.2016.filtered[, c("LACO", "VOMITO", "DT_OBITO", "ARTRALGIA", "CEFALEIA", "DOR_RETRO")], 1, function(x) attr_group_to_case(x[1], x[2], x[3], x[4], x[5], x[6]))


# Checa quantos caso do grupo D existiram
nrow(dengue.2016.filtered[dengue.2016.filtered$GRUPO == "D",]) == 55



# Split our dataset in two groups training and testing
index_to_train <- sample(1:nrow(dengue.2016.filtered), 1000)
index_to_test <- sample(1:nrow(dengue.2016.filtered), 1000)

# Testing our knn algorithm
predictions <- knn(dengue.2016.filtered[index_to_train, 1:19], # Columns to train
                   dengue.2016.filtered[index_to_test, 1:19], # Columsn to test that training
                   dengue.2016.filtered[index_to_train, 20], k=10) # Columns to validade our training

# Função para medir a eficácia
accuracy <- function(predictions, answers){
  sum((predictions==answers)/(length(answers)))
}

# Show our accuracy :D
accuracy(predictions, dengue.2016.filtered[index_to_test, 20])

# output: [1] 0.958


count_how_many_itens_is_equals <- function(predicted, realitems) {
  count = 0
  for (index in 1:length(predicted)) {
    if (predicted[index] == realitems[index]) {
      count = count + 1
    }
  }

  return (count)
}

count_how_many_itens_is_equals(predictions, dengue.2016.filtered[index_to_test, 20])

# Tentando predizer com o naive bayes
# A bibliotéca naive bayes utiliza a (...) para fazer computações probabilisticas em variáveis do tipo "categorical"
# Desta forma podemos montar um modelo probabilistico e aplicar em um dashboard por exemplo
library(naivebayes)
index_to_train <- sample(1:nrow(dengue.2016.filtered), 1000)
index_to_test <- sample(1:nrow(dengue.2016.filtered), 1000)
data_to_train <- dengue.2016.filtered[index_to_train,]
data_to_test <- dengue.2016.filtered[index_to_test,]

model <- naive_bayes(GRUPO ~ ., data = data_to_train)

xpredicted <- predict(model, data_to_test[, 1:19], type="class")
xpredicted == data_to_test[, 20]
count_how_many_itens_is_equals(xpredicted, data_to_test[, 20]) * 100 / 1000


predict(model, data.frame(ARTRALGIA=TRUE, FEBRE=FALSE, MIALGIA=TRUE, DT_OBITO=FALSE, VOMITO=FALSE, LACO=FALSE, DOR_RETRO=TRUE, LEUCOPENIA=TRUE), type="class")

saveRDS(model, "/Users/joffily/Desktop/TCC/models/xdengue.RData")
modelo <- readRDS(file="/Users/joffily/Desktop/TCC/models/xdengue.RData")

# Test if our model act how we spect
# predict(modelo, data.frame(ARTRALGIA=TRUE, FEBRE=FALSE, MIALGIA=TRUE, DT_OBITO=FALSE, VOMITO=FALSE, LACO=FALSE, DOR_RETRO=TRUE, LEUCOPENIA=TRUE), type="class")


