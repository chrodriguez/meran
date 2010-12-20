#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::AR::Proveedores;
use C4::AR::Presupuestos;
use CGI;
use JSON;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;

my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj            = C4::AR::Utilidades::from_json_ISO($obj);
my $proveedor   = $obj->{'id_proveedor'}||"";
my $tipoAccion  = $obj->{'tipoAccion'}||"";



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
elsif($tipoAccion eq "GUARDAR_MODIFICION_PROVEEDOR"){


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


elsif($tipoAccion eq "GUARDAR_MODIFICACION_PRESUPUESTO"){

    my $recomendacion=1;

    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "/adquisiciones/mostrarPresupuesto.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });

     my (@pres_detalle) = &C4::AR::Presupuestos::getAdqPresupuestoDetalle($recomendacion);  
     C4::AR::Debug::debug(@pres_detalle);

}


=item
Se procesa la planilla ingresada
=cut
elsif($tipoAccion eq "MOSTRAR_PRESUPUESTO"){

# PARA FILEUPLOAD
my $filepath    = $input->param('planilla');

my ($template, $session, $t_params) =  C4::Auth::get_template_and_user ({
                      template_name   => '/adquisiciones/mostrarPresupuesto.tmpl',
                      query       => $input,
                      type        => "intranet",
                      authnotrequired => 0,
                      flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
});

my $presupuestos_dir= "/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores";
my $write_file  = $presupuestos_dir."/prueba.xls";

my $parser  = Spreadsheet::ParseExcel->new();

my $workbook = $parser->parse($write_file);


# if ( !defined $workbook ) {
#             die $parser->error(), ".\n";
# }
#  
my @table;
my @reg;
my $presupuesto;
     

for my $worksheet ( $workbook->worksheets() ) {
     my ( $row_min, $row_max ) = $worksheet->row_range();
  
     for my $row ( $row_min + 1 .. $row_max ) {
        my %hash;
#         my $cell = $worksheet->get_cell( $row, $col );
        
        $hash{'renglon'}            = $worksheet->get_cell( $row, 0 )->value();
        $hash{'cantidad'}           = $worksheet->get_cell( $row, 1 )->value();
        $hash{'articulo'}           = $worksheet->get_cell( $row, 2 )->value();       
        $hash{'precio_unitario'}    = $worksheet->get_cell( $row, 3 )->value();
        $hash{'total'}              = $worksheet->get_cell( $row, 4 )->value();
        C4::AR::Debug::debug("MI RENGLON:".$hash{'renglon'});
       
        push(@reg, \%hash);  
  }
}


$t_params->{'datos_presupuesto'} = \@reg;

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

} #end if($tipoAccion eq "MOSTRAR_PRESUPUESTO")



=item
Se elimina una moneda de proveedor
=cut

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
