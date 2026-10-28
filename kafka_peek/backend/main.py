import os
from flask import Flask, jsonify, request
from flask_cors import CORS
from kafka import KafkaProducer, KafkaConsumer

BROKER = os.environ.get("KAFKA_BROKER", "localhost:9092")
TOPIC = os.environ.get("KAFKA_TOPIC", "peek")

app = Flask(__name__)
CORS(app)


@app.get("/")
def index():
    return "topic_peek is alive"


@app.get("/health")
def health():
    return jsonify(status="ok")


@app.post("/produce")
def produce():
    """
    Produce a message to the Kafka topic.

    Accepts JSON body with optional 'message' field.
    If no message is provided, defaults to "hello".

    Request body:
        {
            "message": "your custom message"
        }

    Returns:
        {
            "sent": "the message that was sent"
        }
    """
    message = (request.get_json(silent=True) or {}).get("message", "hello")
    producer = KafkaProducer(bootstrap_servers=BROKER)
    producer.send(TOPIC, message.encode())
    producer.flush()
    producer.close()
    return jsonify(sent=message)


@app.get("/messages")
def messages():
    consumer = KafkaConsumer(
        TOPIC,
        bootstrap_servers=BROKER,
        auto_offset_reset="earliest",
        consumer_timeout_ms=2000,
    )
    values = [m.value.decode() for m in consumer]
    consumer.close()
    return jsonify(messages=values[-10:])


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)