import json
import random
import time
from datetime import datetime
from flask import Flask, Response, render_template
from controller import get_new_speeds


application = Flask(__name__)

@application.route('/')
def index():
    return render_template('index.html')


@application.route('/get-data-info')
def chart_data():
    def generate_internetSpeed():
        while True:
            json_data = json.dumps(get_new_speeds())
            yield f"data:{json_data}\n\n"
            time.sleep(1)
    return Response(generate_internetSpeed(), mimetype='text/event-stream')


if __name__ == '__main__':
    application.run(host='0.0.0.0', port=8001, debug=True)
