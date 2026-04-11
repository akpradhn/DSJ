# -*- coding: utf-8 -*-

from flask import Flask, request, redirect, url_for,render_template,send_file
from werkzeug import secure_filename
import logging
import sys
import os
from flask.json import jsonify
import time
import requests
from os import path

# Face Detection Library
from matplotlib import pyplot
from matplotlib.patches import Rectangle
from matplotlib.patches import Circle
from mtcnn.mtcnn import MTCNN

detector = MTCNN()

# draw an image with detected objects
def draw_image_with_boxes(filename, result_list,result_id):
  # load the image
  data = pyplot.imread(filename)
  # plot the image
  pyplot.imshow(data)
  # get the context for drawing boxes
  ax = pyplot.gca()
  # plot each box
  for result in result_list:
    # get coordinates
    x, y, width, height = result['box']
    # create the shape
    rect = Rectangle((x, y), width, height, fill=False, color='red')
    # draw the box
    ax.add_patch(rect)
    # draw the dots
    for key, value in result['keypoints'].items():
      # create and draw dot
      dot = Circle(value, radius=2, color='red')
      ax.add_patch(dot)
  # show the plot
  #pyplot.show()
  pyplot.savefig(result_id)


logging.basicConfig(stream=sys.stdout, format='%(levelname)s : %(asctime)s : %(message)s', level=logging.INFO)


app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = "/Users/amit/Desktop/projects/faceDetection/image_files"
app.config['RESULT_FOLDER'] = "/Users/amit/Desktop/projects/faceDetection/image_results"

@app.route('/')
def homepage():
    return '''<!doctype html>
              <title>Upload new File</title>
              <h1>Upload new File</h1>
              <form action="" method=post enctype=multipart/form-data>
                <p><input type=file name=file>
                <input type=submit value=Upload>
              </form>'''

    # return '''<p><input type="file"  accept="image/*" name="image" id="file"  onchange="loadFile(event)" style="display: none;"></p>
    # <p><label for="file" style="cursor: pointer;">Upload Image</label></p>
    # <p><img id="output" width="200" /></p>

    # <script>
    # var loadFile = function(event) {
    #   var image = document.getElementById('output');
    #   image.src = URL.createObjectURL(event.target.files[0]);
    # };
    # </script>'''

@app.route('/upload_image', methods=['POST'])
def upload_file():
    if request.method == 'POST':
        file = request.files['file']
        file_name = secure_filename(file.filename)
        logging.info('=== response %s',file_name)
        file.save(os.path.join(app.config['UPLOAD_FOLDER'], file_name))
        logging.info('=== file Saved %s',file_name)

        image_path = app.config['UPLOAD_FOLDER']+'/'+file_name
        # load image from file
        pixels = pyplot.imread(image_path)
        
        # detect faces in the image
        faces = detector.detect_faces(pixels)

        result_id = app.config['RESULT_FOLDER']+'/FD'+str(int(time.time()))+file_name 

        # Saving Image Result 
        draw_image_with_boxes(file_name, faces, result_id)
        n = 0
        detect_result = {}
        face_details = []
        for i in faces:
          n=n+1
          temp = {}
          temp['Face #'] = n
          temp['Confidence'] = i['confidence']
          face_details.append(temp)
        detect_result['result_image'] = result_id
        detect_result['face_detected'] = True if len(face_details)>0 else False
        detect_result['total_faces'] = len(face_details)
        detect_result['face_details'] = face_details
        
        return jsonify(detect_result)

@app.route('/detect_from_url', methods=['GET'])
def detect_url():
  url = request.args.get("url")
  logging.info('=== Image url %s',url)
  
  f_ext = os.path.splitext(url)[-1]
  file_name = 'img{}'.format(f_ext)

  try:
    image = requests.get(url)
  except OSError:  # Little too wide, but work OK, no additional imports needed. Catch all conection problems
    return False
      
  if image.status_code == 200:  # we could have retrieved error page
          base_dir = app.config['UPLOAD_FOLDER']  # Use your own path or "" to use current working directory. Folder must exist.
          with open(path.join(base_dir, file_name), "wb") as f:
              f.write(image.content)

  logging.info('=== file Saved %s',file_name)

  image_path = app.config['UPLOAD_FOLDER']+'/'+file_name
  # load image from file
  logging.info('=== image_path %s',image_path)

  pixels = pyplot.imread(image_path)
  
  # detect faces in the image
  faces = detector.detect_faces(pixels)

  result_id = app.config['RESULT_FOLDER']+'/FD'+str(int(time.time()))+file_name 
  logging.info('=== result_id %s',result_id)
  # Saving Image Result 
  draw_image_with_boxes(image_path, faces, result_id)
  n = 0
  detect_result = {}
  face_details = []
  for i in faces:
    n=n+1
    temp = {}
    temp['Face #'] = n
    temp['Confidence'] = i['confidence']
    face_details.append(temp)

  detect_result['result_image'] = result_id
  detect_result['face_detected'] = True if len(face_details)>0 else False
  detect_result['total_faces'] = len(face_details)
  detect_result['face_details'] = face_details
  
  return jsonify(detect_result)

if __name__ == '__main__':
  app.debug=True
  app.run()