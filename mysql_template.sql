DROP DATABASE IF EXISTS db_name_here;
CREATE DATABASE db_name_here;
GRANT ALL PRIVILEGES ON db_name_here.* TO "user_name_here"@"localhost" IDENTIFIED BY "password_here";
FLUSH PRIVILEGES
