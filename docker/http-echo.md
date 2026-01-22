## running the echo server
`docker run -d --rm --name http-echo -e HTTP_PORT=80 mendhak/http-https-echo`

`docker inspect http-echo`

`docker inspect http-echo --format json | jq '.[0].NetworkSettings.Networks.bridge.IPAddress'`

## querying with curl

`curl http://<ip>:80/`

`curl -HHost:from.example.com -HUser-Agent:Mozzila/5.3 http://<ip>/some/path/here?id=1&param=test`


## running network tooling container

`docker run -it --rm --name netshoot nicolaka/netshoot`

withing the container, curl the http-echo "server"