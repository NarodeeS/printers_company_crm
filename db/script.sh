echo 'hostssl clients_database +manager all scram-sha-256' >> /var/lib/postgresql/data/db/pg_hba.conf
echo 'hostssl all admin all scram-sha-256' >> /var/lib/postgresql/data/db/pg_hba.conf
echo 'hostssl clients_database +worker all scram-sha-256' >> /var/lib/postgresql/data/db/pg_hba.conf

psql -U admin -f "/app/creation.sql"
