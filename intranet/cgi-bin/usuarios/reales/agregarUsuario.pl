#!/usr/bin/perl


use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use C4::Members;
use Date::Manip;
use C4::Date;
use C4::AR::Busquedas;
use C4::AR::Referencias;

	my $input = new CGI;
	
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "usuarios/reales/agregarUsuario.tmpl",
				query => $input,
				type => "intranet",
				authnotrequired => 0,
				flagsrequired => {borrowers => 1},
				debug => 1,
				});


=item
 	my $member=$input->param('bornum');
 	my $data=C4::AR::Usuarios::getBorrower($member);

	my %flags = ('gonenoaddress' => ['gna', 'Direcci&oacute;n actualizada'],
				#'lost'          => ['lost', 'Perdido'],
				'debarred'      => ['debarred', 'Habilitado']);
				
	my @flagdata;
	foreach (keys(%flags)) {
	my $key = $_;
	my %row =  ('key'   => $key,
			'name'  => $flags{$key}[0],
			'html'  => $flags{$key}[1]);
	if ($data->{$key}) {
		$row{'yes'}=' checked';
		$row{'no'}='';
	} else {
		$row{'yes'}='';
		$row{'no'}=' checked';
	}
	push(@flagdata, \%row);
	}
=cut

	my ($categories,$labels)=C4::AR::Usuarios::obtenerCategorias();
	my $catcodepopup = CGI::popup_menu(-name=>'categorycode',
					-id => 'categorycode',
					-values=>$categories,
# 					-default=>$data->{'categorycode'},
					-labels=>$labels);

	my @documents = &C4::AR::Referencias::obtenerTiposDeDocumentos();
        my @documentdata;
	while (@documents) {
		my $doc = shift @documents;
		my %row = ('document' => $doc);
# 		if ($data->{'documenttype'} eq $doc) {
# 			$row{'selected'}=' selected';
# 		} else {
# 			$row{'selected'}='';
# 		}
		push(@documentdata, \%row);
	}

	my @branches;
	my @select_branch;
	my %select_branches;
	my $branches=C4::AR::Busquedas::getBranches();
	foreach my $branch (keys %$branches) {
		push @select_branch, $branch;
		$select_branches{$branch} = $branches->{$branch}->{'branchname'};
	}

# 	my $branchdefecto=$data->{'branchcode'};
# 	($branchdefecto ||($branchdefecto=(split("_",(split(";",$cookie))[0]))[1]));

	my $branchdefecto= C4::Context->preference("defaultbranch");
	#hasta aca y la linea adentro del pasaje por parametros a la CGIbranch

	my $CGIbranch=CGI::scrolling_list( 	-name     => 'branchcode',
						-id => 'branchcode',
						-values   => \@select_branch,
						-defaults  => $branchdefecto, #tambien agregado para que funcione
						-labels   => \%select_branches,
						-size     => 1,
						-multiple => 0 );



	$template->param(	
				documentloop     => \@documentdata,
# 				documentloop	=> \@documents,
# 				flagloop	=> \@flagdata,
				CGIbranch => $CGIbranch
		);
	

output_html_with_http_headers $input, $cookie, $template->output;

