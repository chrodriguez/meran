#!/usr/bin/perl
require Exporter;
use CGI;
use C4::AR::PdfGenerator;
use C4::Auth;
use C4::Interface::CGI::Output;
use Mail::Sendmail;
use C4::BookShelves;

my $query=new CGI;
my $cant=$query->param('num');
my %search;
my @fields = ('keyword', 'subject', 'author', 'illustrator', 'itemnumber', 'isbn', 'date-before', 'date-after', 'class', 'dewey', 'branch', 'title', 'abstract', 'publisher','subjectitems', 'virtual', 'authorid' );

foreach my $field (@fields) {
    $search{$field} = $query->param($field);
    if ($field eq 'keyword'){
        $search{$field} = $query->param('words') unless $search{$field};
    }
    }


#Para imprimir
	my  ($template, $borrowernumber, $cookie)
                = get_template_and_user({template_name => "opac-print.tmpl",
                             query => $query,
                             type => "opac",
                             authnotrequired => 1,
                             flagsrequired => {borrow => 1}
                             });



#Analiticas
my $analytical= $query->param('analytical');
$search{'analytical'}= $analytical;

$search{'ttype'} = $query->param('ttype');

my %env = (
        itemcount       => 1,   # If set to 1, &catalogsearch enumerates
                                # the results found and returns the number
                                # of items found, where they're located,
                                # etc.
        );

# Favoritos
my $from= $query->param('from');
my $bor= $query->param('borrower');

# Orden
my $orden;
if ($query->param('orden') eq ""){$orden='title'}
                                else {$orden=$query->param('orden')};
#
my $count; 
my @results;
if ($from ){
	($count, @results) = privateShelfs($bor,$cant,0);
	}
#
else{
($count, @results) = catalogsearch($borrowernumber,\%env,'opac',\%search,$cant,0,$orden);
	}
foreach my $res (@results) {
#     $res->{'firstbulk'} = &firstbulk($res->{'biblionumber'}); SE BORRO LA FUNCION VER!!!!!!!!  Hacer otra porque no servia ver si ya viene la signatura topografica en los datos
    my @aux=&getautor($res->{'author'});
    $res->{'id'}=$res->{'author'};
    $res->{'completo'}=$aux[0]->{'completo'};
    $res->{'nombre'}=$aux[0]->{'nombre'};
    $res->{'apellido'}=$aux[0]->{'apellido'};
}

if ($query->param('type') eq 'pdf') {#Para PDF
					searchGenerator('',@results);}
else{

if ($query->param('type') eq 'mail') {#Por Mail

my $mail=$query->param('mail');


my $branchname=C4::AR::Busquedas::getBranch($branch);
$branchname=$branchname->{'branchname'};
my $mailFrom=C4::Context->preference("mailFrom");
   $mailFrom =~ s/BRANCH/$branchname/;

my $mailSubject =C4::Context->preference("mailSubject");

my $mailMessage;
if ($from ){  $mailMessage='Favoritos:

';}
else{
 $mailMessage='Resultados obtenidos por la b'.chr(250).'squeda:

';
}

foreach my $res (@results) {
 $mailMessage .= $res->{'completo'}.' -- '.$res->{'title'}.' (Solicitar por '.$res->{'firstbulk'}.')

';}

$mailMessage .= $branchname;

my $subject;
if ($from){  $subject='Favoritos:';}
else{
 $subject='Resultados de la B'.chr(250).'squeda:';
}

  %mail = ( To      => $mail,
	    Subject => $subject,
            From    => $mailFrom,
            Message => $mailMessage
           );

  sendmail(%mail) or die $Mail::Sendmail::error;



 
 
my $input = new CGI;
if ($from){ print $input->redirect("opac-privateshelfs.pl");}
else{ print $input->redirect("opac-search.pl");}

		}
else{ #Para imprimir

my $resultsarray=\@results;
#($resultsarray) || (@$resultsarray=());

$template->param(SEARCH_RESULTS => $resultsarray,
		 numrecords => $cant);

output_html_with_http_headers $query, $cookie, $template->output;
}}
