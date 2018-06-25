FROM python:2.7-wheezy

# Install locust
RUN pip install pyzmq locustio faker

ADD locustfile.py /config/locustfile.py
ADD runLocust.py /runLocust.py

ENV LOCUST_FILE /config/locustfile.py

EXPOSE 8089

#ENTRYPOINT ["/usr/local/bin/runLocust.sh"]
ENTRYPOINT ["/usr/bin/python", "/runLocust.py"]
