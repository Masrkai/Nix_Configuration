create user ${secrets.databaseUser} with encrypted password '${secrets.databasePassword}';
create database mydatabase;
grant all privileges on database mydatabase to ${secrets.databaseUser};