from flask import Flask, jsonify

import datetime

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), 200

@app.route('/')
def index():
    return "This is index page"

@app.route('/time')
def time():
    return jsonify({'result': datetime.datetime.now()})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)