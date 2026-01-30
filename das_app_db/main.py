from flask import Flask, jsonify
import os
import datetime
from pymongo import MongoClient  
import random

APP_LABEL = os.environ.get('APP_LABEL', 'Das APP')
HTTP_PORT = os.environ.get('HTTP_PORT', 8080) 

mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/das_app_mongo')
client = MongoClient(mongo_uri)
db = client.das_app
main_collection = db.main ## creating / connecting to main collection
fortune_collection = db.fortune

app = Flask(__name__)

@app.route('/fortune')
def init_db():
    try:

        # fortune_count = format.count_documents({})

        # select = random.randint(fortune_count)

        results = fortune_collection.find({}).limit(100)
        
        # records = { k:v for k,v in results }
        records = [ x for x in results]
        # print(records)

        return jsonify({'msg': random.choice(records)['msg']}), 200
        # return jsonify(str(records)), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500



@app.route('/health', methods=['GET'])
def health():
    try:
        client.admin.command('ping')
        return jsonify({"status": "healthy", "database": "connected"}), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 503

@app.route('/')
def index():
    return f"This is index page, hello from {APP_LABEL}"


@app.route('/add/<msg>')
def add_msg(msg):
    try:
        record = {
            'msg': msg,
            'timestamp': datetime.datetime.utcnow(),
        }
        db_result = main_collection.insert_one(record)
        return jsonify({'result': 'ok'}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/list')
def list_msg():
    try:
        db_result = main_collection.find({}).sort('timestamp', -1).limit(100)

        result = []
        for i_msg in db_result:
            record = {
                'timestamp': i_msg['timestamp'],
                'msg': i_msg['msg'],
            }

            result.append(record)
        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=HTTP_PORT)