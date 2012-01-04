#!/usr/bin/perl


use MARC::Moose::Record;
use MARC::Moose::Reader::File::Isis;

my $reader = MARC::Moose::Reader::File::Isis->new(
    file   => 'biblio.iso', );
while ( my $record = $reader->read() ) {


     for my $field ( @{$record->fields} ) {
         if($field->tag < '010'){
             #CONTROL FIELD
                 print "CAMPO CONTROL > ".$field->tag;
                 print "\n";
             }
             else {
         for my $subfield ( @{$field->subf} ) {
              print "CAMPO > ".$field->tag." SUBCAMPO > ". $subfield->[0]." ==> ".$subfield->[1]."\n";
            }
        }

     }
}
