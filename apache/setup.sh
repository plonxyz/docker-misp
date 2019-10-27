#!/bin/bash
#MISP installation script

echo "Install dependencies via APT" ;
apt-get update && apt-get install -y  curl gcc git gnupg-agent make python3 openssl sudo vim zip wget  sqlite3 apache2 apache2-doc apache2-utils libapache2-mod-php php php-cli php-gnupg php-dev php-json php-mysql php-opcache php-readline php-redis php-xml php-mbstring rng-tools python3-dev python3-pip python3-yara python3-redis python3-zmq libxml2-dev libxslt1-dev zlib1g-dev python3-setuptools libpq5 libjpeg-dev libfuzzy-dev ruby asciidoctor tesseract-ocr imagemagick
echo "Configuring PHP" ;
sed -i "s/max_execution_time = 30/max_execution_time = 300/" /etc/php/7.2/apache2/php.ini ;
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/7.2/apache2/php.ini ;
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 50M/" /etc/php/7.2/apache2/php.ini ;
sed -i "s/post_max_size = 8M/post_max_size = 50M/" /etc/php/7.2/apache2/php.ini

a2dismod status ;
a2enmod ssl rewrite headers;
a2ensite 000-default ;
a2ensite default-ssl ;
mkdir -p /var/www/MISP /.config /.git


cd /var/www/MISP ;
chown -R www-data:www-data /var/www/MISP /.config /.git;
sudo -u www-data -H git clone https://github.com/MISP/MISP.git /var/www/MISP ;
sudo -u www-data -H git submodule update --init --recursive ;
sudo -u www-data -H git submodule foreach --recursive git config core.filemode false ;
sudo -u www-data -H git config core.filemode false ;
echo ;
sudo pip3 install --upgrade pip ;
cd /var/www/MISP/app/files/scripts ;
sudo -u www-data -H git clone https://github.com/CybOXProject/python-cybox.git ;
sudo -u www-data -H git clone https://github.com/STIXProject/python-stix.git ;
sudo -u www-data -H git clone https://github.com/MAECProject/python-maec.git ;
sudo -u www-data -H git clone https://github.com/CybOXProject/mixbox.git

cd /var/www/MISP/app/files/scripts/mixbox ;
sudo pip3 install .

cd /var/www/MISP/app/files/scripts/python-cybox ;
sudo pip3 install .

cd /var/www/MISP/app/files/scripts/python-stix ;
sudo pip3 install .

cd /var/www/MISP/app/files/scripts/python-maec ;
sudo pip3 install .

cd /var/www/MISP/cti-python-stix2 ;
sudo pip3 install .

cd /var/www/MISP/PyMISP ;
sudo pip3 install . ;
sudo pip3 install git+https://github.com/kbandla/pydeep.git ;
sudo pip3 install https://github.com/lief-project/packages/raw/lief-master-latest/pylief-0.9.0.dev.zip


cd /var/www/MISP ;
sudo -u www-data -H git submodule init ;
sudo -u www-data -H git submodule update ;

 sudo pip3 install jsonschema ;
sudo pip3 install reportlab ;
sudo pip3 install python-magic ;
sudo pip3 install pyzmq ;
sudo pip3 install redis ;

cd /usr/local/src ;
sudo -H git clone https://github.com/MISP/misp-modules.git ;

cd /usr/local/src/misp-modules ;
sudo -H git checkout -b v2.4.104 ;
sudo pip3 install -I -r REQUIREMENTS ;  
sudo pip3 install -I .

# sudo pip uninstall -y cybox

cd /var/www/MISP/app
mkdir /var/www/.composer && chown -R www-data:www-data /var/www/.composer ;
sudo -u www-data -H wget https://getcomposer.org/download/1.2.1/composer.phar -O composer.phar ;
sudo -u www-data -H php composer.phar require kamisama/cake-resque:4.1.2 ;
sudo -u www-data -H php composer.phar config vendor-dir Vendor ;
sudo -u www-data -H php composer.phar install ;
sudo phpenmod redis ;
sudo -u www-data -H cp -fa /var/www/MISP/INSTALL/setup/config.php /var/www/MISP/app/Plugin/CakeResque/Config/config.php ;
sudo chown -R www-data:www-data /var/www/MISP ;
sudo chmod -R 750 /var/www/MISP ;
sudo chmod -R g+ws /var/www/MISP/app/tmp ;
sudo chmod -R g+ws /var/www/MISP/app/files ;
sudo chmod -R g+ws /var/www/MISP/app/files/scripts/tmp ;
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -keyout /etc/ssl/private/misp.key -out /etc/ssl/private/misp.crt -batch ;
echo "<VirtualHost *:8080>" > /etc/apache2/sites-available/000-default.conf ;
echo "ServerName ${MISP_FQDN}" >> /etc/apache2/sites-available/000-default.conf ;
echo "Redirect permanent / https://${MISP_FQDN}:8443" >> /etc/apache2/sites-available/000-default.conf ;
echo "LogLevel warn" >> /etc/apache2/sites-available/000-default.conf ;
echo "ErrorLog /var/log/apache2/misp_error.log" >> /etc/apache2/sites-available/000-default.conf ;
echo "CustomLog /var/log/apache2/misp_access.log combined" >> /etc/apache2/sites-available/000-default.conf ;
echo "ServerSignature Off" >> /etc/apache2/sites-available/000-default.conf ;
echo "</VirtualHost>" >> /etc/apache2/sites-available/000-default.conf ;
echo "<VirtualHost *:4434>" > /etc/apache2/sites-available/default-ssl.conf ;
echo "ServerAdmin ${MISP_EMAIL}" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "ServerName ${MISP_FQDN}" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "DocumentRoot /var/www/MISP/app/webroot" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "<Directory /var/www/MISP/app/webroot>" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "Options -Indexes" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "AllowOverride all" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "</Directory>" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "SSLEngine On" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "SSLCertificateFile /etc/ssl/private/misp.crt" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "SSLCertificateKeyFile /etc/ssl/private/misp.key" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "#SSLCertificateChainFile /etc/ssl/private/misp-chain.crt" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "LogLevel warn" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "ErrorLog /var/log/apache2/misp_ssl_error.log" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "CustomLog /var/log/apache2/misp_ssl_access.log combined" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "ServerSignature Off" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "</VirtualHost>" >> /etc/apache2/sites-available/default-ssl.conf ;
echo "ServerName ${MISP_FQDN}" >> /etc/apache2/apache2.conf ;
sudo -u www-data cp -a /var/www/MISP/app/Config/bootstrap.default.php /var/www/MISP/app/Config/bootstrap.php ;
sudo -u www-data cp -a /var/www/MISP/app/Config/database.default.php /var/www/MISP/app/Config/database.php ;
sudo -u www-data cp -a /var/www/MISP/app/Config/core.default.php /var/www/MISP/app/Config/core.php ;
sudo -u www-data cp -a /var/www/MISP/app/Config/config.default.php /var/www/MISP/app/Config/config.php

