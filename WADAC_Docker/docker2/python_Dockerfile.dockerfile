FROM python:3.7

WORKDIR /srv/shiny-server/WADAC_demo
ADD docker2/requirements.txt /usr/src/install/
#RUN apt-get install libhdf5-serial-dev
RUN pip3 install -r /usr/src/install/requirements.txt
