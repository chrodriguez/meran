#!/usr/bin/perl

use strict;
use CGI;
use C4::AR::Utilidades;

my $input = new CGI;
my $authnotrequired = 0;
my $flagsrequired = { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'sistema'};

my $session = CGI::Session->load();

my $type = $session->param('type') || "opac";

my ($user, $session, $flags)= C4::Auth::checkauth($input, $authnotrequired, $flagsrequired, $type);

my $operacion   = C4::AR::Utilidades::trim( $input->param('operacion') ) || '';
my $accion      = C4::AR::Utilidades::trim( $input->param('accion') );
my $string      = C4::AR::Utilidades::trim( $input->param('q') );
# C4::AR::Debug::debug("BUSCASTE: ".$string);
#Variable para luego hacerle el print
my $result;

if ($accion eq 'autocomplete_ciudades'){

    $result = C4::AR::Utilidades::ciudadesAutocomplete($string);
}
elsif ($accion eq 'autocomplete_paises'){

    $result = C4::AR::Utilidades::paisesAutocomplete($string);
}
elsif ($accion eq 'autocomplete_lenguajes'){

    $result = C4::AR::Utilidades::lenguajesAutocomplete($string);
}
elsif ($accion eq 'autocomplete_autores'){

    $result = C4::AR::Utilidades::autoresAutocomplete($string);
}
elsif ($accion eq 'autocomplete_soportes'){

    $result = C4::AR::Utilidades::soportesAutocomplete($string);
}
elsif ($accion eq 'autocomplete_usuarios'){

    $result = C4::AR::Utilidades::usuarioAutocomplete($string);
}
elsif ($accion eq 'autocomplete_barcodes_prestados'){

	$result = C4::AR::Utilidades::barcodePrestadoAutocomplete($string);
}
elsif ($accion eq 'autocomplete_barcodes'){

     $result = C4::AR::Utilidades::barcodeAutocomplete($string);
}
elsif ($accion eq 'autocomplete_temas'){

     $result = C4::AR::Utilidades::autocompleteTemas($string);
}
elsif ($accion eq 'autocomplete_editoriales'){

     $result = C4::AR::Utilidades::autocompleteEditoriales($string);
}
elsif ($accion eq 'autocomplete_ayuda_marc'){

     $result = C4::AR::Utilidades::ayudaCampoMARCAutocomplete($string);
}
elsif ($accion eq 'autocomplete_UI'){

     $result = C4::AR::Utilidades::uiAutocomplete($string);
}


C4::Auth::print_header($session);
print $result;

1;