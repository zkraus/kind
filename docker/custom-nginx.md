## Build-in custom webpage with nginx

Create a dockerfile called `Dockerfile` and follow this https://hub.docker.com/_/nginx

```Dockerfile
FROM nginx ## base image
COPY data/index.html /usr/share/nginx/html ## copy files from host into image
## in this case, there is no need to overwrite RUN command, nginx will do correct run command
```

and build

`docker build -t my-custom-nginx .`

and run

`docker run --rm --name my_nginx -p 80:80 my-custom-nginx`

and test via curl and web browser

now changing the webpage on the disc won't work


## end

`docker image list`

`docker image rm my_custom_nginx`