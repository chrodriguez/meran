#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Proveedores;
use C4::AR::Recomendaciones;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::XLSGenerator;
use C4::AR::Utilidades;

my $input           = new CGI;
my $to_pdf          = $input->param('exportPDF') || 0;
my $to_doc          = $input->param('exportDOC') || 0;
my $to_xls          = $input->param('exportXLS') || 0;
my $template_name   = "";

if($to_pdf){
	$template_name = "adquisiciones/listado_ejemplares_export.tmpl";
}elsif($to_doc){
    $template_name = "adquisiciones/listado_ejemplares_export_doc.tmpl";
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

# TODO escupir en el navegador el presupuesto para el proveedor recibido como parametro y el id_pedido_cotizacion

    my $pedido_cotizacion_id    = $input->param('pedido_cotizacion');
 
    my $proveedor_id     = $input->param('proveedor');

    
        my $presupuesto;
        my $headers_tabla;
        my $headers_planilla;
        my $campos_hidden;

        my $proveedor       = C4::AR::Proveedores::getProveedorInfoPorId($proveedor_id);  
        my $tipo_proveedor  = C4::AR::Proveedores::isPersonaFisica($proveedor_id);
        
        push(@$headers_planilla, 'Proveedor');
        
        my $nombre_proveedor;
        if($tipo_proveedor == 0){
            push (@$headers_planilla, $proveedor->getRazonSocial());
            $nombre_proveedor = $proveedor->getRazonSocial();
        }else{
            push (@$headers_planilla, $proveedor->getNombre());
            $nombre_proveedor = $proveedor->getNombre();
        }
    
        push(@$campos_hidden, $proveedor_id);
        
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
               
        my $data = C4::AR::XLSGenerator::exportarPesupuesto($presupuesto, $headers_tabla, $headers_planilla, $campos_hidden, $nombre_proveedor); 
        
        my %hash;
        
        $hash{'aplicacion'}   = "application/excel";
        $hash{'file_name'}    = "presupuesto".$nombre_proveedor.".xls";
        
       # print C4::AR::Utilidades::setHeaders(\%hash);
        #C4::AR::Debug::debug(C4::AR::Utilidades::setHeaders(\%hash));
        
        print "Content-type: application/vnd.ms-excel\n";
        print "Content-Disposition: attachment; filename=archivo.xls\n";
        print "Pragma: no-cache";
        print "Expires: 0";
        print $data;
    
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
    
    my $combo_proveedores               = C4::AR::Utilidades::generarComboProveedoresMultiple();

    $t_params->{'combo_proveedores'}    = $combo_proveedores;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
