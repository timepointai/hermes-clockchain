FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

ARG UPSTREAM_REPO=https://github.com/timepointai/timepoint-clockchain.git
ARG UPSTREAM_REF=main
RUN git clone --depth 1 --branch ${UPSTREAM_REF} ${UPSTREAM_REPO} /upstream \
    && cp -r /upstream/* /upstream/.* /app/ 2>/dev/null || true \
    && rm -rf /upstream

# Install dependencies
RUN pip install --no-cache-dir -e .

# Copy hermes-specific overlay
COPY overlay/ /app/overlay/
COPY hermes-config.yaml /app/hermes-config.yaml

# Hermes defaults: free distillable, text-only, expansion enabled
ENV FREE_DISTILLABLE_MODE=true
ENV EXPANSION_ENABLED=true
ENV EXPANSION_DAILY_BUDGET=0
ENV EXPANSION_INTERVAL=600
ENV PORT=8000

EXPOSE 8000

CMD ["uvicorn", "app.main:application", "--host", "0.0.0.0", "--port", "8000"]
