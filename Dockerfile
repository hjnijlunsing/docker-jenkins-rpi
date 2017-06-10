FROM dilgerm/rpi-app-base:jessie
MAINTAINER Martin Dilger <martin@effectivetrainings.de>

RUN mkdir /var/jenkins_home

ENV JENKINS_HOME /var/jenkins_home
RUN groupadd -r jenkins && useradd -d $JENKINS_HOME jenkins -g jenkins
RUN chown -R jenkins /var/jenkins_home

RUN apt-get update && apt-get install -y wget nodejs npm git unzip curl software-properties-common
RUN echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" >>  /etc/apt/sources.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
RUN apt-get update && apt-get install -y ansible ssh-client iproute
RUN curl -sSL https://get.docker.com | sh

RUN mkdir /var/jenkins_work
RUN chown -R jenkins /var/jenkins_work
RUN chown -R jenkins /usr/local

USER jenkins
WORKDIR /var/jenkins_work

RUN wget http://mirrors.jenkins-ci.org/war/latest/jenkins.war

ENV NODE_VERSION 0.12.0
RUN wget https://s3-eu-west-1.amazonaws.com/conoroneill.net/wp-content/uploads/2015/02/node-v${NODE_VERSION}-linux-arm-pi.tar.gz 
RUN cd /usr/local && \
    tar --strip-components 1 -xzf /var/jenkins_work/node-v${NODE_VERSION}-linux-arm-pi.tar.gz &&\
    rm -rf /var/jenkins_work/node-v${NODE_VERSION}-linux-arm-pi.tar.gz   
 
RUN npm update && \
    npm install -g grunt grunt-cli


WORKDIR /var/jenkins_work
RUN wget https://github.com/piksel/phantomjs-raspberrypi/archive/master.zip 
RUN unzip master.zip
RUN mv phantomjs-raspberrypi-master/bin/phantomjs /usr/local/bin/phantomjs
RUN rm -rf phantomjs-raspberrypi-master
RUN chmod +x /usr/local/bin/phantomjs
ENV PHANTOMJS_BIN=/usr/local/bin/phantomjs

USER root
RUN apt-get install -y build-essential

#install python - docker-compose has some dependencies
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN pip install jsonschema

RUN pip install docker-compose

#shipwright
RUN pip install shipwright

RUN usermod -a -G root jenkins
WORKDIR /var/jenkins_home
#USER jenkins
ENV JENKINS_HOME=/var/jenkins_home
CMD java -jar /var/jenkins_work/jenkins.war
