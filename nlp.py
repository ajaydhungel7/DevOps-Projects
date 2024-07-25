import pandas as pd
import numpy as np
import seaborn as sns

# for punctuations
import string

# for spell checks
import nltk
from nltk.corpus import words
# for stop words
from nltk.corpus import stopwords

# for splitting dataset into training and testing set
from sklearn.model_selection import train_test_split

# for NLP Pipeline
from sklearn.pipeline import Pipeline
from sklearn.feature_extraction.text import CountVectorizer, TfidfTransformer
from sklearn.naive_bayes import MultinomialNB
from sklearn.svm import SVC

# for displaying report of the predictions made by the pipeline
from sklearn.metrics import classification_report


def remove_tags(text):
    tags = ['\n', '\'']
    for tag in tags:
        text = text.replace(tag, '')

    return text


def remove_punc(text):
    new_text = [x for x in text if x not in string.punctuation]
    new_text = ''.join(new_text)
    return new_text


english_words = set()


def is_spelled_correctly(word):
    return word in english_words


def remove_stopwords(text):
    stop_words = set(stopwords.words('english'))
    tmp_words = nltk.word_tokenize(text)
    filtered_words = [word for word in tmp_words if word.lower() not in stop_words]
    filtered_words = ' '.join(filtered_words)
    return filtered_words


def perform_nlp_old():
    # reding data
    df = pd.read_csv('./dataset/ai_human_text.csv')

    # Remove tags \n and \'
    df['text'] = df['text'].apply(remove_tags)

    # Remove punctuation
    df['text'] = df['text'].apply(remove_punc)

    # Performing spell check
    nltk.download('words')
    global english_words
    english_words = set(words.words())
    nltk.download('stopwords')

    # Remove stopwords
    df['text'] = df['text'].apply(remove_stopwords)

    # x is the actual text, y is the label (0 or 1)
    # 0 -> Human written text
    # 1 -> AI generated text
    y_label = df['generated']
    x_data = df['text']

    # Splitting data into train and test set.
    # 30% of the data is separated for testing.
    x_train, x_test, y_train, y_test = train_test_split(x_data, y_label, test_size=0.3, random_state=42)

    # The NLP Pipeline
    pipeline = Pipeline([
        ('count_vectorizer', CountVectorizer()),  # Step 1: CountVectorizer
        ('tfidf_transformer', TfidfTransformer()),  # Step 2: TF-IDF Transformer
        ('naive_bayes', MultinomialNB())])

    # Inserting training data into the pipeline
    pipeline.fit(x_train, y_train)

    # Predicting for a test data
    y_pred = pipeline.predict(x_test)

    # Printing the prediction results
    print(classification_report(y_test, y_pred))
    return 'hello'

