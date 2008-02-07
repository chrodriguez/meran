#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use Mail::Sendmail;
use C4::AR::UpdateData;
use C4::Auth;         # checkauth, getborrowernumber.
use C4::Context;
use C4::Koha;
use C4::Circulation::Circ2;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Date;

my $query = new CGI;

my ($template, $borrowernumber, $cookie) 
    = get_template_and_user({template_name => "opac-userupdate.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 0,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

# get borrower information ....
my ($borr, $flags) = getpatroninformation(undef, $borrowernumber);


# handle the new information....
# collect the form values and send an email.
my @fields = ('surname', 'firstname', 'phone', 'faxnumber', 'streetaddress','city', 'emailaddress');
my $update;
$update->{'borrowernumber'}=$borrowernumber;
my $updateemailaddress= C4::Context->preference('KohaAdminEmailAddress');
if ($updateemailaddress eq '') {
    warn "La preferencia KohaAdminEmailAddress no esta seteada. No se puede enviar la informacion de actualizacion de $borr->{'firstname'} $borr->{'surname'} (#$borrowernumber)\n";
    my($template) = get_template_and_user({template_name => "kohaerror.tmpl",
			     query => $query,
			     type => "opac",
			     authnotrequired => 1,
			     flagsrequired => {borrow => 1},
			     debug => 1,
			     });

    $template->param(errormessage => 'La preferencia KohaAdminEmailAddress no esta seteada. Por favor visite la biblioteca para actualizar sus datos');

    output_html_with_http_headers $query, $cookie, $template->output;
    exit;
}

if ( C4::Context->preference('CheckUpdateDataEnabled') == 'yes') {


if ($query->{'surname'}) {
    # get all the fields:
    my $message = <<"EOF";
El usuario  $borr->{'cardnumber'}
ha requerido cambiar sus datos personales.
Por favor chequee los cambios realizados:
EOF
    foreach my $field (@fields){
	my $newfield = $query->param($field);
	$message .= "$field : $borr->{$field}  -->  $newfield\n";
    	$update->{$field}=$newfield;
		
	}
    $message .= "\n\nGracias,\nKoha\n\n";
    my %mail = ( To      => $updateemailaddress ,
		 From    => $updateemailaddress ,
		 Subject => "Cambio de caracteristicas de usuario.",
		 Message => $message );
    if (sendmail %mail) {
# do something if it works....

	&updateopacborrower($update);  #Se actualiza el registro del usuario

	warn "Mail sent ok\n";
	print $query->redirect('/cgi-bin/koha/opac-user.pl');
	exit;
    } else {
# do something if it doesnt work....
        warn "Error sending mail: $Mail::Sendmail::error \n";
    }
}
}

$borr->{'dateenrolled'} = format_date($borr->{'dateenrolled'});
$borr->{'expiry'}       = format_date($borr->{'expiry'});
$borr->{'dateofbirth'}  = format_date($borr->{'dateofbirth'});
$borr->{'ethnicity'}    = fixEthnicity($borr->{'ethnicity'});


my @bordat;
$bordat[0] = $borr;

$template->param(BORROWER_INFO => \@bordat,
			     LibraryName => C4::Context->preference("LibraryName"),
);

#otra vez einar con Guarani

$template->param(updatedata=>checkUpdateData());


$template->param(pagetitle => "Actualizaci&oacute;n de datos personales");

output_html_with_http_headers $query, $cookie, $template->output;
