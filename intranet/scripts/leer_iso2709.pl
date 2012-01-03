#!/usr/bin/perl


use MARC::Moose::Record;

use MARC::Moose::Reader::File::Isis;

my $reader = MARC::Moose::Reader::File::Isis->new(
    file   => 'biblio.iso', );
while ( my $record = $reader->read() ) {

     my $formater = MARC::Moose::Formater::Text->new();
 print $formater->format( $record );

}
