#!/bin/ksh

set -e
_TMP=$(mktemp -d -p /tmp installruby.XXXXXXXXXX)
trap "rm -rf ${_TMP}; exit 1" 2 3 9 13 15 ERR

# Change file /etc/login.conf
_changelogin(){
cat <<'EOF'>>/etc/login.conf
mysqld:\
        :openfiles-cur=1024:\
        :openfiles-max=2048:\
        :tc=daemon:
EOF
}

# Add OpenBSD packages
pkg_add ruby%2.3 libiconv node mariadb-server nginx-- cmake

# Add links
pkg_info -M ruby python | grep '^ ln' | sed 's/ //' > ${_TMP}/run.sh
/bin/sh ${_TMP}/run.sh

# Install the last version of Rails
/usr/local/bin/gem install rails --no-ri --no-rdoc

# Add links
ln -sf /usr/local/bin/rails23 /usr/local/bin/rails
ln -sf /usr/local/bin/bundle23 /usr/local/bin/bundle
ln -sf /usr/local/bin/bundler23 /usr/local/bin/bundler

# Set mariadb-mysql
/usr/local/bin/mysql_install_db > /dev/null 2>&1

if (! grep '^mysqld\:' /etc/login.conf > /dev/null 2>&1); then
        _changelogin
        /usr/bin/cap_mkdb /etc/login.conf
fi

/usr/sbin/rcctl enable mysqld
/usr/sbin/rcctl start mysqld

# Set NginX
mv /etc/nginx/nginx.conf /etc/examples
install -m 0644 ./nginx/nginx.conf /etc/nginx
/usr/sbin/rcctl enable nginx
/usr/sbin/rcctl set nginx flags -u
/usr/sbin/rcctl start nginx

# Set a sample, and run rails in daemon mode
(cd /var/www/htdocs && rails new sample -d mysql)

mysql -u root -e 'create database sample_test;'
mysql -u root -e 'create database sample_development;'
mysql -u root -e "grant all privileges on sample_test.* to '_rails'@'localhost' identified by 'demo'"
mysql -u root -e "grant all privileges on sample_development.* to '_rails'@'localhost' identified by 'demo'"

sed -e '16s/root$/_rails/' -e '17s/  password:/  password: demo/' /var/www/htdocs/sample/config/database.yml > ${_TMP}/database.yml
rm /var/www/htdocs/sample/config/database.yml
cp ${_TMP}/database.yml /var/www/htdocs/sample/config

(cd /var/www/htdocs/sample && rails server -d)

# Clear temp files
rm -rf ${_TMP}
