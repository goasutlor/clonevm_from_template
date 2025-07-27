FROM python:3.11-slim

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 5051

# Set environment variable
ENV FLASK_APP=vm_provisioning.app
ENV FLASK_ENV=development

# Run the application
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=5051"]
