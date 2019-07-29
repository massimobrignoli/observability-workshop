#!/bin/bash
# INSTALL DEPENDENCIES
sudo yum install epel* -y && sudo yum install java-1.8* nano vim git net-tools -y && sudo yum update -y
sudo yum install wget -y
sudo yum install unzip -y
# INSTALL ELASTIC REPO & DOWNLOAD METRIC & FILEBEAT
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
sudo touch /etc/yum.repos.d/elasticsearch.repo
echo "[elasticsearch-7.x]" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "name=Elasticsearch repository for 7.x packages" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "baseurl=https://artifacts.elastic.co/packages/7.x/yum" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgcheck=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "enabled=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "autorefresh=1" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
echo "type=rpm-md" | sudo tee -a /etc/yum.repos.d/elasticsearch.repo
sudo yum install metricbeat filebeat -y
#
# DOWNLOAD THE MASTER BRANCH
wget -O /home/centos/master.zip https://github.com/bvader/spring-petclinic/archive/master.zip
#
# UNZIP THE FILE
unzip /home/centos/master.zip -d /home/centos
#
# DOWNLOAD APM AGENT
wget -O elastic-apm-agent-1.6.0.jar https://search.maven.org/remotecontent?filepath=co/elastic/apm/elastic-apm-agent/1.6.0/elastic-apm-agent-1.6.0.jar
#
# GIT TEST APP & COMPILE
git clone https://github.com/spring-projects/spring-petclinic.git
cd /home/centos/observability-workshop/spring-petclinic
bash /home/centos/observability-workshop/spring-petclinic/mvnw package
#
# IT TAKES A WHILE
#
# COPY THE TARGET FOLDER TO THE MASTER BRANCH
#
cp -r /home/centos/spring-petclinic/target /home/centos/spring-petclinic-master/
#
# DISABLE FIREWALL
sudo service firewalld stop
#
# DOWNLOAD NGINX ZIP, CREATE VAR FOLDER, UNZIP
wget -O nginx.zip https://www.dropbox.com/s/wkh1zm5naiat2np/nginx.zip?dl=0
sudo mkdir /var/log/nginx
sudo unzip nginx.zip -d /var/log/nginx/
#
# 
exit
