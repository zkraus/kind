# topic_peek

Small Flask app that sends messages to a Kafka topic and shows the latest ones.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Docker Compose Network                  │
│                                                              │
│  ┌──────────────────────┐          ┌───────────────────┐   │
│  │   Flask App (8000)   │          │   Kafka Broker    │   │
│  │                      │          │   (kraft mode)    │   │
│  │  GET  /              │          │                   │   │
│  │  GET  /health        │          │   Topic: "peek"   │   │
│  │  POST /produce       │◄────────►│                   │   │
│  │  GET  /messages      │          │   Port: 9092      │   │
│  │                      │          │                   │   │
│  └──────────────────────┘          └───────────────────┘   │
│           ▲                                                  │
│           │                                                  │
└───────────┼──────────────────────────────────────────────────┘
            │
            │ Port: 8000
            ▼
     ┌──────────────┐
     │   Client     │
     │   (curl)     │
     └──────────────┘
```

**Flow:**
1. Client sends POST to `/produce` with message
2. Flask app produces message to Kafka topic "peek"
3. Client requests GET `/messages`
4. Flask app consumes last 10 messages from Kafka and returns them

## Build custom app

- `main.py`: Flask app with `/health`, `POST /produce` and `GET /messages`
- `requirements.txt`: flask, kafka-python
- `Dockerfile`: Python 3.12 slim image running the app on port 8000

## Building and running with podman compose

- `compose.yaml`: two services, `kafka` (single-node broker) and `app`
- Build and start: `make up`
- Send and read a message: `make test`
- Logs: `make logs`
- Stop: `make down`

Notes: the app reaches the broker at `kafka:9092` via the compose network.

short “problems I hit” section if you like (the Docker Hub pull limit and the switch to quay.io are good material), since teachers usually like that.