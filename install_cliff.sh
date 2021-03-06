#!/bin/sh
CLIFF_VERSION=2.3.0

sudo apt-get update
echo "Installing basic packages..."
sudo apt-get install -y git
sudo apt-get install -y curl
sudo apt-get install -y vim
sudo apt-get install -y unzip htop

echo "Installing Java and JDK"
sudo apt-get install -y openjdk-8-jre
sudo apt-get install -y openjdk-8-jdk

echo "Configuring Java and things"

set JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64

cd ~
sudo wget https://raw.githubusercontent.com/c4fcm/CLIFF-up/master/bashrc
sudo rm .bashrc
sudo mv bashrc .bashrc
source .bashrc

cd /usr/lib/jvm/
sudo chmod 777 /usr/lib/jvm/java-8-openjdk-amd64

cd /usr/lib/jvm/java-8-openjdk-amd64
sudo chmod 777 -R *

echo "Install Maven"
# Why does stupid Maven install Java 6?
sudo apt-get install -y maven

# tell it again that we do indeed want Java 7
set JRE_HOME=/usr/lib/jvm/java-8-openjdk-amd64

echo 2 | sudo update-alternatives --config java

echo "Download Tomcat"
# Create tomcat user (https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-8-on-ubuntu-14-04)
sudo groupadd tomcat
sudo useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat

# Install tomcat into /opt/tomcat
cd ~
sudo wget http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.59/bin/apache-tomcat-7.0.59.tar.gz
sudo mkdir /opt/tomcat
sudo tar -xvzf apache-tomcat-7.0.59.tar.gz -C /opt/tomcat --strip-components=1
#sudo rm apache-tomcat-7.0.59.tar.gz

# get tomcat users set up correctly
cd /opt/tomcat
sudo chgrp -R tomcat conf
sudo chmod g+rwx conf
sudo chmod g+r conf/*

sudo chown -R tomcat work/ temp/ logs/

sudo rm tomcat-users.xml
sudo wget https://raw.githubusercontent.com/c4fcm/CLIFF-up/master/tomcat-users.xml

echo "Boot Tomcat"
sudo $CATALINA_HOME/bin/startup.sh

echo "Download CLIFF"
cd ~
sudo wget https://github.com/c4fcm/CLIFF/releases/download/v$CLIFF_VERSION/cliff-$CLIFF_VERSION.war
sudo mv ~/cliff-$CLIFF_VERSION.war /opt/tomcat/webapps/

echo "Downloading CLAVIN..."
cd ~
sudo git clone https://github.com/Berico-Technologies/CLAVIN.git
cd CLAVIN
# git checkout 2.0.0
echo "Downloading placenames file from Geonames..."
sudo wget http://download.geonames.org/export/dump/allCountries.zip
sudo unzip allCountries.zip
sudo rm allCountries.zip

echo "Compiling CLAVIN"
sudo mvn compile

echo "Building Lucene index of placenames--this is the slow one"
MAVEN_OPTS="-Xmx4g" mvn exec:java -Dexec.mainClass="com.bericotech.clavin.index.IndexDirectoryBuilder"

sudo mkdir /etc/cliff2
sudo mkdir /opt/CLAVIN
sudo mkdir /opt/CLAVIN/IndexDirectory

sudo chown -R tomcat /opt/CLAVIN/

sudo cp -r IndexDirectory/* /opt/CLAVIN/IndexDirectory
sudo ln -s /opt/CLAVIN/IndexDirectory /etc/cliff2/IndexDirectory

# cd ~
# sudo mkdir .m2
# cd .m2
# sudo rm settings.xml
# sudo wget https://raw.githubusercontent.com/c4fcm/CLIFF-up/master/settings.xml

echo "Move files around and redeploy"
sudo /opt/tomcat/bin/shutdown.sh
sudo /opt/tomcat/bin/startup.sh
echo "Installation Complete"
