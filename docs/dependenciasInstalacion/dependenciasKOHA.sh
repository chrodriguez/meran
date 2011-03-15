#/bin/bash
apt-get update -y
apt-get install apache2 mysql-server libpdf-report-perl libhtml-template-expr-perl  libhtml-template-perl libnet-ldap-perl libdbd-mysql-perl libmail-sendmail-perl libmarc-record-perl libgd-gd2-perl libarchive-zip-perl libapache2-mod-perl2 libapache-db-perl libooolib-perl libpdf-report-perl  libchart-perl libtemplate-perl libnet-amazon-perl libnet-z3950-zoom-perl  aspell-es libtext-aspell-perl libnet-smtp-ssl-perl libspreadsheet-writeexcel-perl htmldoc libyaml-dev -y 

# MUCHOS ESTAN EN SQUEEZE!!!

apt-get install libjson-perl libjson-xs-perl -y

#cpan -i JSON
#cpan -i JSON::XS

cpan -i Locale::Maketext::Gettext::Functions

apt-get install librose-db-perl librose-db-object-perl -y
#cpan -i Rose::DB
#cpan -i Rose::DB::Object
#cpan -i Rose::DB::Object::Helpers

apt-get install sphinxsearch libsphinx-search-perl -y
#cpan -i Sphinx::Search
cpan -i Sphinx::Manager

apt-get install libdigest-sha-perl -y 
#cpan -i Digest::SHA
apt-get install libcrypt-cbc-perl  -y 
#cpan -i Crypt::CBC
cpan -i Image::Resize

cpan -i Text::LevenshteinXS  #Lo de abajo no es esto
apt-get install libtext-levenshtein-perl -y
cpan -i CGI::Session 
#apt-get install libcgi-session-perl -y

cpan -i Date::Manip 
cpan -i DateTime::Format::DateManip 
cpan -i Chart::OFC2
cpan -i Spreadsheet::WriteExcel::Simple

#cpan -i Net::SMTP::TLS
apt-get install libnet-smtp-tls-perl -y 

#cpan -i Net::SSLeay
apt-get install libnet-ssleay-perl -y

apt-get install libnet-twitter-perl -y
#cpan -i Net::Twitter

apt-get install libwww-facebook-api-perl -y
#cpan -i WWW::Facebook::API

cpan -i WWW::Shorten::Bitly
cpan -i HTML::HTMLDoc

# Modulo para parseo de Excel a HTML
apt-get install libspreadsheet-read-perl -y

#Para Exportar
cpan -i MARC::File::XML
