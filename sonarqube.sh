#!/bin/bash

####################################################################################
# @package sonarqube 4.2 server initialize
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
sudo yum update -y
rpm -Uvh http://mirror.webtatic.com/yum/el6/latest.rpm

####################################################################################
# Install Apache
####################################################################################

if ! rpm -qa | grep -qw httpd; then

    #install httpd
    sudo yum install -y httpd 
    
    chkconfig httpd on
    
    #edit httpd.conf
    grep -l '#ServerName www.example.com:80' /etc/httpd/conf/httpd.conf | xargs sed -e 's/#ServerName www.example.com:80/ServerName localhost/' -i
    grep -l 'AllowOverride None' /etc/httpd/conf/httpd.conf | xargs sed -e 's/AllowOverride None/AllowOverride All/g' -i
    
    #remove empty lines
    sed -i '/^$/d' /etc/httpd/conf/httpd.conf
    
    #turn on httpd
    service httpd start
    
    echo "httpd installed."
fi


####################################################################################
# Install wget
####################################################################################

if ! rpm -qa | grep -qw wget; then
    # install wget
    sudo yum install -y wget 
    echo "wget installed."
fi

####################################################################################
# Install "Development Tools"
####################################################################################

if ! rpm -qa | grep -qw java-1.7.0-openjdk.x86_64; then

    sudo yum groupinstall -y "Development Tools" 
    
    echo "Development Tools installed."
fi


####################################################################################
# Install Java
####################################################################################

if ! rpm -qa | grep -qw java-1.7.0-openjdk.x86_64; then

    # install java-1.7.0-openjdk.x86_64
    sudo yum install -y java-1.7.0-openjdk.x86_64 
    
    # Define The JAVA_HOME environment variable
    echo "export JAVA_HOME=/usr/lib/jvm/jre-1.7.0-openjdk.x86_64" >> /root/.bash_profile
    
    echo "java-1.7.0-openjdk.x86_64 installed."
fi


####################################################################################
# Install gcc
####################################################################################

if ! rpm -qa | grep -qw gcc; then
    sudo yum install -y gcc 
    echo "gcc installed."
fi

####################################################################################
# Install gcc-c++
####################################################################################

if ! rpm -qa | grep -qw gcc-c++; then
    sudo yum install -y gcc-c++ 
    echo "gcc-c++ installed."
fi

####################################################################################
# Install autoconf
####################################################################################

if ! rpm -qa | grep -qw autoconf; then
    sudo yum install -y autoconf 
    echo "autoconf installed."
fi

####################################################################################
# Install automake
####################################################################################

if ! rpm -qa | grep -qw automake; then
    sudo yum install -y automake 
    echo "automake installed."
fi

####################################################################################
# Install make
####################################################################################

if ! rpm -qa | grep -qw make; then
    sudo yum install -y make 
    echo "make installed."
fi

####################################################################################
# Install php55w
####################################################################################

if ! rpm -qa | grep -qw php55w; then
    sudo yum install -y php55w 
    echo "php55w installed."
fi

####################################################################################
# Install php55w-opcache
####################################################################################

if ! rpm -qa | grep -qw php55w-opcache; then
    sudo yum install -y php55w-opcache 
    echo "php55w-opcache installed."
fi

####################################################################################
# Install php55w-common
####################################################################################

if ! rpm -qa | grep -qw php55w-common; then
    sudo yum install -y php55w-common 
    echo "php55w-common installed."
fi

####################################################################################
# Install php55w-mysql
####################################################################################

if ! rpm -qa | grep -qw php55w-mysql; then
    sudo yum install -y php55w-mysql 
    echo "php55w-mysql installed."
fi

####################################################################################
# Install php55w-pecl-memcache
####################################################################################

if ! rpm -qa | grep -qw php55w-pecl-memcache; then
    sudo yum install -y php55w-pecl-memcache 
    echo "php55w-pecl-memcache installed."
fi

