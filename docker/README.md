
## queries
`docker ps [-a]`

`docker image list`

`docker search <pattern>`

`docker inspect <container>` -- getting container info incl. IP address

## Running
`docker run <image-name>`
* `-it` -- interactive, +tty
* `-d` -- detach, in the background, useful for servers
* `-e <KEY>=<VALUE>` -- environment variables
* `--name <container_name>` -- custom container name, has to be unique on re-runs
* `--rm` -- automatic remove, on exit, useful with `--name`

`docker exec [-it] <container> <command>` -- executing a new command inside the container

## Useful docker commands


## Useful images:
- hello-world:latest
- hashicorp/http-echo
- mendhak/http-https-echo
- nicolaka/netshoot
- 


## cleanup

listing all container ids
`docker ps -a -q`

listing all image ids
`docker image list -q`

stop all
`docker stop $(docker ps -a -q)`

remove all unused containers
`docker container prune`

remove all unused images
`docker image prune`

Completely remove all images
`docker image rm $(docker image list -q)`


## detached

Running a container in the background without seeting console.

`-d` or `--detach`:

`docker run -d ...`
