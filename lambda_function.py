import json
import pandas as pd
import nltk
from nltk.corpus import words
from nltk.corpus import stopwords
import string
import boto3
import regex
import numpy

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

def lambda_handler(event, context):
    print(event)
    file_key = event['Records'][0]['s3']['object']['key']
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    s3_client = boto3.client('s3')
    
    response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
    csv_content = response['Body'].read().decode('utf-8')

    # Create a pandas DataFrame from the CSV content
    df = pd.read_csv(pd.compat.StringIO(csv_content))

    # Remove tags, punctuation, and stopwords
    df['text'] = df['text'].apply(remove_tags)
    df['text'] = df['text'].apply(remove_punc)
    nltk.download('words')
    global english_words
    english_words = set(words.words())
    nltk.download('stopwords')
    df['text'] = df['text'].apply(remove_stopwords)

    # Save transformed data to a new CSV file
    df.to_csv('processed_ai_human_text.csv', index=False)

    # Upload the new CSV file to S3
    bucket_name = 'destinationbucketai'
    s3_client.upload_file('processed_ai_human_text.csv', bucket_name, 'processed_ai_human_text.csv')


    return 'Data transformation completed successfully!'
