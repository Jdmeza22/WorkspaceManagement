FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

COPY init.sql /scripts/init.sql
COPY init-db.sh /scripts/init-db.sh

RUN sed -i 's/\r$//' /scripts/init-db.sh
RUN chmod +x /scripts/init-db.sh

ENTRYPOINT ["/bin/bash", "/scripts/init-db.sh"]