.PHONY: build run up down stop

IMAGE_NAME=das_app
VERSION=0.1.0


build:
	docker build -t $(IMAGE_NAME):$(VERSION) .

run: build
	docker run -d --name $(IMAGE_NAME) --rm -p 80:8080 $(IMAGE_NAME):$(VERSION)

stop:
	docker stop $(IMAGE_NAME)

up:
	docker compose up --build --detach

down:
	docker compose down

curl:
	curl http://127.0.0.1/
	curl http://127.0.0.1/health
	curl http://127.0.0.1/time