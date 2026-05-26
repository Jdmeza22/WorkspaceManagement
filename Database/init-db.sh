#!/bin/bash

echo "Iniciando SQL Server..."

/opt/mssql/bin/sqlservr &

echo "Esperando 20 segundos iniciales..."

sleep 20

echo "Verificando disponibilidad de SQL Server..."

until /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'SecPass2026*' \
    -C \
    -Q "SELECT 1" &> /dev/null
do
    echo "SQL Server aún no está listo..."
    sleep 5
done

echo "SQL Server listo"

echo "Ejecutando init.sql..."

/opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'SecPass2026*' \
    -C \
    -i /scripts/init.sql

echo "Base de datos inicializada"

wait