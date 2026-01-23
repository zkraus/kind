from flask import Flask, jsonify
import os
import datetime

APP_LABEL = os.environ.get('APP_LABEL', 'Das APP')
HTTP_PORT = os.environ.get('HTTP_PORT', 8080)

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/')
def index():
    return f"This is index page, hello from {APP_LABEL}"

@app.route('/time')
def time():
    return jsonify({'result': datetime.datetime.now()})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=HTTP_PORT)