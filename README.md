## Build the container

```
docker build -t hasufell/gentoo-nginx .
```

## Run

Available volumes are `/etc/nginx` and `/srv/www`.

If you use IPv4 and have __usable__ nginx configuration in `/etc/nginx` and
static web files in `/srv/www` (nginx must be configure to use that location)
on the __host__, then you might want to run:
```
docker run -d -v /etc/nginx:/etc/nginx -v /srv/www:/srv/www -p 80:80 -p 443:443 hasufell/gentoo-nginx
```
