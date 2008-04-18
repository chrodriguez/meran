#!/usr/bin/perl

use strict;
require Exporter;# contains gettemplate
use CGI;
use C4::AR::Utilidades;
use C4::AR::AnalysisBiblio;
#use C4::Output;
#use C4::Interface::CGI::Output;


my $input = new CGI;
my $param=$input->param('param');
my $tipo=$input->param('tipo');
my $textout='';
my $rand=$input->param('rand');
my @result;
#se setean la cant de caracteres que se deben igresar para que se muestre la lista de autores
if(length($param) gt 0){ 
	if ($tipo eq 'author'||$tipo eq 'additionalauthors'||$tipo eq 'colaboradores'||$tipo eq 'analysisauthor'){ 
		@result=&obtenerReferencia($param);
	}
# busca temas

 	elsif ($tipo eq 'subjectheadings'){
 		@result=&obtenerTemas($param);
 	}
 	elsif ($tipo eq 'publishercode'){
 		@result=&obtenerEditores($param);
 	}
  	elsif ($tipo eq 'keywords'){
		@result=&getKeywordsLike($param);
 	}
	my $selectedString="selectedSmartInputItem";
 	foreach my $i (@result){
    		#my $dato = $i;	
    		$textout.= $i.'#';
    		#$textout .= '<p class="matchedSmartInputItem'. $selectedString  .'">' .$i . '</p>';
    		$selectedString="";
  #siw.matchCollection[i].value.replace(/\{ */gi,"&lt;").replace(/\} */gi,"&gt;")
    #"<p><strong>".$i."</strong></p>"; 
 	}
#Miguel - esta linea creo q no se usa
  #$textout= substr($textout,0,length($textout)-1);
 	if (scalar(@result) == 0){ $textout.=''}

} else {
	$textout='';
} 

print "Content-type: text/html\n\n";
print $textout;
