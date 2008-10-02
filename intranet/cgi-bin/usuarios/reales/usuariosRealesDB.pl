#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use JSON;

my $input = new CGI;

my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $tipoAccion= $obj->{'tipoAccion'}||"";


=item
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "usuarios/reales/cambiar-password.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {borrowers => 1},
			     debug => 1,
			     });

my $flagsrequired;
$flagsrequired->{borrowers}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);

my $member=$input->param('member');
my %env;

my ($bor,$flags)=getpatroninformation(\%env, $member,'');
my $newpassword = $input->param('newpassword');

if ( $newpassword ) {
	my $digest=md5_base64($input->param('newpassword'));
	my $uid = $input->param('newuserid');
	my $dbh=C4::Context->dbh;
    	#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
    	#Then we need to tell the user and have them create a new one.
    	my $sth2=$dbh->prepare("select * from borrowers where userid=? and borrowernumber != ?");
	$sth2->execute($uid,$member);

	if ( ($uid ne '') && ($sth2->fetchrow) ) {
		#The userid exists so we should display a warning.
		my $warn = 1;
        	$template->param( warn => $warn,
			        othernames => $bor->{'othernames'},
                        	surname     => $bor->{'surname'},
                        	firstname   => $bor->{'firstname'},
                        	userid      => $bor->{'userid'},
                        	defaultnewpassword => $newpassword );
    	 } else {
		#Everything is good so we can update the information.
		my $sth=$dbh->prepare("update borrowers set userid=?, password=? where borrowernumber=?");
    		$sth->execute($uid, $digest, $member);
		
		my $sth3=$dbh->prepare("select cardnumber from borrowers where borrowernumber = ?");
        	$sth3->execute($member);

		if (my $cardnumber= $sth3->fetchrow) {
			#Se actualiza el ldap
			if (addupdateldapuser($dbh,$cardnumber,$digest,$template)){
				$template->param(errorldap => 1);
			  }
	 	}

		$template->param(newpassword => $newpassword);
	}

} else {
#if !( $newpassword ) 
    	my $userid = $bor->{'userid'};
    	my $chars='abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    	my $length=int(rand(2))+4;
    	my $defaultnewpassword='';
    	for (my $i=0; $i<$length; $i++) {
	$defaultnewpassword.=substr($chars, int(rand(length($chars))),1);
   	}
	$template->param(	othernames => $bor->{'othernames'},
				surname     => $bor->{'surname'},
				firstname   => $bor->{'firstname'},
				userid      => $bor->{'userid'},
				defaultnewpassword => $defaultnewpassword );
}

$template->param( member => $member );

output_html_with_http_headers $input, $cookie, $template->output;
=cut


if($tipoAccion eq "CAMBIAR_PASSWORD"){

	my %params;
	$params{'usuario'}= $obj->{'usuario'};
	$params{'newpassword'}= $obj->{'newpassword'};
	$params{'newpassword1'}= $obj->{'newpassword1'};

	my ($error,$codMsg,$message)= C4::AR::Usuarios::t_cambiarPassword(\%params);

	my %infoOperacion = (
				codMsg	=> $codMsg,
				error 	=> $error,
				message => $message,
	);
	
	my $infoOperacionJSON=to_json \%infoOperacion;
	
	print $input->header;
	print $infoOperacionJSON;

} #end if($tipoAccion eq "CAMBIAR_PASSWORD")
