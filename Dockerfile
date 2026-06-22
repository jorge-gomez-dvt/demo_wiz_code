# Intentionally vulnerable Dockerfile for demo purposes
FROM ubuntu:18.04

# Running as root - no USER directive
WORKDIR /app

# Hardcoded secrets in ENV
ENV DB_PASSWORD=SuperSecret123!
ENV AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
ENV AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
ENV JWT_SECRET=mysupersecretjwtkey
ENV STRIPE_SECRET_KEY=sk_live_DEMO_FAKE_KEY_FOR_WIZ_SCAN
ENV GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyz12

# Install old vulnerable packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 \
    python3-pip \
    openssl=1.1.0g-2ubuntu4 \
    libssl1.0.0 \
    && rm -rf /var/lib/apt/lists/*

# Copy everything including sensitive files
COPY . .
COPY .env /app/.env
COPY config/secrets.yaml /app/config/

# Install dependencies without verification
RUN pip install -r requirements.txt --trusted-host pypi.org

# Expose sensitive port
EXPOSE 8080
EXPOSE 22
EXPOSE 3306
EXPOSE 5432

# Run as root with shell
CMD ["/bin/sh", "-c", "python3 app.py"]
