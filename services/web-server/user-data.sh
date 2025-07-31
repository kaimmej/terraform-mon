#!/bin/bash

# 
# Adding Ben's public key to the instance. 
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ" >> /home/ec2-user/.ssh/authorized_keys

# 
# DOCKER
service docker start


# 
# DOCKER COMPOSE
# Write the docker-compose file to the instance
cat << 'COMPOSE' > /home/ec2-user/compose.yml
name: dockermon
services:


  # Django application service.
  # Gunicorn is used as the WSGI server.
  app:
    image: kaimmej/django_dockermon:testV3
    container_name: django
    expose:
      - "8000" 
    ports:
      - "${server_port}:${server_port}"

  db:
    image: postgres:latest
    container_name: postgres-db
    environment:
      POSTGRES_USER: my_user
      POSTGRES_PASSWORD: my_password
      POSTGRES_DB: my_database
    ports:
      - "5432:5432"
  
COMPOSE

# Pull the latest Docker image for the Django application
docker pull kaimmej/django_dockermon:testV3

# RUN DOCKER-COMPOSE
docker-compose -f /home/ec2-user/compose.yml up -d