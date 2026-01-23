## Build custom app

1. Create app `main.py` using python and flask
example app has following enpoints:
- `/` -- returns "welcome" page, like regular webpage `index.html`
- `/health` -- to report healthy when deployed
- `/time` -- to report current time "useful" feature 

2. Create `Dockerfile` to build the app
- pick baseimage
- copy the app onto image
- install dependencies (flask)
- expose ports (8080)
- run the app

3. Build the app in docker

`docker build -t dat_app .`

`docker image list`

built image is available only in your local docker.

4. run the image with ports and test

`docker run -p 80:8080 das_app:latest`

port forwarding host 80/TCP -> container 8080/TCP (as flask app uses 8080)

`curl http://<ip>/`
`curl http://<ip>/health`
`curl http://<ip>/time`

5. Add a env variable `APP_LABEL`
`docker run -p 80:8080 -e APP_LABEL=my_custom_app das_app:latest`
and try the `/` endpoint.

6. stop
`docker stop ...` or <ctrl-c> in the container terminal


## Building and running with docker compose

Docker compose is intended for multi container setup (e.g. web app + DB). For now we will do compose just without the simple app.

1. create docker compose `compose.yaml`
2. use docker compose to deploy the app

`docker compose up` -- it will be first built and then deployed, will not rebuild when changing

`docker compose build` -- to rebuild 
or
`docker compose up --build` -- to do both

3. test endpoints

`curl ...`

4. add env variable to docker compose

```yaml
environment:
    APP_LABEL: my custom lable from compose
```

run and check

5. detached mode

same as with regular docker `-d` or `--detached` to run without console like daemon.

6. checking running stuff
`docker compose top`

7. stopping

`docker compose down`
