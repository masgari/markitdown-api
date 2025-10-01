# Stage 1: Builder stage
FROM python:3.13-slim AS builder

# Install uv
RUN pip install uv

# Set the working directory
WORKDIR /app

# Copy requirements
COPY requirements.txt /app/

# Create a virtual environment and install dependencies with uv
RUN uv venv /app/venv
ENV PATH="/app/venv/bin:$PATH"
RUN uv pip install --no-cache-dir -r requirements.txt

# Stage 2: Final stage
FROM python:3.13-slim

# Create a non-root user
RUN groupadd -r mrkdn && useradd -r -g mrkdn mrkdn

# Set the working directory and ownership preemptively
WORKDIR /app
RUN chown mrkdn:mrkdn /app

# Copy the virtual environment from the builder stage
COPY --from=builder /app/venv /app/venv
RUN chown -R mrkdn:mrkdn /app/venv

# Set environment path
ENV PATH="/app/venv/bin:$PATH"

# Switch to non-root user before copying application code
USER mrkdn

# Copy only the application code with correct ownership using --chown
COPY --chown=mrkdn:mrkdn . /app/

# Make port available
EXPOSE 8490

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8490"]
