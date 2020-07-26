from config import *
from pymongo import MongoClient
from pymongo.uri_parser import parse_uri
import speedtest as st
from datetime import datetime
import ssl
import json
import time

ssl._create_default_https_context = ssl._create_unverified_context

# Database: Rapido

client                      = MongoClient(MONGO_URL, ssl_cert_reqs=ssl.CERT_NONE)
db                          = client['home_project']
speed_collection            = db['internet_speed']


def get_new_speeds():

  temp = {}

  speed_test = st.Speedtest()
  speed_test.get_best_server()

  # Get ping (miliseconds)
  ping          = speed_test.results.ping

  # Perform download and upload speed tests (bits per second)
  download      = speed_test.download()
  upload        = speed_test.upload()

  # Convert download and upload speeds to megabits per second
  download_mbs  = round(download / (10**6), 2)
  upload_mbs    = round(upload / (10**6), 2)

  temp['ts']                = datetime.today().strftime("%Y-%m-%d %H:%M:%S")
  temp['date']              = datetime.today().strftime("%Y-%m-%d")
  temp['ping']              = ping
  temp['download_mbs']      = download_mbs
  temp['upload_mbs']        = upload_mbs

  return temp

while True:
    try:
        internet_info = get_new_speeds()
        time.sleep(300)
        print(internet_info)
        speed_collection.insert_one(internet_info)

        print('==== Record Captured')
    except:
        print('==== Failed to Captured')




