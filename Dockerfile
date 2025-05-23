# The builder image, used to build the virtual environment
FROM python:3.12-slim AS builder

# Environment setup for build
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/home/appuser/.local/bin:${PATH}" \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

RUN apt-get update && apt-get install -y git

RUN groupadd -g 1001 appgroup && \
    adduser --uid 1001 --gid 1001 --disabled-password --gecos '' appuser

USER 1001

# Install Poetry 2.1.2
RUN pip install --user --no-cache-dir --upgrade pip && \
    pip install --user --no-cache-dir poetry==2.1.2

WORKDIR /home/appuser/app/
COPY pyproject.toml poetry.lock /home/appuser/app/
RUN poetry install --no-cache --no-root && \
    rm -rf $POETRY_CACHE_DIR

# The runtime image, used to just run the code provided its virtual environment
FROM python:3.12-slim AS runtime

# Environment setup for runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/home/appuser/app/.venv \
    PATH="/home/appuser/app/.venv/bin:/home/appuser/.local/bin:$PATH" \
    HOST=0.0.0.0 \
    LISTEN_PORT=8000

RUN groupadd -g 1001 appgroup && \
    adduser --uid 1001 --gid 1001 --disabled-password --gecos '' appuser

USER 1001
EXPOSE 8000
WORKDIR /home/appuser/app/

# Copy virtual environment from builder
COPY --chown=1001:1001 --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}


# Copy application files
COPY ./chainlit.md /home/appuser/app/chainlit.md
COPY --chown=1001:1001 ./.chainlit /home/appuser/app/.chainlit
COPY ./demo_app /home/appuser/app/demo_app

#force to port 8000
CMD ["chainlit", "run", "/home/appuser/app/demo_app/main.py", "--host", "0.0.0.0", "--port", "8000"]
