FROM postgres:14

RUN mkdir app
COPY script.sh /app

RUN ["chmod", "+x", "./app/script.sh"]

COPY new_creation.sql /app
COPY script.sh /docker-entrypoint-initdb.d/
COPY server.crt /var/ssl/
COPY server.key /var/ssl/

RUN yes | apt update && yes | apt upgrade
RUN apt-get -y install postgresql-14-cron
RUN apt-get install -y locales
RUN sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen
RUN locale-gen

USER root
RUN chmod 600 /var/ssl/server.key
RUN chown postgres.postgres /var/ssl/server.key
RUN echo "export LC_ALL=en_US.UTF-8" >> ~/.bashrc
RUN echo "export LANG=en_US.UTF-8" >> ~/.bashrc
RUN echo "export LANGUAGE=en_US.UTF-8" >> ~/.bashrc

