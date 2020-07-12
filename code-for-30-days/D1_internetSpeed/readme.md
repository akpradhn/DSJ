Day 1 : A Flask-WebApp to monitor internet speed

Overviews
- I have created a flask web-apps to monitor internet speed over on real time
- I have used speedtest-cli to collected internet speed
- Run in infinite loop to contineously collect the data
- Build a flask api to stream the data 
- Taking reference from https://github.com/roniemartinez/real-time-charts-with-flask/tree/0da0eedc3791f1e14a380e2d238c6fe0f0b5dc73 visualizing it over a flask api.
- Build a Docker image

Steps to run the app

* `git clone https://github.com/akpradhn/DSJ.git`

* `cd DSJ/code-for-30-days/D1_internetSpeed`

* `docker-compose build`

* `docker-compose up -d`

Link to webapps
http://127.0.0.1:8000/

API for Streaming Data 
curl --location --request GET 'http://127.0.0.1:8000/get-data-info'

