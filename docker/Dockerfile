FROM python:3.11-slim

# Install system packages + PostgreSQL client
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first (better caching)
COPY requirements.txt .

# Install Python libraries
RUN pip install --no-cache-dir -r requirements.txt

# Expose Jupyter port
EXPOSE 8888

# Default command
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]