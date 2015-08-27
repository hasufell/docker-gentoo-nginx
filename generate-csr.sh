# see: https://www.digicert.com/csr-creation-apache.htm

openssl req -new -newkey rsa:2048 -nodes -keyout config/ssl/server.key -out config/ssl/server.csr
