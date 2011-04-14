#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;

my $input = new CGI;
my $texto = $input->param('id_proveedor');

#TODO: guardar la info que se edito en la BD
