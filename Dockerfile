FROM        hasufell/gentoo-amd64-paludis:20150820
MAINTAINER  Julian Ospald <hasufell@gentoo.org>

# global USE flags
RUN echo -e "*/* acl bash-completion ipv6 kmod openrc pcre readline unicode \
zlib pam ssl sasl bzip2 urandom crypt tcpd \
-acpi -cairo -consolekit -cups -dbus -dri -gnome -gnutls -gtk -gtk2 -gtk3 \
-ogg -opengl -pdf -policykit -qt3support -qt5 -qt4 -sdl -sound -systemd \
-truetype -vim -vim-syntax -wayland -X \
" \
	>> /etc/paludis/use.conf

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x

# per-package USE flags
# check these with "cave show <package-name>"
RUN mkdir /etc/paludis/use.conf.d && echo -e "\
www-servers/nginx http http-cache ipv6 pcre ssl \
\n\
\nwww-servers/nginx NGINX_MODULES_HTTP: \
access auth_basic auth_pam auth_request autoindex browser charset empty_gif \
dav dav_ext fastcgi geo gzip limit_req limit_conn map memcached perl proxy \
referer rewrite scgi ssi spdy split_clients upstream_ip_hash userid uwsgi \
" \
	>> /etc/paludis/use.conf.d/nginx.conf

# install nginx
RUN chgrp paludisbuild /dev/tty && cave resolve -z www-servers/nginx:0 -x

# install tools
RUN chgrp paludisbuild /dev/tty && cave resolve -z app-admin/supervisor sys-process/htop -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

# copy nginx config
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/sites-available /etc/nginx/sites-available

# supervisor config
COPY ./config/supervisord.conf /etc/supervisord.conf

# intall docker-gen
ENV DOCKER_GEN_VERSION 0.4.0
RUN wget https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
	&& tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
	&& rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

# Install Forego
RUN wget -P /usr/local/bin https://godist.herokuapp.com/projects/ddollar/forego/releases/current/linux-amd64/forego \
 && chmod u+x /usr/local/bin/forego

# web server
EXPOSE 80 443

# create common group to be able to synchronize permissions to shared data volumes
RUN groupadd -g 777 www

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
