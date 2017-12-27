 mysql -uadmin -p8Jh0sZoGwvun -h<host> -P<port>


docker run -P --name alarmuser-service --link mysql-test:mysql -e "MYSQL_DATABASE=alarmuser" -e "MYSQL_USERNAME=admin" -e "MYSQL_PASSWORD=8Jh0sZoGwvun" edgar615/alarmuserservice