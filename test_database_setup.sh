mysql -u root -e "CREATE USER 'transition'@'localhost' IDENTIFIED BY 'transition'"
mysql -u root -e 'CREATE DATABASE transition_test'
mysql -u root -e "GRANT ALL ON transition_test.* TO 'transition'@'localhost'"
mysql -u root -D transition_test < db/structure.sql
