FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt

COPY . /app

EXPOSE 8888

CMD jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root --no-browser