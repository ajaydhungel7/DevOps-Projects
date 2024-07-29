from flask import Flask, render_template, request
import predict

app = Flask(__name__, static_url_path='',
            static_folder='web/static',
            template_folder='web/templates')


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/predict-text", methods=['POST'])
def predict_text():
    if request.method == 'POST':
        user_input = request.values.get("user_input")
        return predict.predict(user_input)


