#!/usr/bin/perl

#script to administer the categories table
#written 20/02/2002 by paul.poulain@free.fr

# ALGO :
# this script use an $op to know what to do.
# if $op is empty or none of the above values,
#	- the default screen is build (with all records, or filtered datas).
#	- the   user can clic on add, modify or delete record.
# if $op=add_form
#	- if primkey exists, this is a modification,so we read the $primkey record
#	- builds the add/modify form
# if $op=add_validate
#	- the user has just send datas, so we create/modify the record
# if $op=delete_form
#	- we show the record having primkey=$primkey and ask for deletion validation form
# if $op=delete_confirm
#	- we delete the record having primkey=$primkey


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

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from categories where (description like ?)");
	$sth->execute("$data[0]%");
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	   push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('description');
my $script_name="/cgi-bin/koha/admin/categorie.pl";
my $categorycode=$input->param('categorycode');
my $op = $input->param('op');

my ($template, $session, $t_params) = C4::Auth::get_template_and_user({
								template_name => "admin/categorie.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
			    				});

$t_params->{'script_name'}= $script_name;
$t_params->{'categorycode'}= $categorycode;
$t_params->{'searchfield'}= $searchfield;


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	$t_params->{'add_form'}= 1;
	
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($categorycode) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,issuelimit,reservefee,overduenoticerequired,borrowingdays from categories where categorycode=?");
		$sth->execute($categorycode);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}

	$t_params->{'description'}= $data->{'description'};
	$t_params->{'enrolmentperiod'}= $data->{'enrolmentperiod'};
	$t_params->{'upperagelimit'}= $data->{'upperagelimit'};
	$t_params->{'dateofbirthrequired'}= $data->{'dateofbirthrequired'};
	$t_params->{'enrolmentfee'}= $data->{'enrolmentfee'};
	$t_params->{'overduenoticerequired'}= $data->{'overduenoticerequired'};
	$t_params->{'issuelimit'}= $data->{'issuelimit'};
	$t_params->{'borrowingdays'}= $data->{'borrowingdays'};
	$t_params->{'reservefee'}= $data->{'reservefee'};
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	$t_params->{'add_validate'}= 1;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace categories (categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,issuelimit,reservefee,overduenoticerequired,borrowingdays) values (?,?,?,?,?,?,?,?,?,?)");
	$sth->execute(map { $input->param($_) } ('categorycode','description','enrolmentperiod','upperagelimit','dateofbirthrequired','enrolmentfee','issuelimit','reservefee','overduenoticerequired','borrowingdays'));
	$sth->finish;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	$t_params->{'delete_confirm'}= 1;

	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select count(*) as total from categoryitem where categorycode=?");
	$sth->execute($categorycode);
	my $total = $sth->fetchrow_hashref;
	$sth->finish;
	$t_params->{'total'}= $total->{'total'};
	
	my $sth2=$dbh->prepare("select categorycode,description,enrolmentperiod,upperagelimit,dateofbirthrequired,enrolmentfee,issuelimit,reservefee,overduenoticerequired,borrowingdays from categories where categorycode=?");
	$sth2->execute($categorycode);
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;
	if ($total->{'total'} >0) {
		$t_params->{'totalgtzero'}= 1;
	}

        $t_params->{'description'}             = $data->{'description'};
        $t_params->{'enrolmentperiod'}         = $data->{'enrolmentperiod'};
        $t_params->{'upperagelimit'}           = $data->{'upperagelimit'};
        $t_params->{'dateofbirthrequired'}     = $data->{'dateofbirthrequired'};
        $t_params->{'enrolmentfee'}            = $data->{'enrolmentfee'};
        $t_params->{'overduenoticerequired'}   = $data->{'overduenoticerequired'};
        $t_params->{'issuelimit'}              = $data->{'issuelimit'};
        $t_params->{'reservefee'}              = $data->{'reservefee'};
        $t_params->{'borrowingdays'}	       = $data->{'borrowingdays'};


													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	$t_params->{'delete_confirmed'} = 1;
	my $dbh = C4::Context->dbh;
	my $categorycode=uc($input->param('categorycode'));
	my $sth=$dbh->prepare("delete from categories where categorycode=?");
	$sth->execute($categorycode);
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
} else { # DEFAULT
	$t_params->{'else'}= 1;
	my $env;
	my @loop;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle = 'par';
	for (my $i=0; $i < $count; $i++){
		my %row = (categorycode => $results->[$i]{'categorycode'},
				description => $results->[$i]{'description'},
				enrolmentperiod => $results->[$i]{'enrolmentperiod'},
				upperagelimit => $results->[$i]{'upperagelimit'},
				dateofbirthrequired => $results->[$i]{'dateofbirthrequired'},
				enrolmentfee => $results->[$i]{'enrolmentfee'},
				overduenoticerequired => $results->[$i]{'overduenoticerequired'},
				issuelimit => $results->[$i]{'issuelimit'},
				reservefee => $results->[$i]{'reservefee'},
				borrowingdays => $results->[$i]{'borrowingdays'},
				clase => $toggle );	
		push @loop, \%row;
		if ( $toggle eq 'par' )
		{
			$toggle = 'impar';
		}
		else
		{
			$toggle = 'par';
		}
	}
	$t_params->{'loop'}= \@loop;



} #---- END $OP eq DEFAULT



C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

