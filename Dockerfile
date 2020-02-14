FROM tryton/tryton:5.0
USER root
RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y apt-utils git sudo npm
RUN curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
RUN sudo apt-get install -y nodejs

#Add GNUHealth User
RUN useradd -m -d /home/gnuhealth gnuhealth && \
    echo "gnuhealth ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/gnuhealth && \
    chmod 0440 /etc/sudoers.d/gnuhealth
USER gnuhealth
ENV PATH="/home/gnuhealth/.local/bin:${PATH}"
WORKDIR /home/gnuhealth

#Install GNUHealth
RUN python3 -m pip install --user --upgrade pip setuptools wheel
RUN pip3 install --user gnuhealth
RUN git clone https://github.com/tryton/sao.git
WORKDIR ./sao
RUN npm install --production
WORKDIR /home/gnuhealth
#RUN sudo npm install -g grunt-cli
#RUN npm install grunt --save-dev
#RUN npm install grunt-po2json --save-dev
#RUN npm install grunt-xgettext --save-dev
#RUN grunt
#RUN sudo npm install -g bower
#RUN sudo bower install --allow-root


