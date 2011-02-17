#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use C4::Context;
use C4::AR::Proveedores;
use C4::AR::Recomendaciones;
use CGI;
use C4::AR::PdfGenerator;

my $input = new CGI;
my $to_pdf = $input->param('exportPDF') || 0;
my $to_doc = $input->param('exportDOC') || 0;
my $to_xls = $input->param('exportXLS') || 0;

my ($template, $session, $t_params) = get_template_and_user({
    template_name => "adquisiciones/generatePresupuesto.tmpl",
    query => $input,
    type => "intranet",
    authnotrequired => 0,
    flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'ALTA', entorno => 'usuarios'},
    debug => 1,
});

my $template_name = "adquisiciones/generatePresupuesto.tmpl";

if($to_pdf){
	$template_name = "adquisiciones/listado_ejemplares_export.tmpl";
}elsif($to_xls){
	$template_name = "adquisiciones/presupuesto_export.tmpl";
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
    
        if($input->param('activo'.$i) eq 'checked'){
        
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
    
        if($input->param('activo'.$i) eq 'checked'){
        
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
#   exporta a XLS el presupuesto

    my $recomendaciones_activas        = C4::AR::Recomendaciones::getRecomendacionesActivas();   
    my $cant_recomendaciones           = (scalar(@$recomendaciones_activas));    
    my $i;
    my @resultsdata;
    
    for($i = 1; $i <= $cant_recomendaciones; $i++){
    
        if($input->param('activo'.$i) eq 'checked'){
        
            my %hash = (    titulo      => $input->param('libro'.$i),
                            cantidad    => $input->param('cantidad'.$i),
                            autor       => $input->param('autor'.$i), );
                      
            my %row = ( recomendacion => \%hash,);
            
            push(@resultsdata, \%row);
        }
    }
    
    #TODO ver como exportar a muchos proveedores, un excel por c/u ?    
    my $proveedores     = $input->param('proveedores');
    my @parts           = split(/\,/,$proveedores);
    

    #FIXME no exporta muchos archivos, exporta todo en uno mismo
    my $i;
    for($i = 0; $i < scalar(@parts); $i++){ 

        my $proveedor       = C4::AR::Proveedores::getProveedorInfoPorId(@parts[$i]);  
        my $tipo_proveedor  = C4::AR::Proveedores::isPersonaFisica(@parts[$i]);

        if($tipo_proveedor == 0){
            $t_params->{'proveedor'} = $proveedor->getRazonSocial();
            $t_params->{'proveedor_nombre'} = @parts[$i];
        }else{
            $t_params->{'proveedor'} = $proveedor->getNombre();
        }
    
        if(@resultsdata > 0){
            $t_params->{'resultsloop'} = \@resultsdata; 
        }
     
        print C4::AR::Auth::get_html_content( $template, $t_params, $session );
    }  

# asi anda para un solo archivo OK:    

    #FIXME exporta el xls en modo solo lectura

# if(@resultsdata > 0){
#            $t_params->{'resultsloop'} = \@resultsdata; 
#        }
    
        
#        print C4::AR::Auth::get_html_content( $template, $t_params, $session );

}else{
#   se muestra el template normal

    my $recomendaciones_activas   = C4::AR::Recomendaciones::getRecomendacionesActivas();

    if($recomendaciones_activas){
        my @resultsdata;
      
        for my $recomendacion (@$recomendaciones_activas){   
            my %row = ( recomendacion => $recomendacion, );
            push(@resultsdata, \%row);
        }

       $t_params->{'resultsloop'}= \@resultsdata; 
       
    }#END if($recomendaciones_activas)
    
    my $combo_proveedores         = &C4::AR::Utilidades::generarComboProveedoresMultiple();

    $t_params->{'combo_proveedores'}             = $combo_proveedores;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}
