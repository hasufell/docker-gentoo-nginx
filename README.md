## Build the container

```
docker build -t hasufell/gentoo-nginx .
```

## Run

```
docker run -d -p 80:80 -p 443:443 hasufell/gentoo-nginx
```

Available volumes are `/etc/nginx` and `/srv/www`.
