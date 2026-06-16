FROM python:3.11-slim

WORKDIR /app

# نصب پیش‌نیازها و کامپایلر موقت برای psutil در صورت نیاز
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && pip install --no-cache-dir \
        "fastapi==0.111.0" \
        "uvicorn[standard]==0.30.1" \
        "psutil==5.9.8" \
    && apt-get purge -y --auto-remove build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY main.py .

EXPOSE 8000

# Wasmer و Render متغیر PORT را تزریق می‌کنند، این دستور به خوبی آن را هندل می‌کند
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000}"]