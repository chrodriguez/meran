#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Proveedores;
use C4::AR::Recomendaciones;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::XLSGenerator;

my $input           = new CGI;
my $to_pdf          = $input->param('exportPDF') || 0;
my $to_doc          = $input->param('exportDOC') || 0;
my $to_xls          = $input->param('exportXLS') || 0;
my $template_name   = "";

if($to_pdf){
	$template_name = "adquisiciones/listado_ejemplares_export.tmpl";
}elsif($to_doc){
    $template_name = "adquisiciones/listado_ejemplares_export_doc.tmpl";
}elsif($to_xls){
    $template_name = "adquisiciones/presupuesto_export.tmpl";
}

my ($template, $session, $t_params) = get_template_and_user({
    template_name => $template_name,
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
    debug => 1,
});
 
if($to_pdf){
#   se exporta a PDF las recomendaciones

    my $recomendaciones_activas                 = C4::AR::Recomendaciones::getRecomendacionesActivas();   
    my $cant_recomendaciones                    = (scalar(@$recomendaciones_activas));    
    my $i;
    my @resultsdata;
    
    for($i = 1; $i <= $cant_recomendaciones; $i++){
     
        if($input->param('activo'.$i) ne ''){
        
            my %hash = (    titulo      => $input->param('libro'.$i),
                            cantidad    => $input->param('cantidad'.$i),
                            fecha       => $input->param('fecha'.$i), ); 
                      
            my %row = ( recomendacion => \%hash,);
            
            push(@resultsdata, \%row);
        }
    }
    
    if(@resultsdata > 0){
        $t_params->{'resultsloop'}= \@resultsdata; 
    }

	my $out = C4::AR::Auth::get_html_content( $template, $t_params, $session );
	my $filename = C4::AR::PdfGenerator::pdfFromHTML($out);
	print C4::AR::PdfGenerator::pdfHeader();
	C4::AR::PdfGenerator::printPDF($filename);

}elsif($to_doc){
#   exporta a DOC las recomendaciones

    my $recomendaciones_activas                 = C4::AR::Recomendaciones::getRecomendacionesActivas();   
    my $cant_recomendaciones                    = (scalar(@$recomendaciones_activas));    
    my $i;
    my @resultsdata;
    
    for($i = 1; $i <= $cant_recomendaciones; $i++){
    
        if($input->param('activo'.$i) ne ''){
        
            my %hash = (    titulo      => $input->param('libro'.$i),
                            cantidad    => $input->param('cantidad'.$i),
                            fecha       => $input->param('fecha'.$i), ); 
                      
            my %row = ( recomendacion => \%hash,);
            
            push(@resultsdata, \%row);
        }
    }
    
    if(@resultsdata > 0){
        $t_params->{'resultsloop'}= \@resultsdata; 
    }
    
    print C4::AR::Auth::get_html_content( $template, $t_params, $session );

}elsif($to_xls){
# se exporta a XLS

    my $pedido_cotizacion_id    = $input->param('pedido_cotizacion_id');
 
    my $proveedores     = $input->param('proveedores_array');
    my @parts           = split(/\,/,$proveedores);
    
    my $i;
    # arreglo con los path para hacer los links de descargas
    my @paths_array;
    for($i = 0; $i < scalar(@parts); $i++){ 
    
        my $presupuesto;
        my $headers_tabla;
        my $headers_planilla;
        my $campos_hidden;

        my $proveedor       = C4::AR::Proveedores::getProveedorInfoPorId(@parts[$i]);  
        my $tipo_proveedor  = C4::AR::Proveedores::isPersonaFisica(@parts[$i]);
        
        push(@$headers_planilla, 'Proveedor');
        
        my $nombre_proveedor;
        if($tipo_proveedor == 0){
            push (@$headers_planilla, $proveedor->getRazonSocial());
            $nombre_proveedor = $proveedor->getRazonSocial();
        }else{
            push (@$headers_planilla, $proveedor->getNombre());
            $nombre_proveedor = $proveedor->getNombre();
        }
    
        push(@$campos_hidden, @parts[$i]);
        
        push(@$headers_tabla, 'Renglon');
        push(@$headers_tabla, 'Cantidad');
        push(@$headers_tabla, 'Articulo');
        push(@$headers_tabla, 'Precio Unitario');
        push(@$headers_tabla, 'Precio Total');
    
        my $pedidos_cotizacion_detalle = C4::AR::PedidoCotizacionDetalle::getPedidosCotizacionPorPadre($pedido_cotizacion_id);
        
        foreach my $celda (@$pedidos_cotizacion_detalle){
            my $celda_xls; 
            
            push(@$celda_xls, $celda->{'nro_renglon'});
            push(@$celda_xls, $celda->{'cantidad_ejemplares'});
            push(@$celda_xls, $celda->{'titulo'});

            push (@$presupuesto, $celda_xls);
        }
        
        # antes creamos el archivo
        open(PRESUPUESTO,">/usr/share/meran/intranet/htdocs/intranet-tmpl/reports/presupuesto".$nombre_proveedor.".xls") || die "No se pudo crear el archivo";
        close(PRESUPUESTO); 
        
         # devuelve la data del archivo xls  
        my $path             = C4::AR::XLSGenerator::exportarPesupuesto($presupuesto, $headers_tabla, $headers_planilla, $campos_hidden, $nombre_proveedor); 
        
        $paths_array[$i] = "/reports/presupuesto".$nombre_proveedor.".xls";
    } 
    
    $t_params->{'paths'}     = \@paths_array;
    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
    
}else{
#   se muestra el template normal

    my $recomendaciones_activas   = C4::AR::Recomendaciones::getRecomendacionesActivas();

    if($recomendaciones_activas){
        my @resultsdata;
      
        for my $recomendacion (@$recomendaciones_activas){   
            my %row = ( recomendacion => $recomendacion, );
            push(@resultsdata, \%row);
        }

       $t_params->{'resultsloop'}   = \@resultsdata; 
       
    }
    
    my $combo_proveedores               = &C4::AR::Utilidades::generarComboProveedoresMultiple();

    $t_params->{'combo_proveedores'}    = $combo_proveedores;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
