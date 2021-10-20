# Dockerfile
FROM jenkins/ssh-agent:jdk11
RUN echo PATH=$PATH >> /etc/environment
RUN mkdir /var/jenkins