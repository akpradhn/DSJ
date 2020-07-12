
import speedtest as st
from datetime import datetime
import ssl
ssl._create_default_https_context = ssl._create_unverified_context

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

  temp['time']        = datetime.today().strftime("%Y-%m-%d %H:%M:%S")
  #temp['ping']              = ping
  temp['value']    = download_mbs
  #temp['upload_mbs']        = upload_mbs

  return temp

