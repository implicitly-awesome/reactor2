#! /bin/bash

set -e

DEPLOY_PATH=$1
USER=$2

sudo apt-get -y update
sudo apt-get install build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev curl git-core python-software-properties libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev autoconf libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
sudo mkdir -p /home/ubuntu/apps/reactor
sudo chown -R ubuntu:ubuntu /home/ubuntu/apps/reactor
echo 'gem: --no-ri --no-rdoc'  >> ~/.gemrc

curl -L https://get.rvm.io | bash -s stable --ruby
source /home/ubuntu/.rvm/scripts/rvm
type rvm | head -1
rvm install 1.9.3-p392
rvm 1.9.3-p392

gem install bundler
gem install passenger -v 3.0.19
rvmsudo passenger-install-nginx-module --auto --auto-download --prefix=/opt/nginx

sudo wget -O init-deb.sh http://library.linode.com/assets/660-init-deb.sh
sudo mv init-deb.sh /etc/init.d/nginx
sudo chmod +x /etc/init.d/nginx
sudo /usr/sbin/update-rc.d -f nginx defaults
#vi /home/ubuntu/apps/reactor/htpasswd
#printf "reactor:$(openssl passwd -1 BamBIGaY)\n" >> /home/ubuntu/apps/reactor/htpasswd
#chown root:nobody /home/ubuntu/apps/reactor/htpasswd
#chmod 640 /home/ubuntu/apps/reactor/htpasswd
sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start

sudo apt-add-repository ppa:chris-lea/node.js
sudo apt-get -y update
sudo apt-get -y install nodejs

sudo apt-get install freetds-dev freetds-bin unixodbc-dev tdsodbc

cd ~/.ssh
ssh-keygen -t rsa -C "andrei.chernykh@gmail.com"
#sudo chmod 700 ~/.ssh
vi ~/.ssh/id_rsa.pub
ssh -vT git@github.com