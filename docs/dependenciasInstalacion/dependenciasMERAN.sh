#/bin/bash
apt-get update -y
apt-get install apache2 mysql-server libpdf-report-perl libhtml-template-expr-perl  libhtml-template-perl libnet-ldap-perl libdbd-mysql-perl libmail-sendmail-perl libmarc-record-perl libgd-gd2-perl libarchive-zip-perl libapache2-mod-perl2 libapache-db-perl libooolib-perl libpdf-report-perl  libchart-perl libtemplate-perl libnet-amazon-perl libnet-z3950-zoom-perl  aspell-es libtext-aspell-perl libnet-smtp-ssl-perl libspreadsheet-writeexcel-perl htmldoc libyaml-dev libcaptcha-recaptcha-perl libemail-mime-encodings-perl -y 

# MUCHOS ESTAN EN SQUEEZE!!!
apt-get install libjson-perl libjson-xs-perl librose-db-perl librose-db-object-perl sphinxsearch libsphinx-search-perl libdigest-sha-perl libcrypt-cbc-perl libtext-levenshtein-perl  libnet-smtp-tls-perl libnet-ssleay-perl libnet-twitter-perl libwww-facebook-api-perl libspreadsheet-read-perl -y

apt-get install libcgi-session-perl libdate-manip-perl liblocale-maketext-gettext-perl libspreadsheet-writeexcel-perl libfile-libmagic-perl -y
apt-get install libhttp-browserdetect-perl libtext-unaccent-perl -y
apt-get install libmarc-crosswalk-dublincore-perl libmarc-xml-perl -y
apt-get install libimage-size-perl -y
apt-get install libdatetime-format-mysql-perl -y
# OTROS AUN NO!!!
apt-get install make gcc -y
cpan -i CPAN 
cpan -i YAML
cpan -i MIME::Lite::TT::HTML
cpan -i Spreadsheet::WriteExcel::Simple
cpan -i Sphinx::Manager
cpan -i Image::Resize
cpan -i Text::LevenshteinXS
cpan -i Chart::OFC2
cpan -i WWW::Shorten::Bitly
cpan -i HTML::HTMLDoc
cpan -i MARC::File::XML
cpan -i DateTime::Format::DateManip
cpan -i WWW::Google::URLShortener
cpan -i Apache::Session::Lock::Semaphore



