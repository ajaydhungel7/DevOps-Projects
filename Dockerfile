FROM python:3.12
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt
RUN mkdir /work
COPY . /work
WORKDIR /work
RUN ls


ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=8000
ENV FLASK_DEBUG=0

# Expose the Flask port
EXPOSE 8000

# Command to run the Flask application
CMD ["flask", "run"]
