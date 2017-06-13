DROP DATABASE wordpress;
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO "testuser"@"localhost" IDENTIFIED BY "password";
FLUSH PRIVILEGES
