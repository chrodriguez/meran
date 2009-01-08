#!/usr/bin/perl



# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA
#

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Estadisticas;
use C4::AR::Busquedas;

my $input = new CGI;

my ($template, $session, $t_params, $cookie) = get_template_and_user({
                                                                template_name => "reports/book-labels.tmpl",
                                                                query => $input,
                                                                type => "intranet",
                                                                authnotrequired => 0,
                                                                flagsrequired => {borrowers => 1},
                                                                debug => 1,
			    });

## FIXME ver que poner por defecto en los parametros de entrada
my  $orden=$input->param('orden')||'algo';
my  $op=$input->param('op')||'algo';
my  $barcode1=$input->param('barcode1')||'algo';
my  $barcode2=$input->param('barcode2')||'algo';
my  $bulk1=$input->param('bulk1')||'algo';
my  $bulk2=$input->param('bulk2')||'algo';
my  $bulkbegin=$input->param('bulkbegin')||'algo';
my  $ui= $input->param('ui_name') || C4::Context->preference("defaultUI");
my  $count=0;
my  $cantidad=0;
my  @results=();

# FIXME VER COMO CIERRAN LOS IF... NO ME GUSTA COMO QUEDO

if ($op eq 'pdf') {
#HAY QUE GENERAR EL PDF CON LOS CARNETS

        ($cantidad,@results)=  listaDeEjemplares($barcode1,$barcode2,$bulk1,$bulk2,$bulkbegin,$ui,1,"todos",$orden);
        my $pdf = batchBookLabelGenerator($cantidad,@results);

}
else{

    
    if ($op ne ''){
    
    #Inicializo el inicio y fin de la instruccion LIMIT en la consulta
            my $ini;
            my $pageNumber;
            my $cantR=cantidadRenglones();

            if ($input->param('renglones')){
                $cantR=$input->param('renglones');
            }
            
            if (($input->param('ini') eq "")){
                    $ini=0;
                    $pageNumber=1;
            } 
            else {
                    $ini= ($input->param('ini')-1)* $cantR;
                    $pageNumber= $input->param('ini');
                 }
            #FIN inicializacion
            
            
            ($cantidad,@results)= listaDeEjemplares($barcode1,$barcode2,$bulk1,$bulk2,$bulkbegin,$ui,$ini,$cantR,$orden);
            
            if ($cantR ne 'todos') {
                my @numeros= armarPaginasPorRenglones($cantidad,$pageNumber,$cantR);
                
                my $paginas = scalar(@numeros)||1;
                my $pagActual = $input->param('ini')||1;
                
                $t_params->{'paginas'}= $paginas;
                $t_params->{'actual'}= $pagActual;
                
                if ( $cantidad > $cantR ){#Para ver si tengo que poner la flecha de siguiente pagina o la de anterior
                        my $sig = $pagActual+1;
                        if ($sig <= $paginas){
                                $t_params->{'ok'}='1';
                                $t_params->{'sig'}= $sig;
                        }
                        if ($sig > 2 ){
                                my $ant = $pagActual-1;
                                $t_params->{'ok2'}= '1';
                                $t_params->{'ant'}= $ant;
                        }
                
                $t_params->{'numeros'}= \@numeros;
                $t_params->{'ini'}= $pagActual;
                }
        
           }

    
    my $ComboUI=C4::AR::Utilidades::generarComboUI();
    
    if ($op eq 'search'){
    #Se realiza la busqueda si al algun campo no vacio
        $t_params->{'RESULTSLOOP'}=\@results;
    }
    
    my $MINB=C4::Circulation::Circ2::getminbarcode($ui);
    my $MAXB=C4::Circulation::Circ2::getmaxbarcode($ui);
    my $MINS= signaturamax($ui);
    my $MAXS= signaturamin($ui);
    $t_params->{'cantidad'}=$cantidad;
    $t_params->{'unidades'}= $ComboUI;
    $t_params->{'ui'}= $ui;
    $t_params->{'orden'}= $orden;
    $t_params->{'barcode1'}= $barcode1;
    $t_params->{'barcode2'}= $barcode2;
    $t_params->{'MAXB'}= $MAXB;
    $t_params->{'MINB'}= $MINB;
    $t_params->{'bulk1'}= $bulk1;
    $t_params->{'bulk2'}= $bulk2;
    $t_params->{'MAXS'}= $MAXS;
    $t_params->{'MINS'}= $MINS;
    $t_params->{'bulkbegin'}= $bulkbegin;
    
   } 
    C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session, $cookie);
   
}
