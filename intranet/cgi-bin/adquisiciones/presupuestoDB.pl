#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::AR::Proveedores;
use C4::AR::Presupuestos;
use CGI;
use JSON;
use Spreadsheet::Read;
use Spreadsheet::ParseExcel;
#use Spreadsheet::ReadSXC qw(read_sxc);
use C4::AR::XLSGenerator;

my $input = new CGI;
my $authnotrequired= 0;

my $obj=$input->param('obj');

$obj = C4::AR::Utilidades::from_json_ISO($obj);

my $proveedor   = $obj->{'id_proveedor'}||"";
my $tipoAccion  = $obj->{'tipoAccion'}||"";


if($tipoAccion eq "GUARDAR_MODIFICACION_PRESUPUESTO"){

  
    my ($template, $session, $t_params)  = get_template_and_user({  
                        template_name => "/adquisiciones/mostrarPresupuesto.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'permisos', tipo_permiso => 'general'},
                        debug => 1,
                    });

     my ($Message_arrayref) = C4::AR::Presupuestos::actualizarPresupuesto($obj);   
     
     my $infoOperacionJSON=to_json $Message_arrayref;
        
     C4::AR::Auth::print_header($session);
     print $infoOperacionJSON;

}

=item
Se procesa la planilla ingresada
=cut

elsif($tipoAccion eq "MOSTRAR_PRESUPUESTO"){

        my $filepath  = $obj->{'filepath'}||"";

        my ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                              template_name   => '/adquisiciones/mostrarPresupuesto.tmpl',
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
        });

        my $presupuestos_dir= "/usr/share/meran/intranet/htdocs/intranet-tmpl/proveedores/";
        my $write_file  = $presupuestos_dir.$filepath;

        my $parser  = Spreadsheet::ParseExcel-> new();
        my $workbook = $parser->parse($write_file);
    
        my $workbook_ref = read_sxc($write_file);

        foreach ( sort keys %$workbook_ref ) {
                print "Worksheet ", $_, " contains ", $#{$$workbook_ref{$_}} + 1, " row(s):\n";
                foreach ( @{$$workbook_ref{$_}} ) {
                      foreach ( map { defined $_ ? $_ : '' } @{$_} ) {
                            print utf8(" '$_'")->as_string;
                      }
                      print "\n";
                }
        }
        
        my @table;
        my @reg;

        my $worksheet = $workbook->worksheet(0);
        my ( $row_min, $row_max ) = $worksheet->row_range();

        my $id_pres = $worksheet->get_cell( 1, 1 )->value();
     

        for my $row ( $row_min + 3 .. $row_max ) {
                
                my %hash; 
                
                $hash{'renglon'}            = $worksheet->get_cell( $row, 0 )->value();        
                $hash{'cantidad'}           = $worksheet->get_cell( $row, 1 )->value();
                $hash{'articulo'}           = $worksheet->get_cell( $row, 2 )->value();   
                $hash{'precio_unitario'}    = $worksheet->get_cell( $row, 3 )->value();
                $hash{'total'}              = $worksheet->get_cell( $row, 4 )->value(); 
                              
                push(@reg, \%hash);  
                    
        }
    
        my $pres= C4::AR::Presupuestos::getPresupuestoPorID($id_pres);
        

        $t_params->{'datos_presupuesto'} = \@reg;   
        $t_params->{'pres'} =  $pres;

        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

} #end if($tipoAccion eq "MOSTRAR_PRESUPUESTO")

elsif($tipoAccion eq "MOSTRAR_PRESUPUESTO_MANUAL"){

       
        my $id_pres= $obj->{'id_presupuesto'};

        my ($template, $session, $t_params) =  C4::AR::Auth::get_template_and_user ({
                              template_name   => '/adquisiciones/presupuestoManual.tmpl',
                              query       => $input,
                              type        => "intranet",
                              authnotrequired => 0,
                              flagsrequired   => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'usuarios'},
        });
        
    
        my $detalle_pres = C4::AR::Presupuestos::getAdqPresupuestoDetalle($id_pres);
    
        my $pres= C4::AR::Presupuestos::getPresupuestoPorID($id_pres);
        
        $t_params->{'pres'} =  $pres;
        $t_params->{'detalle_presupuesto'} = $detalle_pres;
       
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);

        
} #end if($tipoAccion eq "MOSTRAR_PRESUPUESTO_MANUAL")


elsif($tipoAccion eq "AGREGAR_PRESUPUESTO"){

    my ($template, $session, $t_params) = get_template_and_user({
        template_name => "adquisiciones/generatePresupuesto.tmpl",
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
        debug => 1,
    });
   
    my $message;

    # recorremos los proveedores seleccionados y les agregamos el presupuesto
    for(my $i=0;$i<scalar(@{$obj->{'proveedores_array'}});$i++){
    
        my %params = {};
        
        $params{'id_proveedor'}           = $obj->{'proveedores_array'}->[$i];
        $params{'pedido_cotizacion_id'}   = $obj->{'pedido_cotizacion_id'};
        
        $message = C4::AR::Presupuestos::addPresupuesto(\%params);   
    }

    my $infoOperacionJSON   = to_json $message;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;

}# end if($tipoAccion eq "AGREGAR_PRESUPUESTO")

elsif($tipoAccion eq "EXPORTAR"){

    my ($template, $session, $t_params) = get_template_and_user({
        template_name => "adquisiciones/generatePresupuesto.tmpl",
        query => $input,
        type => "intranet",
        authnotrequired => 0,
        flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
        debug => 1,
    });
    
    my $proveedores_array       = $obj->{'proveedores_array'};
    my $pedido_cotizacion_id    = $obj->{'$pedido_cotizacion_id'};
    
    my $presupuesto;
    my $headers_tabla;
  
    push(@$headers_tabla, 'Renglon');
    push(@$headers_tabla, 'Cantidad');
    push(@$headers_tabla, 'Articulo');
    push(@$headers_tabla, 'Precio Unitario');
    push(@$headers_tabla, 'Precio Total');
    
    #   con muchos proveedores:
    #for(my $i=0;$i<scalar(@{$obj->{'proveedores_array'}});$i++){
    #    my $celda_xls;
        
    #    push(@$celda_xls, $obj->{'proveedores_array'}->[$i]);
        
    #    push (@$presupuesto, $celda_xls);
    #}
    
    #   test de un solo proveedor:
    
    
    
    #TODO pasar los detalle_presupuesto
    
    my $celda_xls;
    my $i = 0;
    push(@$celda_xls, $obj->{'proveedores_array'}->[$i]);
        
    push (@$presupuesto, $celda_xls);    
    
    
    
    my $message             = C4::AR::XLSGenerator::exportarPesupuesto($presupuesto, $headers_tabla);    

    my $infoOperacionJSON   = to_json $message;
    C4::AR::Auth::print_header($session);
    print $infoOperacionJSON;
    
    #   imrpimir el archivo: FIXME no lo hace
    my ($file,$cadena);
    open(file, ">>/usr/share/meran/intranet/htdocs/intranet-tmpl/reports/presupuesto.xls");
    print file;


}# end if($tipoAccion eq "EXPORTAR")