sed -i -e 's/db login/misp/g' /var/www/MISP/app/Config/database.php ;
sed -i -e "s/db password/${MYSQL_MISP_PASSWORD}/g" /var/www/MISP/app/Config/database.php ;
sed -i -e "s/localhost/${MYSQL_MISP_SERVER}/g" /var/www/MISP/app/Config/database.php ;
sed -i -E "s/'host'(\s+)=>\s'localhost'/'host' => '${REDIS_MISP_SERVER}'/" /var/www/MISP/app/Plugin/CakeResque/Config/config.php ;
sed -i -E "s/'salt'(\s+)=>\s''/'salt' => '`openssl rand -base64 32 | tr \'/\' \'0\'`'/" /var/www/MISP/app/Config/config.php ;
sed -i -E "s/'baseurl'(\s+)=>\s''/'baseurl' => 'https:\/\/${MISP_FQDN}:4434'/" /var/www/MISP/app/Config/config.php ;
sed -i -e "s/email@address.com/${MISP_EMAIL}/" /var/www/MISP/app/Config/config.php ;
sed -i -e "s/bind 127.0.0.1 ::1/bind 0.0.0.0/" /etc/redis/redis.conf ;
sed -i -e 's/Listen 80/Listen 8080/g' /etc/apache2/ports.conf ;
sed -i -e 's/Listen 443/Listen 4434/g' /etc/apache2/ports.conf ;
sudo chown -R www-data:www-data /var/www/MISP/app/Config ;
sudo chmod -R 750 /var/www/MISP/app/Config ;
sudo -u www-data -H wget http://downloads.sourceforge.net/project/ssdeep/ssdeep-2.13/ssdeep-2.13.tar.gz ;
tar zxvf ssdeep-2.13.tar.gz && cd ssdeep-2.13 && ./configure && make && sudo make install ;
sudo pecl install ssdeep ;
useradd appuser ;
sudo echo "extension=ssdeep.so" > /etc/php/7.2/mods-available/ssdeep.ini ;
sudo phpenmod ssdeep ;
sudo -u www-data -H mkdir /var/www/MISP/.gnupg ;
chmod 700 /var/www/MISP/.gnupg ;
echo "Key-Type: 1" > /tmp/config_gpg ;
echo "Key-Length: 4096" >> /tmp/config_gpg ;
echo "Subkey-Type: 1" >> /tmp/config_gpg ;
echo "Subkey-Length: 4096" >> /tmp/config_gpg ;
echo "Name-Real: MISP" >> /tmp/config_gpg ;
echo "Name-Email: $MISP_EMAIL" >> /tmp/config_gpg ;
echo "Expire-Date: 0" >> /tmp/config_gpg ;
#echo "%no-protection" >> /tmp/config_gpg ;
echo "Passphrase: $MISP_GPG_PASSWORD" >> /tmp/config_gpg ;
chmod 700 /tmp/config_gpg ;
sudo rm -f /dev/random ;
sudo mknod -m 0666 /dev/random c 1 9 ;
#sudo echo RNGDOPTIONS="--random-device /dev/urandom --rng-device /dev/urandom" | sudo tee /etc/default/rng-tools ;
sudo echo HRNGDEVICE=/dev/urandom | sudo tee -a /etc/default/rng-tools ;
sudo /etc/init.d/rng-tools restart ;
sudo rngd -f -r /dev/urandom ;
chown www-data /tmp/config_gpg ;
sudo -u www-data sh -c "gpg --batch --homedir /var/www/MISP/.gnupg --gen-key /tmp/config_gpg" ;
sudo -u www-data sh -c "gpg --homedir /var/www/MISP/.gnupg --export --armor $MISP_EMAIL > /var/www/MISP/app/webroot/gpg.asc" ;
sudo /etc/init.d/rng-tools stop ;
sudo apt-get remove --purge -y rng-tools ;\
usermod -aG ssl-cert www-data ;
usermod -aG www-data appuser ;
chown www-data:www-data /var/log/apache2 ;
chown www-data:www-data /var/log/apache2/*.log ;
chown www-data:ssl-cert /etc/ssl/private/misp.* 