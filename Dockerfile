from amazonlinux:latest
ENV TERM=xterm-256color

#Add Dependencies
run yum update -y && \
    yum -y install git wget patch python3 python3-tools python3-pip 2to3 which tar awslogs jq && \
    yum -y clean all && \
    pip3 install pymongo --no-cache-dir
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -
RUN yum -y install nodejs
RUN npm install -g grunt-cli sudo npm install -g bower
RUN npm install bower install grunt
#Add GNUHealth User
run useradd -m -d /home/gnuhealth gnuhealth
#Make Python3 Default python binary
run rm /usr/bin/python && ln -si /usr/bin/python3 /usr/bin/python
#Switch to GNUHealth User
USER gnuhealth
ENV HOME /home/gnuhealth
workdir /home/gnuhealth
#Get & Install GNUHealth
run wget https://ftp.gnu.org/gnu/health/gnuhealth-latest.tar.gz && mkdir $HOME/gnuhealth-latest && tar xzf gnuhealth-latest.tar.gz -C gnuhealth-latest --strip-components=1 && rm gnuhealth-latest.tar.gz
workdir $HOME/gnuhealth-latest
run $HOME/gnuhealth-latest/gnuhealth-setup install && rm -rf gnuhealth-latest
run /bin/bash -c "source $HOME/.gnuhealthrc"
WORKDIR $HOME
RUN git clone https://github.com/tryton/sao.git
WORKDIR $HOME/sao
RUN npm install --production && grunt
WORKDIR $HOME
RUN sed -i '/^\[web\]/a\root = /home/gnuhealth/sao/' $HOME/gnuhealth/tryton/server/config/trytond.conf
RUN ls -laSH
RUN cat $HOME/gnuhealth/tryton/server/config/trytond.conf
RUN ln -sf /dev/stdout /home/gnuhealth/gnuhealth/logs/gnuhealth.log
expose 8000
CMD ["./start_gnuhealth.sh"]
