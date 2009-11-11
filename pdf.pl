#!/usr/bin/perl
use strict;
use warnings;
use PDF::API2;
use Encode;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

my $pdf = PDF::API2->new(-encode => 'latin1');


my %font = (
  Helvetica => {
      Bold   => $pdf->corefont( 'Helvetica-Bold',    -encode => 'latin1' ),
      Roman  => $pdf->corefont( 'Helvetica',         -encode => 'latin1' ),
      Italic => $pdf->corefont( 'Helvetica-Oblique', -encode => 'latin1' ),
  },
  Times => {
      Bold   => $pdf->corefont( 'Times-Bold',   -encode => 'latin1' ),
      Roman  => $pdf->corefont( 'Times',        -encode => 'latin1' ),
      Italic => $pdf->corefont( 'Times-Italic', -encode => 'latin1' ),
  },
);

$pdf->cropbox('A4');

$pdf->corefont('Times-Roman');

$pdf->info(
      'Author'       => " Alfred Reibenschuh ",
      'CreationDate' => "D:20020911000000+01'00'",
      'ModDate'      => "D:YYYYMMDDhhmmssOHH'mm'",
      'Creator'      => "fredos-script.pl",
      'Producer'     => "PDF::API2",
      'Title'        => "some Publication",
      'Subject'      => "perl ?",
      'Keywords'     => "all good things are pdf"
  );

my $page = $pdf->page;

my $headline_text = $page->text;

$headline_text->font( $font{'Times'}{'Roman'}, 18/pt );

$headline_text->fillcolor('black');

$headline_text->translate( 95/mm, 131/mm );

my $data = 'USING PDF::API2 maría';

$headline_text->text_right(Encode::encode('latin1', $data));

$pdf->saveas("new.pdf");
