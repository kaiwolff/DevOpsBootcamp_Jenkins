#!/bin/bash

#start with updating
sudo apt-get update -y
sudo apt-get upgrade -y
#install all requirements

#nginx for the web server
sudo apt-get install nginx -y

#nodejs (and prerequisite python software properties)
sudo apt-get install python-software-properties -y
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install nodejs -y

#not using pm2 at the moment
#sudo npm install pm2 -g
sudo apt-get upgrade -y

#should now have all prerequisites installed, time to change directory to the app directory and run the npm commands to install and run the app
#add new environment variable to bashrc and run source to reload it

sudo echo 'export DB_HOST="mongodb://52.48.235.46:27017/posts"' >> ~/.bashrc
source ~/.bashrc

#replace default of nginx. this hsoudl have been provisioned into /home/environment by Vagrant
sudo rm /etc/nginx/sites-available/default
sudo cp ~/DevOpsBootcamp_Jenkins/default /etc/nginx/sites-available/default
echo "restarting nginx"
sudo service nginx restart
sudo systemctl enable nginx

echo "Attempting npm install steps"
cd ~/DevOpsBootcamp_Jenkins/app
sudo apt-get install npm -y
sudo npm install
sudo npm install express
echo "npm install run successfully"
node ~/DevOpsBootcamp_Jenkins/app/seeds/seed.js

#seed the database


#at this point, should be able to simply run the app by sshing in and entering the npm command.

#not sure how to make this run so commented out for now
#(npm run start&) 

