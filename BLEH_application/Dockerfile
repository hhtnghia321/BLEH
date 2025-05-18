# Use a stable Ubuntu base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Python, pip, and other needed system packages
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /BLEH_application

# Copy the application code
COPY . /BLEH_application

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Expose the port uvicorn will run on
EXPOSE 30000

# Start the FastAPI app with uvicorn
# CMD ["gunicorn", "main:app", "-k", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:30000"]
# CMD ["bash"]
CMD ["uvicorn", "main:app", "--reload" , "--host", "0.0.0.0", "--port" ,"30000"]