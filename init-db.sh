
echo "Iniciando SQL Server..."

/opt/mssql/bin/sqlservr &

echo "Esperando SQL Server..."

until /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'SEC_PASS2026*' \
    -C \
    -Q "SELECT 1" &> /dev/null
do
    sleep 5
done

echo "SQL Server listo"

echo "Ejecutando init.sql..."

/opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U sa \
    -P 'SEC_PASS2026*' \
    -C \
    -i /Database/init.sql

echo "Base de datos inicializada"

wait