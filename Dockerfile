from amazonlinux:latest
ENV TERM=xterm-256color

#Add Dependencies
run yum update -y && \
    yum -y install git wget patch python3 python3-tools python3-pip python3-ldap 2to3 which tar awslogs sudo && \
    yum -y clean all
RUN curl --silent --location -sL https://rpm.nodesource.com/setup_13.x | bash -
RUN yum -y install nodejs
RUN npm install -g grunt-cli
#RUN npm install bower install grunt

#Add GNUHealth User
RUN adduser -m -d /home/gnuhealth gnuhealth && \
    echo "gnuhealth ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gnuhealth && \
    chmod 0440 /etc/sudoers.d/gnuhealth

#Make Python3 Default python binary
RUN rm /usr/bin/python && ln -si /usr/bin/python3 /usr/bin/python

#Switch to GNUHealth User
USER gnuhealth
ENV HOME /home/gnuhealth
WORKDIR /home/gnuhealth

#Get GNUHealth
RUN wget https://ftp.gnu.org/gnu/health/gnuhealth-latest.tar.gz && mkdir $HOME/gnuhealth-latest && tar xzf gnuhealth-latest.tar.gz -C gnuhealth-latest --strip-components=1 && rm gnuhealth-latest.tar.gz
WORKDIR $HOME/gnuhealth-latest
RUN wget -qO- https://ftp.gnu.org/gnu/health/gnuhealth-setup-latest.tar.gz | tar -xzvf -

#Fix werkzeug version to prevent "No module named 'werkzeug.contrib'"
RUN sed -i -E "s/werkzeug/\werkzeug==0.16.1/" gnuhealth-setup

#Install GNUHealth
RUN $HOME/gnuhealth-latest/gnuhealth-setup install

WORKDIR $HOME

#Install SAO Web Client
RUN git clone https://github.com/tryton/sao.git
WORKDIR $HOME/sao
RUN npm install grunt-po2json --save-dev
RUN npm install grunt-xgettext --save-dev
RUN npm install grunt --save-dev
RUN npm install --production
RUN grunt
WORKDIR $HOME

# Add SAO Webroot to trytond.conf
RUN sed -i '/^\[web\]/a\root = /home/gnuhealth/sao/' $HOME/gnuhealth/tryton/server/config/trytond.conf

# Listen on 0.0.0.0 to expose outside container
RUN sed -E -i "s/^listen = \*:8000/listen = 0.0.0.0:8000/g" $HOME/gnuhealth/tryton/server/config/trytond.conf
RUN sed -E -i "s/^listen = \*:8080/listen = 0.0.0.0:8080/g" $HOME/gnuhealth/tryton/server/config/trytond.conf

# Output logs
RUN ln -sf /dev/stdout /home/gnuhealth/gnuhealth/logs/gnuhealth.log

EXPOSE 8000
#Copy custom gnuhealthrc which contains Docker ENV Variables.
COPY gnuhealthrc $HOME/.gnuhealthrc
RUN /bin/bash -c "source $HOME/.gnuhealthrc"
ENTRYPOINT ["/home/gnuhealth/start_gnuhealth.sh"]
CMD [""]
