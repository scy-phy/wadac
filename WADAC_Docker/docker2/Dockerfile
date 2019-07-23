FROM rocker/r-base:latest

ENV DEBIAN_FRONTEND noninteractive
ENV PATH /opt/conda/bin:$PATH

# Install Anaconda
RUN apt-get -qq update && apt-get install -y wget
RUN wget https://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    /bin/bash Miniconda2-latest-Linux-x86_64.sh -b -p /opt/conda

RUN apt-get install -t unstable -y libcurl4-openssl-dev libssl-dev gdebi-core python3-pip
#apt-get install python3-pip
ENV TENSORFLOW_PYTHON /opt/conda/bin/python
RUN pip install tensorflow keras utils np_utils h5py
ADD docker2/requirements.txt /usr/src/install/
RUN pip3 install -r /usr/src/install/requirements.txt
# Download and install ShinyServer (latest version)
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN mkdir /code
ADD docker2/install.R /code
RUN Rscript /code/install.R

RUN rm /srv/shiny-server/index.html &&\
    rm -rf /srv/shiny-server/sample-apps

COPY ./WADAC_demo /srv/shiny-server/WADAC_demo
#COPY ./Injection_Molding /srv/shiny-server/Injection_Molding
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
COPY shiny-server.sh /usr/bin/shiny-server.sh
CMD ["/usr/bin/shiny-server.sh"]


#CMD R -e "shiny::runApp('WADAC_demo')"
#CMD ["R -e "shiny::runApp('WADAC_demo')""]
#CMD ["R"]
