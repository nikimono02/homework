FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY sum.py .
COPY pytest.ini .
COPY test ./test

CMD ["pytest", "-q", "test"]
