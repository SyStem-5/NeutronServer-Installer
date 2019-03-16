# Pull official base image
FROM python:3.6-alpine

# Set environment varibles
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set work directory
WORKDIR /usr/src/djangoapp

# Copy project
COPY ./app /usr/src/djangoapp/

# Copy entrypoint.sh
COPY ./entrypoint.sh /entrypoint.sh

# Install psycopg2
RUN apk update \
    && apk add --virtual build-deps gcc python3-dev musl-dev  \
    && apk add postgresql-dev \
    && pip install --upgrade pip \
    && pip install pipenv \
    && pipenv install --ignore-pipfile --system \
    && apk del build-deps \
    && chmod +x /entrypoint.sh
#   && apk add tree \

ENTRYPOINT ["/entrypoint.sh"]
