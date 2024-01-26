# Imports
from flask import Flask, request, render_template
import joblib

# App
app = Flask(__name__)

# Carregar o modelo treinado para previsão de investimento
modelo_investimento_final = joblib.load('modelo_previsao_investimento_treinado.pkl')

# Rota da página de entrada
@app.route('/')
def home():
    return render_template('index.html')

@app.route('/predict', methods=['POST'])
def predict():

    # Recebe os novos dados de entrada
    features = [float(x) for x in request.form.values()]

    # Prepara a lista dos atributos
    final_features = [features]

    # Previsão com o modelo treinado 
    prediction = modelo_investimento_final.predict(final_features)
    
    return render_template('index.html', prediction_text='Fará um novo investimento' if prediction[0] == 1 else 'Não fará um novo investimento')

# Executa o programa 
if __name__ == "__main__":
    app.run(debug=True)



