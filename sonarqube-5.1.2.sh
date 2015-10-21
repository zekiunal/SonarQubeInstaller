#!/bin/bash

####################################################################################
# @package sonarqube 3.7 server initialize
# @author Zeki Unal <zekiunal@gmail.com>
# @name ssonarqube37.sh
####################################################################################

if [ ! $1 ]; then
	echo 'mysql password is required (.\sonarqube37.sh passwordhere)'
	exit 1;
else
	password=$1
fi;

####################################################################################
# Update CentOS
####################################################################################
yum update -y
yum -y install deltarpm epel-release
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh http://mirror.yandex.ru/fedora/russianfedora/russianfedora/free/el/releases/7/Everything/x86_64/os/re2c-0.13.5-7.el7.R.x86_64.rpm
yum update -y
yum -y install wget unzip
yum install -y java-1.7.0-openjdk.x86_64 expect gcc-c++ autoconf automake re2c httpd php56w php56w-opcache php56w-common php56w-mysql php56w-pecl-memcache php56w-devel gcc libtool make git-core gd gd-devel php56w-gd mariadb mariadb-server
 
echo "export JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64" >> /root/.bash_profile
####################################################################################
# Install Apache
####################################################################################

grep -l '#ServerName www.example.com:80' /etc/httpd/conf/httpd.conf | xargs sed -e 's/#ServerName www.example.com:80/ServerName localhost/' -i
grep -l '#NameVirtualHost \*:80' /etc/httpd/conf/httpd.conf | xargs sed -e 's/#NameVirtualHost \*:80/NameVirtualHost \*:80/g' -i
grep -l 'AllowOverride None' /etc/httpd/conf/httpd.conf | xargs sed -e 's/AllowOverride None/AllowOverride All/g' -i


#remove empty lines
sed -i '/^$/d' /etc/httpd/conf/httpd.conf

systemctl enable mariadb.service
systemctl start mariadb.service

systemctl enable httpd.service
systemctl start httpd.service

git clone git://github.com/phalcon/cphalcon.git
cd cphalcon/build
sudo ./install 
echo "; Enable phalcon extension module" >> /etc/php.d/phalcon.ini 
echo "extension=phalcon.so" >> /etc/php.d/phalcon.ini 
echo 'date.timezone = "Europe/Istanbul"' >> /etc/php.d/phalcon.ini 

systemctl restart httpd.service        


	####################################################################################
	# MySQL Secure Installation
	####################################################################################
	# enforce password as parameter
	

	# automatically call mysql_secure_installation
	expect -c "
	spawn mysql_secure_installation
	set password [lindex $argv 0]
	 
	expect \"Enter current password for root (enter for none):\"
	send \"\r\"
	expect \"Set root password?\"
	send \"y\r\"
	expect \"New password:\"
	send \"$password\r\"
	expect \"Re-enter new password:\"
	send \"$password\r\"
	expect \"Remove anonymous users?\"
	send \"y\r\"
	expect \"Disallow root login remotely?\"
	send \"n\r\"
	expect \"Remove test database and access to it?\"
	send \"y\r\"
	expect \"Reload privilege tables now?\"
	send \"y\r\"
	puts \"Ended expect script.\"
	"
	# create .ran file indicating mysql was secured
	touch `which mysql_secure_installation`.ran

mysql -u root -p${password} << EOF
use mysql;
DELETE FROM mysql.user WHERE User = 'root' AND Host = '%';
GRANT ALL PRIVILEGES ON *.* TO "root"@"%" IDENTIFIED BY "${password}";
FLUSH PRIVILEGES;
CREATE DATABASE sonar;
CREATE USER 'sonar' IDENTIFIED BY 'sonar';
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'%' IDENTIFIED BY 'sonar';
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY 'sonar';
FLUSH PRIVILEGES;
EOF
	
	service mysqld restart

fi

####################################################################################
# Install xdebug
####################################################################################

if [ ! -L /etc/php.d/xdebug.ini ]
    then
    	git clone git://github.com/xdebug/xdebug.git
	cd xdebug
	phpize
	./configure --enable-xdebug
	make
	cp /xdebug/modules/xdebug.so /usr/lib64/php/modules/xdebug.so
        rm -f -r /etc/php.d/xdebug.ini
        echo 'zend_extension=/usr/lib64/php/modules/xdebug.so' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.auto_trace = "Off"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.collect_params = "On"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.collect_return = "Off"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.trace_format = "0"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.trace_options = "1"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.trace_output_dir = "/local/tmp/xdebug"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.trace_output_name = "timestamp"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.profiler_enable = "0"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.auto_profile = "1"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.auto_profile_mode = "6"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.output_dir = "/local/tmp/xdebug"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.profiler_output_dir = "/local/tmp/xdebug"' >> /etc/php.d/xdebug.ini 
        echo 'xdebug.profiler_output_name = "timestamp"' >> /etc/php.d/xdebug.ini 
        cd /
        rm -fr xdebug
