#!/usr/bin/perl
use C4::AR::Sphinx;

my $id1 = $ARGV[0] || '0'; #id1 del registro

    C4::AR::Sphinx::generar_indice($id1);

1;