####################################################################################
# Install php55w-devel
####################################################################################

if ! rpm -qa | grep -qw php55w-devel; then
    sudo yum install -y php55w-devel 
    echo "php55w-devel installed."
fi

####################################################################################
# Install php55w-xml
####################################################################################

if ! rpm -qa | grep -qw php55w-xml; then
    sudo yum install -y php55w-xml 
    echo "php55w-xml installed."
fi

####################################################################################
# Install php55w-pear
####################################################################################

if ! rpm -qa | grep -qw php55w-pear; then
    sudo yum install -y php55w-pear 
    echo "php55w-pear installed."
fi


####################################################################################
# Install phalcon
####################################################################################

if [ ! -f /usr/lib64/php/modules/phalcon.so ]; then

    ################################################################################
    # Install git-core
    ################################################################################
    
    if ! rpm -qa | grep -qw git-core; then
        sudo yum install -y git-core 
        echo "git installed."
    fi

    git clone git://github.com/phalcon/cphalcon.git
    cd cphalcon/build
    sudo ./install 
    if [ ! -L /etc/php.d/phalcon.ini ]
    then
        rm -f -r /etc/php.d/phalcon.ini
        echo "; Enable phalcon extension module" >> /etc/php.d/phalcon.ini 
        echo "extension=phalcon.so" >> /etc/php.d/phalcon.ini 
        echo 'date.timezone = "Europe/Istanbul"' >> /etc/php.d/phalcon.ini 
    fi
    cd /
    echo "phalcon installed."
fi



####################################################################################
# Install mysql55
####################################################################################

if ! rpm -qa | grep -qw mysql55w; then
    sudo yum remove -y mysql mysql-* 
    sudo yum install -y mysql55w 
    echo "mysql55w installed."
fi

####################################################################################
# Install mysql55-server
####################################################################################

if ! rpm -qa | grep -qw mysql55w-server; then
    sudo yum install -y mysql55w-server 
    echo "mysql55w-server installed."
fi

####################################################################################
# Install php55w-mysql
####################################################################################

if ! rpm -qa | grep -qw php55w-mysql; then
	sudo yum install -y php55w-mysql 
	chkconfig --levels 235 mysqld on
	#turn on mysqld
	service mysqld start
    
	####################################################################################
	# Install expect
	####################################################################################

	if ! rpm -qa | grep -qw expect; then
		sudo yum install -y expect
		echo "expect installed."
	fi

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
CREATE USER 'sonar' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON sonar.* TO 'sonar'@'localhost' IDENTIFIED BY '${password}';
FLUSH PRIVILEGES;
EOF
	
	service mysqld restart

    echo "php55w-mysql installed."
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
# Install Sonar Last Version
####################################################################################

sudo wget -O /etc/yum.repos.d/sonar.repo http://downloads.sourceforge.net/project/sonar-pkg/rpm/sonar.repo
yum install -y sonar

chkconfig --add sonar

cp  /opt/sonar/conf/sonar.properties  /opt/sonar/conf/sonar.properties.bak
rm -rf /opt/sonar/conf/sonar.properties

echo 'sonar.jdbc.username:                       sonar' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.password:                       '${password} >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.url:                            jdbc:mysql://localhost:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.maxIdle:                        5' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.minIdle:                        2' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.maxWait:                        5000' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.minEvictableIdleTimeMillis:     600000' >> /opt/sonar/conf/sonar.properties
echo 'sonar.jdbc.timeBetweenEvictionRunsMillis:  30000' >> /opt/sonar/conf/sonar.properties
echo 'sonar.notifications.delay=60' >> /opt/sonar/conf/sonar.properties


mv /etc/localtime /etc/localtime.bak
ln -s /usr/share/zoneinfo/Asia/Istanbul /etc/localtime
yum install -y ntp
sudo ntpdate -b pool.ntp.org
sudo service ntpd start

service sonar start

source ~/.bash_profile
source ~/.bashrc
