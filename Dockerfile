# ÉTAPE 1 : Builder sur Alpine
FROM python:3.12-alpine AS builder
WORKDIR /build

RUN apk add --no-cache gcc musl-dev postgresql-dev

RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt \
    && pip uninstall -y setuptools pip wheel

# ÉTAPE 2 : Runtime ultra-léger sur Alpine
FROM python:3.12-alpine

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

RUN apk add --no-cache libpq \
    && addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /opt/venv /opt/venv
COPY --chown=appuser:appgroup . /app

USER appuser

EXPOSE 4000

CMD ["python", "main.py"]
