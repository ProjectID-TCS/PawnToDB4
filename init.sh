 #!/bin/bash
echo -e "DROP USER IF EXISTS project; \n DROP DATABASE IF EXISTS project" | sudo psql -U postgres
echo -e "CREATE USER project WITH PASSWORD 'chess' CREATEDB; \nCREATE DATABASE project" | sudo psql -U postgres
sudo psql -U project  < drop.sql
