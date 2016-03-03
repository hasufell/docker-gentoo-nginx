FROM        mosaiksoftware/gentoo-amd64-paludis:latest
MAINTAINER  Julian Ospald <hasufell@gentoo.org>


##### PACKAGE INSTALLATION #####

# install nginx
RUN chgrp paludisbuild /dev/tty && \
	git -C /usr/portage checkout -- . && \
	env-update && \
	source /etc/profile && \
	cave sync gentoo && \
	cave resolve -c docker-nginx -x && \
	rm -rf /var/cache/paludis/names/* /var/cache/paludis/metadata/* \
		/var/tmp/paludis/* /usr/portage/* /srv/binhost/*

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

################################

# copy nginx config
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/sites-enabled /etc/nginx/sites-enabled
COPY ./config/sites-available /etc/nginx/sites-available

# set up modescurity
RUN cp /etc/nginx/modsecurity/modsecurity.conf \
	/etc/nginx/modsecurity/modsecurity.conf.orig
RUN git clone --depth=1 https://github.com/SpiderLabs/owasp-modsecurity-crs.git \
	/etc/modsecurity
RUN cat /etc/modsecurity/base_rules/*.conf >> \
	/etc/nginx/modsecurity/modsecurity.conf && \
	cp /etc/modsecurity/base_rules/*.data /etc/nginx/modsecurity/
RUN sed -i \
		-e 's|SecRuleEngine .*$|SecRuleEngine On|' \
		/etc/nginx/modsecurity/modsecurity.conf
COPY ./config/update-modsec.sh /usr/bin/update-modsec.sh
RUN chmod +x /usr/bin/update-modsec.sh

# supervisor config
COPY ./config/supervisord.conf /etc/supervisord.conf

# web server
EXPOSE 80 443

# create common group to be able to synchronize permissions to shared data volumes
RUN groupadd -g 777 www

CMD exec /usr/bin/supervisord -n -c /etc/supervisord.conf