=item
my $type=$input->param('type') || '';
my $modify=$input->param('modify');
my $delete=$input->param('delete');
if ($delete){
	print $input->redirect("/cgi-bin/koha/members/deletemem.pl?member=$member");
}
elsif($type eq 'Mod'){
	my $dateformat = C4::Date::get_date_format();
	my $adress=$input->param('address');
	my $firstname=$input->param('firstname');
	my $surname= $input->param('surname');
	my $streetaddress= $input->param('streetaddress');
	my $zipcode = $input->param('zipcode');
	my $streetcity= $input->param('streetcity');
	my $dstreetcity= $input->param('dstreetcity');
	my $homezipcode = $input->param('homezipcode');
	my $city= $input->param('city');
	my $dcity=$input->param('dcity');
	my $phone= $input->param('phone');
	my $phoneday = $input->param('phoneday');
	my $emailaddress = $input->param('emailaddress');
	my $borrowernotes= $input->param('borrowernotes');
	my $documentnumber= $input->param('documentnumber');
	my $studentnumber= $input->param('studentnumber');
	my $dateenrolled= $input->param('dateenrolled');
	my $expiry = $input->param('expiry');
	my $cardnumber= $input->param('cardnumber');
	my $dateofbirth = $input->param('dateofbirth');

	$template->param(	type 		=> $type,
				member          => $member,
				address         => $adress,
				firstname       => $firstname,
				surname         => $surname,
				catcodepopup	=> $catcodepopup,
				streetaddress   => $streetaddress,
				zipcode 	=> $zipcode,
				streetcity      => $streetcity,
				dstreetcity     => $dstreetcity,
				homezipcode 	=> $homezipcode,
				city		=> $city,
				dcity           => $dcity,
				phone           => $phone,
				phoneday        => $phoneday,
				emailaddress    => $emailaddress,
				borrowernotes	=> $borrowernotes,
                                documentnumber   => $documentnumber,
				documentloop     => \@documentdata,
				studentnumber 	 =>$studentnumber,
				dateenrolled	=> $dateenrolled,
				expiry		=> $expiry,
				cardnumber	=> $cardnumber,
				dateofbirth	=> $dateofbirth,
				dateformat      => display_date_format($dateformat),
			        modify          => $modify,
				CGIbranch => $CGIbranch);

	# Curso de usuarios#
	if (C4::Context->preference("usercourse")){
		$template->param( 	course => 1 , 
					usercourse => $input->param('usercourse')||0);
		
	}
	####################


	output_html_with_http_headers $input, $cookie, $template->output;

}
else {  
# this else goes down the whole script
	if ($type eq 'Add'){
		$template->param( addAction => 1);
	} else {
		$template->param( addAction => 0);
	}

	
	# Curso de usuarios#
	if (C4::Context->preference("usercourse")){
		$template->param( course => 1);
		if ($data->{'usercourse'} != 'NULL') {  $template->param( usercourse => $data->{'usercourse'});}
		
	}
	####################


	if ($data->{'changepassword'} eq '0'){
		$template->param( updatepassword => '0');
	} else {
		$template->param( updatepassword => '1');
	}

	if ($type eq 'Add'){
		$template->param( updtype => 'I');
	} else {
		$template->param( updtype => 'M');
	}
	my $cardnumber=C4::Members::fixup_cardnumber($data->{'cardnumber'});
	if ($data->{'sex'} eq 'F'){
		$template->param(female => 1);
	}
	

	my @relationships = ('trabajo', 'familiar','amigo', 'vecino');

	my @relshipdata;
	while (@relationships) {
		my $relship = shift @relationships;
		my %row = ('relationship' => $relship);
		if ($data->{'altrelationship'} eq $relship) {
			$row{'selected'}=' selected';
		} else {
			$row{'selected'}='';
		}
		push(@relshipdata, \%row);
	}



	if ($modify){
	$template->param( modify => 1 );
	}

	my $dateformat = C4::Date::get_date_format();
	#Convert dateofbirth to correct format
	$data->{'dateofbirth'} = format_date($data->{'dateofbirth'},$dateformat);



$data->{'dcity'}=getNombreLocalidad($data->{'city'});
$data->{'dstreetcity'}=getNombreLocalidad($data->{'streetcity'});
#CGI::scrolling_list(-name     => 'streetcity',
                      #          -id => 'streetcity',
                      #          -values   => \@select_city,
                      #          -defaults  => $streetcitydefecto, #tambien agregado para que funcione
                      #          -labels   => \%select_cities,
                      #          -size     => 1,
                      #          -multiple => 0 );

	$template->param(	type 		=> $type,
				member          => $member,
				address         => $data->{'streetaddress'},
				firstname       => $data->{'firstname'},
				surname         => $data->{'surname'},
				othernames	=> $data->{'othernames'},
				initials	=> $data->{'initials'},
				catcodepopup	=> $catcodepopup,
				streetaddress   => $data->{'physstreet'},
				zipcode		=> $data->{'zipcode'},
				streetcity      => $data->{'streetcity'},
				dstreetcity     => $data->{'dstreetcity'},
				homezipcode 	=> $data->{'homezipcode'},
				city		=> $data->{'city'},
				dcity           => $data->{'dcity'},
				phone           => $data->{'phone'},
				phoneday        => $data->{'phoneday'},
				faxnumber       => $data->{'faxnumber'},
				emailaddress    => $data->{'emailaddress'},
				textmessaging   => $data->{'textmessaging'},
				contactname     => $data->{'contactname'},
				altphone        => $data->{'altphone'},
				altnotes	=> $data->{'altnotes'},
				borrowernotes	=> $data->{'borrowernotes'},
                                documentnumber   => $data->{'documentnumber'},
				documentloop     => \@documentdata,
				studentnumber => $data->{'studentnumber'},
				flagloop	=> \@flagdata,
				relshiploop	=> \@relshipdata,
				"title_".$data->{'title'} => " SELECTED ",
				dateenrolled	=> $data->{'dateenrolled'},
				expiry		=> $data->{'expiry'},
# cardnumber	=> $cardnumber, Esto es lo que estaba, ahora lo cambie porque no se mostraba el cardnumber cunado editas el usuario 
				cardnumber	=> $data->{'cardnumber'}, #esto es lo que agregue yo
				dateofbirth	=> $data->{'dateofbirth'},
				dateformat      => display_date_format($dateformat),
			        modify          => $modify,
				CGIbranch => $CGIbranch);
	

output_html_with_http_headers $input, $cookie, $template->output;


}
=cut