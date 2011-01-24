#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
# use C4::Database;
use C4::AR::Auth;
use C4::AR::Debug;
use C4::Context;
use CGI::Session;
use CGI;



my $session = CGI::Session->new();

my $dbh   = C4::Context->dbh;
use MARC::Record;

my $sth = $dbh->prepare("   SELECT registro_marc
                            FROM indice_busqueda n1r
                            WHERE (id = ?) ");
$sth->execute(1);
my $marcblob = $sth->fetchrow;
    
my $marc_record = MARC::Record->new_from_usmarc( $marcblob );

foreach my $m  ($marc_record->fields()){
    while ( my ($key, $value) = each(%$m) ) {
        C4::AR::Debug::debug("marcblob ===================================================> key ".$key."value ".$value);
    }
}

my $list_995 = $marc_record->field( "995" );
foreach my $m  (%$list_995){
    C4::AR::Debug::debug("marcblob ===================================================> list_995 ".$m);
}

$marc_record->encoding( 'UTF-8' );
C4::AR::Debug::debug("marcblob ===================================================> titulo".$marc_record->subfield("245","a"));
C4::AR::Debug::debug("marcblob ===================================================> barcode ".$marc_record->subfield("995","f"));
C4::AR::Debug::debug("marcblob ===================================================> autor ".$marc_record->subfield("110","a"));

C4::AR::Debug::debug("CREO MARCRECORD SIN TITUTLO ============================================================================");
my $field = MARC::Field->new('590','','','a' => 'My local note.');
my $subfield = $field->subfield( 'a' );
C4::AR::Debug::debug("CREO MARCRECORD SIN TITUTLO ===================================================".$subfield);

foreach my $m  (%$field){
    C4::AR::Debug::debug("marcblob ===================================================> field solo ".$m);
}

C4::AR::Debug::debug("as_formatted ".$field->as_formatted());

$marc_record->add_fields( $field );
C4::AR::Debug::debug("marc_record => as_formatted ".$marc_record->as_formatted());

my $marc_record = MARC::Record->new();
$marc_record->add_fields( $field );
C4::AR::Debug::debug("marc_record => as_formatted ".$marc_record->as_formatted());


C4::AR::Auth::print_header($session);