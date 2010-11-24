#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Date;

use CGI;

my $input=new CGI;

my ($template, $session, $t_params) =  get_template_and_user ({
                            template_name   => 'usuarios/reales/items.tmpl',
                            query       => $input,
                            type        => "intranet",
                            authnotrequired => 0,
                            flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
    });


my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));

C4::AR::Validator::validateParams('U389',$obj,['id_proveedor'] );

my $id_proveedor= $obj->{'id_proveedor'};
my $orden= $obj->{'orden'}||'descripcion';
my $ini= $obj->{'ini'};
my $funcion= $obj->{'funcion'};

my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);

# ver esta funcion:
my ($cant,$items_array_ref,$loop_reading)=C4::AR::Items::getItemsParaTemplate($id_proveedor,$ini,$cantR,$orden);

if($items_array_ref){
      $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);
      my @resultsdata;
  
      for my $item ($items_array_ref){
         my $clase="";
 #        my ($od,$issue)=C4::AR::Prestamos::cantidadDePrestamosPorUsuario($socio->getNro_socio);  --- Ver si es necesario para cant de items del proveedor
 #        my $regular= &C4::AR::Usuarios::esRegular($socio->getNro_socio);
     
 #         if ($regular eq 1){$regular="Regular"; $clase="prestamo";}  
 #         else{
 #             if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
 #             else{
 #                 $regular="---";
 #             }
 #         }
     
           my %row = (
 #                     clase=>$clase,
                     item => $item,
 #                     issue => "$issue",
 #                     od => "$od",
 #                     regular => $regular,
           );
           push(@resultsdata, \%row);
       }
      $t_params->{'paginador'}=&C4::AR::Utilidades::crearPaginador($cant,$cantR, $pageNumber,$funcion,$t_params);
      $t_params->{'loop_reading'}= \@resultsdata;
      $t_params->{'cant'}= $cant;
#       $t_params->{'item_busqueda'}=$item;
 
 }#END if($proveedores)


C4::Auth::output_html_with_http_headers($template, $t_params, $session);
