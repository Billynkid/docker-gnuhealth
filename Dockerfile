from amazonlinux:latest
ENV TERM=xterm-256color

#Add Dependencies
run yum update -y && \
    yum -y install git wget patch python3 python3-tools python3-pip 2to3 which tar python-ldap && \
    yum -y clean all && \
    pip3 install ldap3 pymongo --no-cache-dir
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
add trytond.conf /etc/trytond.conf
expose 8000
CMD ["./start_gnuhealth.sh"]
