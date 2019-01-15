from amazonlinux:latest
ENV TERM=xterm-256color

#Add Dependencies
run yum update -y
run yum -y install git wget nano patch python3 python3-tools python3-pip 2to3 which tar python-ldap 
run pip3 install ldap3 pymongo
#Add GNUHealth User
run useradd -m -d /home/gnuhealth gnuhealth
#Make Python3 Default python binary
run rm /usr/bin/python
run ln -si /usr/bin/python3 /usr/bin/python
#Switch to GNUHealth User
USER gnuhealth
ENV HOME /home/gnuhealth
workdir /home/gnuhealth
#Get & Install GNUHealth
run wget https://ftp.gnu.org/gnu/health/gnuhealth-latest.tar.gz
run mkdir $HOME/gnuhealth-latest
run tar xzf gnuhealth-latest.tar.gz -C gnuhealth-latest --strip-components=1
workdir $HOME/gnuhealth-latest
run ls $HOME/gnuhealth-latest
run $HOME/gnuhealth-latest/gnuhealth-setup install
run /bin/bash -c "source $HOME/.gnuhealthrc"
add trytond.conf /etc/trytond.conf
run ls $HOME/gnuhealth/tryton/server/
expose 8000

CMD ["./start_gnuhealth.sh"]
