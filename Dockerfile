FROM        hasufell/gentoo-amd64-paludis:latest
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
referer rewrite scgi ssi split_clients upstream_ip_hash userid uwsgi \
" \
	>> /etc/paludis/use.conf.d/nginx.conf

# install nginx
RUN chgrp paludisbuild /dev/tty && cave resolve -z www-servers/nginx:0 -x

# install tools
RUN chgrp paludisbuild /dev/tty && cave resolve -z app-admin/supervisor sys-process/htop -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

# supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

VOLUME ["/etc/nginx"]
VOLUME ["/srv/www"]

# web server
EXPOSE 80 443

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