fi

####################################################################################
# Update pear
####################################################################################
pear channel-update pear.php.net
pear upgrade-all

####################################################################################
# Install PHPUnit
# The PHP Unit Testing framework. http://phpunit.de/
####################################################################################
pear config-set auto_discover 1
pear channel-discover pear.phpunit.de
pear channel-discover pear.symfony-project.com
pear install pear.phpunit.de/PHPUnit

####################################################################################
# Install PHP Mess Detector
# PHPMD is a spin-off project of PHP Depend and aims to be a PHP equivalent of the 
# well known Java tool PMD. PHPMD can be seen as an user friendly frontend 
# application for the raw metrics stream measured by PHP Depend. http://phpmd.org
#
# Install PHP Depend
# This tool shows you the quality of your design in the terms of extensibility, 
# reusability and maintainability. http://pdepend.org
####################################################################################
wget wget http://sourceforge.net/projects/re2c/files/re2c/0.13.5/re2c-0.13.5.tar.gz
tar zxf re2c-0.13.5.tar.gz && cd re2c-0.13.5
./configure
make && make install
cd /
rm -fr re2c-0.13.5
rm -rf re2c-0.13.5.tar.gz

yum install -y ImageMagick
yum install -y ImageMagick-devel
printf "\n" | pecl install imagick

rm -f -r /etc/php.d/imagick.ini
echo "extension=imagick.so" >> /etc/php.d/imagick.ini 

pear channel-discover pear.phpmd.org
pear remote-list -c phpmd
pear install --alldeps phpmd/PHP_PMD-1.5.0

####################################################################################
# Install PHP CodeSniffer
# PHP_CodeSniffer is a PHP5 script that tokenises and "sniffs" PHP, JavaScript and 
# CSS files to detect violations of a defined coding standard. It is an essential 
# development tool that ensures your code remains clean and consistent. It can also 
# help prevent some common semantic errors made by developers.
####################################################################################

pear install PHP_CodeSniffer

####################################################################################
# Install PHPLOC
# phploc is a tool for quickly measuring the size and analyzing the structure of a 
# PHP project.
####################################################################################

pear channel-discover components.ez.no  
pear install phpunit/phploc

####################################################################################
# Restart Httpd
####################################################################################
service httpd restart


####################################################################################
# Install Maven 3.2.1 Install
####################################################################################
# Download Maven
wget http://ftp.itu.edu.tr/Mirror/Apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz
# Unzip 
tar -zxvf apache-maven-3.2.1-bin.tar.gz
# Rename and move folder to /user/local
mv apache-maven-3.2.1 /usr/local/maven
echo "export M2_HOME=/usr/local/maven" >> /root/.bashrc
echo "export PATH=\${M2_HOME}/bin:\${PATH}" >> /root/.bashrc


####################################################################################
# Install Sonar 3.7 Install
####################################################################################
if [ ! -L /etc/init.d/sonar ]
    then
    	wget http://dist.sonar.codehaus.org/sonar-3.7.4.zip
	unzip sonar-3.7.4.zip
	rm -f sonar-3.7.4.zip
	mv sonar-3.7.4 /usr/local
	ln -s /usr/local/sonar-3.7.4/ /usr/local/sonar
	cp /usr/local/sonar/bin/linux-x86-64/sonar.sh /etc/init.d/sonar
	
	sed -i "2i SONAR_HOME=/usr/local/sonar/" /etc/init.d/sonar
	sed -i "3i PLATFORM=linux-x86-64" /etc/init.d/sonar

	sed -i 's/WRAPPER_CMD=".\/wrapper"/WRAPPER_CMD="\${SONAR_HOME}\/bin\/\${PLATFORM}\/wrapper"/g' /etc/init.d/sonar
	sed -i 's/WRAPPER_CONF="..\/..\/conf\/wrapper.conf"/WRAPPER_CONF="\${SONAR_HOME}\/conf\/wrapper.conf"/g' /etc/init.d/sonar
	sed -i 's/PIDDIR="."/PIDDIR="\/var\/run"/g' /etc/init.d/sonar
	

	chkconfig --add sonar
	
	cp  /usr/local/sonar/conf/sonar.properties  /usr/local/sonar/conf/sonar.properties.bak
	rm -rf /usr/local/sonar/conf/sonar.properties
	
	echo 'sonar.jdbc.username:                       sonar' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.password:                       sonar' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.url:                            jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.maxActive:                      20' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.maxIdle:                        5' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.minIdle:                        2' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.maxWait:                        5000' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.minEvictableIdleTimeMillis:     600000' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.jdbc.timeBetweenEvictionRunsMillis:  30000' >> /usr/local/sonar/conf/sonar.properties
	echo 'sonar.notifications.delay=60' >> /usr/local/sonar/conf/sonar.properties
	
	service sonar start
fi

source ~/.bash_profile
source ~/.bashrc