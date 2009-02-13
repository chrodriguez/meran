#/bin/bash
apt-get update
apt-get install libpdf-report-perl libhtml-template-expr-perl  libhtml-template-perl libnet-ldap-perl libdbd-mysql-perl libmail-sendmail-perl libmarc-record-perl libgd-gd2-perl libarchive-zip-perl libapache2-mod-perl2 libapache-db-perl libdate-manip-perl libooolib-perl libpdf-report-perl  libchart-perl libtemplate-perl libcgi-session-perl libnet-amazon-perl libnet-z3950-zoom-perl

cpan -i JSON
cpan -i JSON::XS
cpan -i Locale::Maketext::Gettext::Functions
cpan -i Rose::DB
cpan -i Rose::DB::Object
cpan -i Rose::DB::Object::Helpers
