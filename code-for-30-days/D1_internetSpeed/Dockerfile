ARG PYTHON_BASE_IMAGE

FROM ${PYTHON_BASE_IMAGE}

ADD origin /

RUN pip install -r requirements.txt

EXPOSE 8000

CMD [ "python", "SpeedTestAPI.py" ]