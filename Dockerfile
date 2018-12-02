from amazonlinux:latest
add requires /tmp/
run yum install -y sudo which wget tar mercurial shadow-utils
run sudo yum install -y patch gcc libxml2-devel libxslt-devel libjpeg8-devel python3-tools python3-pip python3-ldap unoconv 
run mkdir -p /etc/mercurial/
run which pip3.7
run echo "[extensions]\nhgnested =" > /etc/mercurial/hgrc
run mkdir /tmp/gnuhealth
workdir /tmp/gnuhealth/

#Download latest stable version of GNUHealth from Savannah Mercurial Website.
run hg clone http://hg.savannah.gnu.org/hgweb/health -r  stable 
workdir /tmp/gnuhealth/health/tryton
run adduser -m -d /opt/gnuhealth gnuhealth
run ln -sf /usr/bin/python3.7 /usr/bin/python3
run ln -sf /usr/bin/python3 /usr/bin/python
run ln -sf /usr/bin/pip3.7 /usr/bin/pip
run ln -sf /usr/bin/2to3-3.7 /usr/bin/2to3
run which pip3.7
USER gnuhealth
ENV HOME /opt/gnuhealth

#run alias 2to3="/usr/bin/2to3-3.7"
run ./gnuhealth-setup install
#USER root
#run rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
#ADD gnuhealth.service /usr/lib/systemd/system/gnuhealth.service
add trytond.conf /etc/trytond.conf
#ADD gnuhealthd /usr/local/bin/gnuhealthd

#RUN ln -s /opt/gnuhealth/gnuhealth/tryton/server/trytond-3.*/bin/trytond /usr/local/bin/
expose 8000
CMD ["/opt/gnuhealth/start_gnuhealth.sh"]
