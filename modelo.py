import pandas as pd
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import joblib

# Geração de um conjunto de dados fictício para previsão de investimento
X_investimento, y_investimento = make_classification(n_samples=1000, n_features=4, random_state=42)

# Dividindo os dados em conjuntos de treino e teste
X_treino_investimento, X_teste_investimento, y_treino_investimento, y_teste_investimento = train_test_split(X_investimento, y_investimento, test_size=0.2, random_state=42)

# Criando e treinando o modelo para aprovação de empréstimos
modelo_investimento = LogisticRegression()
modelo_investimento.fit(X_treino_investimento, y_treino_investimento)

# Avaliando o modelo de aprovação de empréstimos
predictions_investimento = modelo_investimento.predict(X_teste_investimento)
accuracy_investimento = accuracy_score(y_teste_investimento, predictions_investimento)
print(f"Acurácia do Modelo de Previão de Investimento: {accuracy_investimento:.2f}")

# Salvando o modelo de previsão de investimento
joblib.dump(modelo_investimento, 'modelo_previsao_investimento_treinado.pkl')


