#!/bin/bash
#finish installing php, linux and configuring permission
sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
sudo yum install -y httpd mariadb-server
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl is-enabled httpd
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl start mariadb
#sudo mysql_secure_installation
sudo systemctl enable mariadb
sudo yum install php-mbstring -y
sudo yum install php-xml -y
sudo systemctl restart httpd
sudo systemctl restart php-fpm
####DOWNLOAD PHPMYADMIN #####
cd /var/www/html
wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
mkdir phpMyAdmin && tar -xvzf phpMyAdmin-latest-all-languages.tar.gz -C phpMyAdmin --strip-components 1
rm phpMyAdmin-latest-all-languages.tar.gz
#WEBSITE LOCATION
#aws s3 cp s3://owonikokoadventureswp /var/www/html --recursive
sudo yum install git -y
git clone https://github.com/stackitgit/CliXX_Retail_Repository.git
cp -r CliXX_Retail_Repository/* /var/www/html 
#START MARIADB
sudo chkconfig httpd on
sudo systemctl status httpd
#####CONFIGURE CLIXX####
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
#cp -r wordpress/* /var/www/html/
###CREATE CLIXX DATABASE AND USER#
sudo sed -i 's/database_name_here/${DB_NAME}/' /var/www/html/wp-config.php
sudo sed -i 's/username_here/${USERNAME}/' /var/www/html/wp-config.php
sudo sed -i 's/password_here/${DB_PASSWORD}/' /var/www/html/wp-config.php
sudo sed -i 's/localhost/${RDS_ENDPOINT}/' /var/www/html/wp-config.php
## ALLOW WORDPRESS TO USE PERMALINKS###
sudo sed -i '151s/None/All/' /etc/httpd/conf/httpd.conf
###CHANGE OWNERSHIP FOR APACHE AND RESTART SERVICES###
sudo chown -R apache /var/www
sudo chgrp -R apache /var/www
sudo chmod 2775 /var/www
find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
sudo systemctl restart httpd
sudo systemctl enable httpd && sudo systemctl enable mariadb
sudo systemctl status mariadb
sudo systemctl start mariadb
sudo systemctl status httpd
sudo systemctl start httpd
###UPDATE WORDPRESS URL TO LATEST INSTANCE IP ADDRESS###
mysql -h${RDS_ENDPOINT} -D${DB_NAME} -u${USERNAME} -p${DB_PASSWORD} <<EOT
UPDATE wp_options SET option_value = "http://${APP_LB}" WHERE option_value LIKE 'http%';
use ${DB_NAME};
commit;
EOT
EOF
sudo systemctl restart httpd
sudo systemctl enable httpd
sudo chmod 755 /home/ec2-user/postinstall.sh
sudo /home/ec2-user/postinstall.sh
