#!/bin/bash

# 
# Adding Ben's public key to the instance. 
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwp+5sSt53+244HeH6l1ZCM+jsEX3woB+K8Noi1eenZ" >> /home/ec2-user/.ssh/authorized_keys

# 
# DOCKER
service docker start
export PG_PASSWORD=$(aws secretsmanager get-secret-value --secret-id postgres-master-user --query SecretString)
# docker run -d -p 80:80 -e PG_PASSWORD=$${PG_PASSWORD} -e PG_USER=master nginx

# 
# NGINX
# Write the nginx.conf file to the instance
# This configuration sets up NGINX to reverse proxy requests to the Django application.
cat << 'NGINXCONF' > /home/ec2-user/nginx.conf
events {}

http {
  server {
    listen 80;

    location / {
      proxy_pass http://app:${server_port};
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
  }
}
NGINXCONF

# 
# DOCKER COMPOSE
# Write the docker-compose file to the instance
cat << 'COMPOSE' > /home/ec2-user/compose.yml
name: dockermon
version: '3.8'
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
  
  # NGINX reverse proxy setup.
#   nginx:
#     image: nginx:latest
#     container_name: nginx-proxy
#     ports:
#       - "80:80"
#     volumes:
#       - ./nginx.conf:/etc/nginx/nginx.conf
#     depends_on:
#       - app

COMPOSE

# Pull the latest Docker image for the Django application
docker pull kaimmej/django_dockermon:testV3

# RUN DOCKER-COMPOSE
docker-compose -f compose.yml up -d