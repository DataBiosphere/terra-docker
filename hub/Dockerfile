FROM ubuntu:14.04

RUN apt-get -y update 

RUN apt-get -y install software-properties-common

RUN add-apt-repository -y ppa:cpick/hub

RUN apt-get -y update

RUN apt-get -y install hub

RUN git config --system core.logallrefupdates false

RUN mkdir -p /app/leo
WORKDIR /app/leo

RUN useradd -m dsde-jenkins
USER dsde-jenkins

RUN mkdir /home/dsde-jenkins/.config

CMD ["/bin/bash"]

