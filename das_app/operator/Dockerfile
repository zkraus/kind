# Dockerfile for the DasApp operator
# This builds a container image that runs the operator

FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy operator code
COPY operator.py .

# Run the operator
# kopf run watches for DasApp resources and calls our handlers
CMD ["kopf", "run", "--verbose", "operator.py"]
