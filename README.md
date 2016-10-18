# Execute Rails applications on OpenBSD

Tested on OpenBSD 6.0.

This will install :

- Ruby 2.3.1
- Mariadb server
- NginX
- Rails 5.0.0.1

With a sample app located in /var/www/htdocs/sample.

## Installation

>**From a fresh OpenBSD install...**

#### Get git

    echo installpath=ftp2.fr.openbsd.org > /etc/pkg.conf
    pkg_add git

#### Fetch the project

    cd 
    git clone https://github.com/wesley974/railsonopenbsd
    
#### Install the GUI

>**Don't forget to tune your hosts file and verify your hostname!**

    cd railsonopenbsd
    sh installrails.sh



>Browse now http://YOUR_IP_ADDRESS and *Enjoy!*

Use at your own risk. No one will help you.
