import joblib
import nlp


def predict(text):
    pipeline = joblib.load('./dataset/pipeline_small.pkl')
    text = perform_preprocessing(text)
    predicted = pipeline.predict([text])

    # predicted variable contains either [0.0] or [1.0] based on prediction.
    # return 'human' for 0 and 'ai' for 1.
    return 'human' if predicted[0] == 0 else 'ai'


def perform_preprocessing(text):
    text = nlp.remove_tags(text)
    text = nlp.remove_stopwords(text)
    text = nlp.remove_punc(text)
    text = text.lower()
    return text
