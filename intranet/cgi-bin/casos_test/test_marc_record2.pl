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

my $id1 = 4;
my $id2;
my $sth_n1 = $dbh->prepare("    SELECT *
                                FROM cat_registro_marc_n1
                                WHERE (id = ?) ");
$sth_n1->execute($id1);
my $marcblob_n1 = $sth_n1->fetchrow;
    
my $marc_record_n1 = MARC::Record->new_from_usmarc( $marcblob_n1 );

C4::AR::Debug::debug("marc_record_n1 => as_formatted ".$marc_record_n1->as_formatted());


my $sth_n2 = $dbh->prepare("    SELECT *
                                FROM cat_registro_marc_n2
                                WHERE (id1 = ?) ");
$sth_n2->execute($id1);

while (my $marcblob_n2 = $sth_n2->fetchrow_hashref){
    # RECORRO LOS GRUPOS DEL NIVEL 1
    my $marc_record_n2 = MARC::Record->new_from_usmarc( $marcblob_n2->{'marc_record'} );

    $id2 = $marcblob_n2->{'id'};



    # BUSCO LOS EJEMPLARES DE UN GRUPO EN PARTICULAR
    my $sth_n3 = $dbh->prepare("    SELECT *
                                    FROM cat_registro_marc_n3
                                    WHERE (id2 = ?) ");
    $sth_n3->execute($id2);
    
    while (my $marcblob_n3 = $sth_n3->fetchrow_hashref){
    # RECORRO LOS EJEMPLARES DEL NIVEL 2
        my $marc_record_n3 = MARC::Record->new_from_usmarc( $marcblob_n3->{'marc_record'});
        C4::AR::Debug::debug("marc_record_n3 => as_formatted ".$marc_record_n3->as_formatted());
    
    # AGREGO LOS FILEDS AL marc_record_n1
        $marc_record_n2->add_fields( $marc_record_n3->fields() );
    }

    C4::AR::Debug::debug("marc_record_n2 COMPLETO => as_formatted ".$marc_record_n2->as_formatted());


    # AGREGO LOS FILEDS AL marc_record_n1
    $marc_record_n1->add_fields( $marc_record_n2->fields() );

}


 C4::AR::Debug::debug("marc_record_n1 COMPLETO => as_formatted ".$marc_record_n1->as_formatted());


C4::AR::Auth::print_header($session);