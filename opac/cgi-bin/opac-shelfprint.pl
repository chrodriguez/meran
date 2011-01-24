#!/usr/bin/perl
require Exporter;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Auth;

use Mail::Sendmail;
use C4::BookShelves;
use C4::AR::Utilidades;

my $query=new CGI;
my $cant=$query->param('num');

my $env;

# Favoritos
my $from= $query->param('from');
my $bor= $query->param('borrower');
my $shelfnumber;
my $count; 
my @results;

if ($from eq 'shelfsContents'){ #Es sobre el contenido del EV
my $env;
my $type='public';
 $shelfnumber=$query->param('shelfnumber');
	 my ($count,%bitemlist) = GetShelfContents($env, $type,$shelfnumber);
	
        my @key=sort { noaccents($bitemlist{$a}->{'title'} ) cmp noaccents($bitemlist{$b}->{'title'} ) } keys(%bitemlist);
  
        my $bibnum;
        foreach my $element (@key) {
                my %line;
#                 $line{'firstbulk'} = &firstbulk($bitemlist{$element}->{'biblioitemnumber'}); SE BORRO LA FUNCION!!!!! Hacer otra porque no servia ver si ya viene la signatura topografica en los datos
		$line{'title'}=$bitemlist{$element}->{'title'};
                $line{'author'}=$bitemlist{$element}->{'completo'};
                $line{'place'}=$bitemlist{$element}->{'place'};
                $line{'editors'}=$bitemlist{$element}->{'editors'};
                push (@results, \%line);
			}



}
else { #Es sobre el resultado de una busqueda de EV
my $nameShelf = $query->param('search');

  (%shelflist) = &getbookshelfLike($nameShelf, 0,$cant);
  ($count)=      &getbookshelfLikeCount($nameShelf);


my @key=sort { noaccents($shelflist{$a}->{'shelfname'}) cmp noaccents($shelflist{$b}->{'shelfname'}) } keys(%shelflist);
foreach my $element (@key) {
                my %line;
                $line{'shelf'}=$element;
                $line{'numberparent'}=$shelflist{$element}->{'numberparent'};#los datos del padre, sirve para la busqueda
                $line{'nameparent'}=$shelflist{$element}->{'nameparent'};#los datos del padre,sirve para la busqueda
                $line{'shelfname'}=$shelflist{$element}->{'shelfname'};
                $line{'shelfbookcount'}=$shelflist{$element}->{'count'};
                $line{'countshelf'}=$shelflist{$element}->{'countshelf'} ;

                push (@results, \%line);
}
}



if ($query->param('type') eq 'pdf') {#Para PDF
	if ($from eq 'shelfsContents'){shelfContentsGenerator($query->param('shelfname'),@results);}	
				else{searchShelfGenerator(@results);}
	}
else{

if ($query->param('type') eq 'mail') {#Por Mail

my $mail=$query->param('mail');

my $branchname=C4::AR::Busquedas::getBranch($branch);
$branchname=$branchname->{'branchname'};
my $mailFrom=C4::AR::Preferencias->getValorPreferencia("mailFrom");
   $mailFrom =~ s/BRANCH/$branchname/;

my $mailSubject =C4::AR::Preferencias->getValorPreferencia("mailSubject");

my $mailMessage;

if ($from eq 'shelfsContents'){#Contenido
 $mailMessage='Contenido del Estante Virtual: '.$query->param('shelfname').'

';
foreach my $res (@results) {
 $mailMessage .= $res->{'author'}.' '.$res->{'title'}.' (Solicitar por '.$res->{'firstbulk'}.')

';}

	}
else{#Resultado de un busqueda
 $mailMessage='Resultados obtenidos por la b'.chr(250).'squeda:

';

foreach my $res (@results) {
	if ($res->{'nameparent'} ne ''){
 $mailMessage .= $res->{'nameparent'}.' / '.$res->{'shelfname'}.'

';}
else{ $mailMessage .= $res->{'shelfname'}.'

';}
}
}

$mailMessage .= $branchname;

my $subject;
 if ($from eq 'shelfsContents'){$subject='Contenido del Estante Virtual: '.$query->param('shelfname');}
else{$subject='Resultados de la B'.chr(250).'squeda:';}

  %mail = ( To      => $mail,
	    Subject => $subject,
            From    => $mailFrom,
            Message => $mailMessage
           );

  sendmail(%mail) or die $Mail::Sendmail::error;



 
 
my $input = new CGI;
if ($from eq 'shelfsContents')#Vuelve al estante
{ print $input->redirect("opac-shelves.pl?viewshelf=$shelfnumber");}
else{ print $input->redirect("opac-shelves.pl?viewShelfItems=$nameShelf&startfrom=0");}
		
}
else{ #Para imprimir

if ($from eq 'shelfsContents') #Contenido del estante
{
 my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "opac-shelfcontentprint.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                             });




my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

$template->param(SEARCH_RESULTS => $resultsarray,
                 shelfname =>$query->param('shelfname'));

output_html_with_http_headers $cookie, $template->output;

}
else { #Resultado de Busqueda
	my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "opac-shelfprint.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                             });




my $resultsarray=\@results;
($resultsarray) || (@$resultsarray=());

$template->param(SEARCH_RESULTS => $resultsarray,
		 numrecords => $cant,
		 viewShelfItems =>$nameShelf);

output_html_with_http_headers $cookie, $template->output;
}}}
