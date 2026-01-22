## running a empty nginx (mapping ports)

`docker run --rm --name nginx -p 80:80 nginx`

`docker ps`

`docker inspect nginx`

`curl http://<ip>`

try web browser with URL

`docker stop nginx`


## running with custom website (mapped volume)

`docker run --rm --name nginx -p 80:80 -v ${PWD}/data/:/usr/share/nginx/html nginx`

1. try curl and access the nginx from you web browser

1. change the `data/index.html` and refresh the webbrowser.

## end

`docker stop nginx`