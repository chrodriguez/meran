#/bin/bash
apt-get update -y
apt-get install libpdf-report-perl libhtml-template-expr-perl  libhtml-template-perl libnet-ldap-perl libdbd-mysql-perl libmail-sendmail-perl libmarc-record-perl libgd-gd2-perl libarchive-zip-perl libapache2-mod-perl2 libapache-db-perl libdate-manip-perl libooolib-perl libpdf-report-perl  libchart-perl libtemplate-perl libnet-amazon-perl libnet-z3950-zoom-perl  aspell-es libtext-aspell-perl libnet-smtp-ssl-perl libspreadsheet-writeexcel-perl htmldoc -y 

cpan -i JSON
cpan -i JSON::XS
cpan -i Locale::Maketext::Gettext::Functions
cpan -i Rose::DB
cpan -i Rose::DB::Object
cpan -i Rose::DB::Object::Helpers


apt-get install libdigest-sha-perl  #cpan -i Digest::SHA
apt-get install libcrypt-cbc-perl   #cpan -i Crypt::CBC
cpan -i Image::Resize
cpan -i Text::LevenshteinXS
cpan -i Sphinx::Search
cpan -i Sphinx::Manager
cpan -i CGI::Session #libcgi-session-perl
cpan -i DateTime::Format::DateManip
cpan -i Chart::OFC2
cpan -i Net::SMTP::TLS
cpan -i Net::SSLeay
cpan -i Net::Twitter
cpan -i WWW::Facebook::API
cpan -i HTML::HTMLDoc
