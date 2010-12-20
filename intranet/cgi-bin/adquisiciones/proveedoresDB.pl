#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::AR::Proveedores;
use CGI;
use JSON;

my $input = new CGI;
my $authnotrequired= 0;
C4::AR::Debug::debug($input->param('obj'));
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";


=item
    Se elimina el Proveedor
=cut

if($tipoAccion eq "ELIMINAR"){

        my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'usuarios'},
                                                "intranet"
                                );

        my %params;
        my $id_proveedor= $obj->{'id_proveedor'};

        C4::AR::Validator::validateParams('U389',$obj,['id_proveedor'] );

        my ($Message_arrayref)= C4::AR::Proveedores::eliminarProveedor($id_proveedor);
        my $infoOperacionJSON=to_json $Message_arrayref;

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

    } #end if($tipoAccion eq "ELIMINAR_USUARIO")


=item
Se guarda la modificacion los datos del Proveedor
=cut
elsif($tipoAccion eq "GUARDAR_MODIFICACION_PROVEEDOR"){


      my ($loggedinuser, $session, $flags) = checkauth( 
                                                                $input, 
                                                                $authnotrequired,
                                                                {   ui => 'ANY', 
                                                                    tipo_documento => 'ANY', 
                                                                    accion => 'MODIFICACION', 
# TODO generar el entorno proveedores
                                                                    entorno => 'usuarios'},
#                                                                 entorno => 'proveedores'},    
                                                                "intranet"
                                );  

        C4::AR::Debug::debug("ciudad en proveedoresDB: ".$obj->{'ciudad'});
        my ($Message_arrayref)= C4::AR::Proveedores::editarProveedor($obj);
        my $infoOperacionJSON=to_json $Message_arrayref;
        

        C4::Auth::print_header($session);
        print $infoOperacionJSON;

 } #end if($tipoAccion eq "GUARDAR_MODIFICACION_USUARIO")


=item
Se guarda una nueva moneda del proveedor
=cut
elsif($tipoAccion eq "GUARDAR_MONEDA_PROVEEDOR"){

# 
#       my ($loggedinuser, $session, $flags) = checkauth( 
#                                                                 $input, 
#                                                                 $authnotrequired,
#                                                                 {   ui => 'ANY', 
#                                                                     tipo_documento => 'ANY', 
#                                                                     accion => 'MODIFICACION', 
# # TODO generar el entorno proveedores
#                                                                     entorno => 'usuarios'},
# #                                                                 entorno => 'proveedores'},    
#                                                                 "intranet"
#                                 );  



    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "includes/partials/proveedores/mostrar_monedas.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });


          my ($Message_arrayref) = C4::AR::Proveedores::agregarMoneda($obj);   

          my $monedas;

           if($Message_arrayref->{'error'} == 0){
#             la moneda fue agregada con exito, recargamos el div de las monedas en el tmpl
              $monedas = C4::AR::Proveedores::getMonedasProveedor($obj->{'id_proveedor'});
              $t_params->{'monedas'} = $monedas;

           }

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);

 } #end if($tipoAccion eq "GUARDAR_MONEDA_PROVEEDOR")

elsif($tipoAccion eq "ELIMINAR_MONEDA_PROVEEDOR"){

# 
#       my ($loggedinuser, $session, $flags) = checkauth( 
#                                                                 $input, 
#                                                                 $authnotrequired,
#                                                                 {   ui => 'ANY', 
#                                                                     tipo_documento => 'ANY', 
#                                                                     accion => 'MODIFICACION', 
# # TODO generar el entorno proveedores
#                                                                     entorno => 'usuarios'},
# #                                                                 entorno => 'proveedores'},    
#                                                                 "intranet"
#                                 );  



    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "includes/partials/proveedores/mostrar_monedas.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });

#          le mandamos un arreglo con ids de las monedas a eliminar
            my ($Message_arrayref) = C4::AR::Proveedores::eliminarMoneda($obj);
          

           my $monedas;
      C4::AR::Debug::debug(" error : ".$Message_arrayref->{'error'});
 
            if($Message_arrayref->{'error'} == 0){
 #             la moneda fue agregada con exito, recargamos el div de las monedas en el tmpl
               $monedas = C4::AR::Proveedores::getMonedasProveedor($obj->{'id_proveedor'});
               $t_params->{'monedas'} = $monedas;
 
            }

  C4::Auth::output_html_with_http_headers($template, $t_params, $session);

 } #end if($tipoAccion eq "ELIMINAR_MONEDA_PROVEEDOR")
