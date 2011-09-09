#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::Recomendaciones;
use CGI;
use JSON;

my $input               = new CGI;
my $obj                 = $input->param('obj')||"";

my ($template, $session, $t_params);

if($obj){
#   trabajamos con JSON

    $obj                    = C4::AR::Utilidades::from_json_ISO($obj);
    my $tipoAccion          = $obj->{'tipoAccion'};
    
    if($tipoAccion eq 'ACTUALIZAR_RECOMENDACION'){
    

                        ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                            template_name       => '/adquisiciones/datosRecomendacion.tmpl',
                            query               => $input,
                            type                => "intranet",
                            authnotrequired     => 0,
                            flagsrequired       => {    ui => 'ANY',   
                                                        tipo_documento => 'ANY', 
                                                        accion => 'ALTA',  
                                                        entorno => 'usuarios'},
                        });   
                          
                        my ($ok) = C4::AR::Recomendaciones::updateRecomendacionDetalle($obj);
                        
                        my $infoOperacionJSON = to_json $ok;
                    
                        C4::AR::Auth::print_header($session);
                        print $infoOperacionJSON;
    

      } elsif ($tipoAccion eq 'ELIMINAR') {
 

                        my ($template, $session, $t_params)  = get_template_and_user({  
                                          template_name   => "/adquisiciones/recomendaciones.tmpl",
                                          query           => $input,
                                          type            => "intranet",
                                          authnotrequired => 0,
                                          flagsrequired   => {    ui => 'ANY', 
                                                                  tipo_documento => 'ANY', 
                                                                  accion => 'MODIFICAR', 
                                                                  entorno => 'undefined'},
                                          debug           => 1,
                                      });

                          my $id_recomendacion = $obj->{'id_rec'};

                          my $ok= C4::AR::Recomendaciones::eliminarRecomendacion($id_recomendacion);  
                          
                          my $infoOperacionJSON = to_json $ok;
                  
                          C4::AR::Auth::print_header($session);
                          print $infoOperacionJSON;

        
    } elsif ($tipoAccion eq 'MAS_DETALLE') {

        
                          my $id_recomendacion          = $obj->{'id_rec'};
                          
                          ($template, $session, $t_params)= get_template_and_user({
                                              template_name   => "includes/partials/recomendaciones/detalle_recom.inc",
                                              query           => $input,
                                              type            => "intranet",
                                              authnotrequired => 1,
                                              flagsrequired   => {    ui => 'ANY', 
                                                                      tipo_documento => 'ANY', 
                                                                      accion => 'CONSULTA', 
                                                                      entorno => 'undefined'},
                          });

                          my $recom_detalle= C4::AR::Recomendaciones::getRecomendacionDetallePorId($id_recomendacion);
                        
                          $t_params->{'recomendacion'}  = $recom_detalle;

                          C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

    } elsif ($tipoAccion eq 'BUSQUEDA_RECOMENDACION') {


                          my $idNivel1        =  $obj->{'idCatalogoSearch'};
                          my $combo_ediciones = C4::AR::Utilidades::generarComboNivel2($idNivel1);

                          ($template, $session, $t_params)= get_template_and_user({
                                              template_name   => "includes/partials/proveedores/combo_ediciones.tmpl",
                                              query           => $input,
                                              type            => "intranet",
                                              authnotrequired => 1,
                                              flagsrequired   => {    ui => 'ANY', 
                                                                      tipo_documento => 'ANY', 
                                                                      accion => 'CONSULTA', 
                                                                      entorno => 'undefined'},
                                          });

                          $t_params->{'combo_ediciones'} = $combo_ediciones;

       
    } elsif ($tipoAccion eq 'CARGAR_DATOS_EDICION')   {


                          my $idNivel2        =  $obj->{'edicion'};

                          my $idNivel1        = $obj->{'idCatalogoSearch'};

                          my $datos_edicion   = C4::AR::Nivel2::getNivel2FromId2($idNivel2);
                        
                          my $datos_nivel1    = C4::AR::Nivel1::getNivel1FromId1($idNivel1);

                          ($template, $session, $t_params)= get_template_and_user({
                                              template_name   => "includes/partials/proveedores/datos_edicion.tmpl",
                                              query           => $input,
                                              type            => "intranet",
                                              authnotrequired => 1,
                                              flagsrequired   => {    ui => 'ANY', 
                                                                      tipo_documento => 'ANY',   
                                                                      accion => 'CONSULTA', 
                                                                      entorno => 'undefined'},
                                          });

                          $t_params->{'datos_edicion'} = $datos_edicion;
                          $t_params->{'datos_nivel1'}  = $datos_nivel1;

                          C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    

    }  elsif ($tipoAccion eq 'LISTAR')   {


                          ($template, $session, $t_params)= get_template_and_user({
                                              template_name   => "adquisiciones/listRecomendacionesResult.tmpl",
                                              query           => $input,
                                              type            => "intranet",
                                              authnotrequired => 1,
                                              flagsrequired   => {    ui => 'ANY', 
                                                                      tipo_documento => 'ANY',   
                                                                      accion => 'CONSULTA', 
                                                                      entorno => 'undefined'},
                                          });


                          # my $ini  = 1;
                          # 
                          # my ($ini,$pageNumber,$cantR) = C4::AR::Utilidades::InitPaginador($ini);

                          # my $funcion   = $obj->{'funcion'};

                          my $recomendaciones= C4::AR::Recomendaciones::getRecomendaciones();
                          # my $cantidad= scalar(@$recomendaciones);

                          $t_params->{'page_sub_title'} = C4::AR::Filtros::i18n("Listado de Recomendaciones");
                          # $t_params->{'paginador'} = C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);

                          $t_params->{'recom_activas'} = $recomendaciones;
                          $t_params->{'cantidad'} = scalar(@$recomendaciones);


                          C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    }   


}else{
#   trabajamos con CGI

    my $id_recomendacion = $input->param('id_recomendacion');
    my $tipoAccion          = $input->param('action')||"";
      

    if($tipoAccion eq 'EDITAR_RECOMENDACION'){


                          ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                                      template_name       => '/adquisiciones/datosRecomendacion.tmpl',
                                      query               => $input,
                                      type                => "intranet",
                                      authnotrequired     => 0,
                                      flagsrequired       => {    ui => 'ANY', 
                                                                  tipo_documento => 'ANY',   
                                                                  accion => 'ALTA', 
                                                                  entorno => 'usuarios'},
                          }); 

                          my $recomendaciones             = C4::AR::Recomendaciones::getRecomendacionDetallePorId($id_recomendacion);
                          
                          $t_params->{'recomendaciones'}  = $recomendaciones;
    
    } elsif ($tipoAccion eq 'DETALLE'){
     
                          ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                                        template_name       => '/adquisiciones/detalle_recomendacion.tmpl',
                                        query               => $input,
                                        type                => "intranet",
                                        authnotrequired     => 0,
                                        flagsrequired       => {    ui => 'ANY', 
                                                                    tipo_documento => 'ANY',   
                                                                    accion => 'ALTA', 
                                                                    entorno => 'usuarios'},
                            }); 
                          

                            my $recom_detalle= C4::AR::Recomendaciones::getRecomendacionDetalle($id_recomendacion);
                          
                          
                            $t_params->{'recomendaciones'}  = $recom_detalle;

    }

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
