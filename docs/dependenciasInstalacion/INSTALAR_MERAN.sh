#!/bin/bash
#obtener el código fuente
apt-get install git-core
cd /usr/share/
git clone ssh://root@proyectos.linti.unlp.edu.ar/var/meran
cd /usr/share/meran/docs/dependenciasInstalacion/
#Configurar apache
cp ../configuracion/apache/* /etc/apache2/sites-availables
a2ensite opac
a2ensite ssl
#Instalar dependencias
sh dependenciasKOHA.sh
#Configurar Meran
mkdir /etc/meran
cp ../configuracion/koha/koha.conf /etc/meran
chown -R +r /etc/meran/koha.conf
#
apt-get install apache2 apache2-mpm-worker apache2-utils apache2.2-bin apache2.2-common bzip2 fontconfig-config libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libapache-db-perl libapache2-mod-perl2 libapache2-reload-perl libappconfig-perl libapr1 libaprutil1 libaprutil1-dbd-sqlite3 libaprutil1-ldap libapt-pkg-perl libarchive-zip-perl libbit-vector-perl libbsd-resource-perl libcarp-clan-perl libchart-perl libclass-singleton-perl libconvert-asn1-perl  libcrypt-cbc-perl libcrypt-rijndael-perl libcrypt-ssleay-perl libdate-calc-perl libdate-manip-perl  libdatetime-locale-perl libdatetime-perl libdatetime-timezone-perl libdbd-mysql-perl libdbi-perl libdevel-symdump-perl  libdigest-sha-perl libdpkg-perl libextutils-parsexs-perl libfont-afm-perl libfont-freetype-perl libfontconfig1  libgd-gd2-perl libgd2-xpm libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-template-expr-perl  libhtml-template-perl libhtml-tree-perl libicu44 libio-socket-ssl-perl libio-stringy-perl libipc-shareable-perl  libjpeg62 liblist-moreutils-perl liblog-dispatch-perl liblog-log4perl-perl libmail-sendmail-perl libmailtools-perl  libmarc-record-perl libmysqlclient16 libnet-amazon-perl libnet-daemon-perl libnet-ldap-perl libnet-libidn-perl  libnet-smtp-ssl-perl libnet-ssleay-perl libnet-z3950-zoom-perl libole-storage-lite-perl libooolib-perl  libparams-validate-perl libparse-recdescent-perl libpdf-api2-perl libpdf-report-perl libperl5.10 libplrpc-perl  libpng12-0 libspreadsheet-writeexcel-perl libsys-hostname-long-perl libtemplate-perl libtext-aspell-perl  libtext-roman-perl libtimedate-perl liburi-perl libwww-perl libxapian22 libxml-namespacesupport-perl libxml-parser-perl  libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libxpm4 libxslt1.1 libyaml-syck-perl libyaz4 mysql-common ssl-cert ttf-dejavu ttf-dejavu-core ttf-dejavu-extra
apt-get install libtext-levenshtein-perl libsphinx-search-perl libcgi-session-perl libnet-smtp-tls-perl libnet-ssleay-perl libnet-twitter-perl libwww-facebook-api-perl  libwww-shorten-perl 

#Crear la bdd

#Configurar meran
#Reiniciar apache 
