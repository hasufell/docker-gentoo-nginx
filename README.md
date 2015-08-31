## Install

Either pull the image
```sh
docker pull hasufell/gentoo-nginx:20150820
```

or build it yourself:
```sh
docker build -t hasufell/gentoo-nginx:20150820 <path-to-this-repo>
```

## Run

If you use IPv4 and have __usable__ nginx configuration in `/etc/nginx` and
static web files in `/srv/www` (nginx must be configure to use that location)
on the __host__, then you might want to run:
```
docker run -d \
	-p 80:80 -p 443:443 \
	-v /etc/nginx:/etc/nginx \
	-v /srv/www:/srv/www \
	hasufell/gentoo-nginx:20150820
```

Nginx is started via supervisord and is configured to automatically restart.

Port 80 and 443 are exposed.

## Advanced nginx configuration (docker-gen support)

Since nginx doesn't have proper support for environment variables,
this image has [docker-gen](https://github.com/jwilder/docker-gen) and
[forego](https://github.com/ddollar/forego) preinstalled, so you can
create automated template configuration. A typical example would be
to [configure an automated reverse proxy](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/) by supplying a docker-gen
template (`nginx.tmpl` here) and starting it via forego (uses `Procfile`).
E.g.:
```sh
docker run -ti -d \
	-p 80:80 -p 443:443 \
	-v "`pwd`"/config/examples/nginx.tmpl:/app/nginx.tmpl \
	-v "`pwd`"/config/examples/Procfile:/app/Procfile \
	-v /var/run/docker.sock:/tmp/docker.sock \
	-e DOCKER_HOST=unix:///tmp/docker.sock \
	hasufell/gentoo-nginx:20150820 \
	sh -c 'cd /app && forego start -r'
```

Also see [here](https://github.com/jwilder/nginx-proxy) for configuration
instructions.
