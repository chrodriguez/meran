#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Context;
use CGI;
use JSON;


my $input = new CGI;
my $editing = 0;

# my $editing = $input->param('edit');
# my $obj=$input->param('obj');
# $obj=C4::AR::Utilidades::from_json_ISO($obj); 
# my $tipoAccion= obj->{'tipo_accion'};

if ($editing != 0){
    my $tipoAccion;
    if ($tipoAccion == 'AGREGAR_PROVEEDOR'){
        my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "adquisiciones/formProveedores.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
                            debug => 1,
                        });

        # my $comboDeCategorias       = &C4::AR::Utilidades::generarComboCategoriasDeSocio();
        # my $comboDeTipoDeDoc        = &C4::AR::Utilidades::generarComboTipoDeDoc();
        # my $comboDeUI               = &C4::AR::Utilidades::generarComboUI();
        # my $comboDeCredentials      = &C4::AR::Utilidades::generarComboDeCredentials();

    #     $t_params->{'combo_temas'} = C4::AR::Utilidades::generarComboTemasINTRA();
    #     $t_params->{'combo_tipo_documento'} = $comboDeTipoDeDoc;
    #     $t_params->{'comboDeCategorias'}    = $comboDeCategorias;
    #     $t_params->{'comboDeCredentials'}   = $comboDeCredentials;
    #     $t_params->{'comboDeUI'}            = $comboDeUI;
        my %params = {};

    #     $params{'nombre'} = $obj->{'nombre'};
    #     $params{'direccion'} = $obj->{'direccion'};
    #     $params{'proveedor_activo'} = 1;
    #     $params{'telefono'} = $obj->{'telefono'};
    #     $params{'email'} = $obj->{'email'};
    #     $params{'actionType'} = $obj->{'tipoAccion'};

    # 
    #     my ($value)= C4::AR::Proveedores::agregarProveedor(\%params);
        $t_params->{'addProveedor'} = 1;

    #     $t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("Agregar Usuario");
        C4::Auth::output_html_with_http_headers($template, $t_params, $session);

    }else{
        my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "adquisiciones/formProveedores.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
                            debug => 1,
                        });
      $t_params->{'addProveedor'} = 0;
      C4::Auth::output_html_with_http_headers($template, $t_params, $session);
    }
}else{
            my ($template, $session, $t_params) = get_template_and_user({
                            template_name => "adquisiciones/formProveedores.tmpl",
                            query => $input,
                            type => "intranet",
                            authnotrequired => 0,
                            flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
                            debug => 1,
                        });
          $t_params->{'addProveedor'} = 0;
          C4::Auth::output_html_with_http_headers($template, $t_params, $session);
}