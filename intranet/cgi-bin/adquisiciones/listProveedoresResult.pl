#!/usr/bin/perl

use strict;
use C4::Auth;
use CGI;
use C4::Date;
use Date::Manip;
use C4::AR::Usuarios;
use C4::AR::Utilidades;


my $input = new CGI;

my ($template, $session, $t_params)= get_template_and_user({
                                template_name => "adquisiciones/listProveedoresResult.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
                                debug => 1,
                 });


#C4::AR::Debug::debug("EL STRING"."OTRO SYRING".$ini);

my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));



# Test:

      my $proveedor = $obj->{'nombre_proveedor'};

      my @resultsdata;


      my %row = (
                  proveedor => $proveedor
      );
      push(@resultsdata, \%row);

      $t_params->{'resultsloop'}= \@resultsdata;

      C4::Auth::output_html_with_http_headers($template, $t_params, $session);


# fin Test, anda OK. Muestra el nombre del proveedor que ingrese en el input.






#  Como debe ser:
# my $orden=$obj->{'orden'}||'nombre';

  $obj->{'ini'} = $obj->{'ini'} || 1;
  my $ini=$obj->{'ini'};
  my $funcion=$obj->{'funcion'};
  my $inicial=$obj->{'inicial'};
  my $proveedor = $obj->{'nombre_proveedor'};
  my $env;
#  C4::AR::Validator::validateParams('U389',$obj,['proveedor','ini','funcion'] );


#  my $orden= '';

# my $ini= 1;
# my $funcion=$input->param('funcion');
# 
# 
# 
# 
# C4::AR::Debug::debug($orden);
# C4::AR::Debug::debug($proveedor);
# C4::AR::Debug::debug($ini);
# C4::AR::Debug::debug($funcion);
# C4::AR::Debug::debug($inicial);
# 
# my ($cantidad,$proveedores);
# my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
# # 
# if ($inicial){
#     ($cantidad,$proveedores)= C4::Modelo::AdqProveedor::getProveedorLike($proveedor,$orden,$ini,$cantR,1,$inicial);
# }else{
#     ($cantidad,$proveedores)= C4::Modelo::AdqProveedor::getProveedorLike($proveedor,$orden,$ini,$cantR,1,0);
# }
#  
# if($proveedores){
#      $t_params->{'paginador'}= C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
#      my @resultsdata;
#  
#      for my $proveedor (@$proveedores){
#         my $clase="";
# #        my ($od,$issue)=C4::AR::Prestamos::cantidadDePrestamosPorUsuario($socio->getNro_socio);  --- Ver si es necesario para cant de items del proveedor
# #        my $regular= &C4::AR::Usuarios::esRegular($socio->getNro_socio);
#     
# #         if ($regular eq 1){$regular="Regular"; $clase="prestamo";}  
# #         else{
# #             if($regular eq 0){$regular="Irregular";$clase="fechaVencida";}
# #             else{
# #                 $regular="---";
# #             }
# #         }
#     
#           my %row = (
# #                     clase=>$clase,
#                     proveedor => $proveedor,
# #                     issue => "$issue",
# #                     od => "$od",
# #                     regular => $regular,
#           );
#           push(@resultsdata, \%row);
#       }
#      
#      $t_params->{'resultsloop'}= \@resultsdata;
#      $t_params->{'cantidad'}= $cantidad;
#      $t_params->{'proveedor_busqueda'}=$proveedor;
# 
# }#END if($proveedores)
# 
# C4::Auth::output_html_with_http_headers($template, $t_params, $session);
# 

1;