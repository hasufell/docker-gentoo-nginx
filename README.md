## Build the container

```
docker build -t hasufell/gentoo-nginx .
```

## Run

If you use IPv4 and have __usable__ nginx configuration in `/etc/nginx` and
static web files in `/srv/www` (nginx must be configure to use that location)
on the __host__, then you might want to run:
```
docker run -d \
	-p 80:80 \
	-p 443:443 \
	-v /etc/nginx:/etc/nginx \
	-v /srv/www:/srv/www \
	hasufell/gentoo-nginx
```

## Enabling modsecurity

Modsecurity configuration and files are installed into `/etc/nginx/modsecurity`.
It includes the `base_rules` rules from the `www-apache/modsecurity-crs` package.
If you want to use your own ruleset/configuration, simply mount in the
`/etc/nginx/modsecurity` directory from the host and configure your site to
something like:
```
	location / {
		root   /srv;
		autoindex on;
		ModSecurityEnabled on;
		ModSecurityConfig modsecurity/modsecurity.conf;
	}
```
