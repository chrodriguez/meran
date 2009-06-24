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
	my $sth=$dbh->prepare("Select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where (tagfield >= ?) order by tagfield");
	$sth->execute($data[0]);
	my @results;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
$searchfield=0 unless $searchfield;
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/marctagstructure.pl";

my $dbh = C4::Context->dbh;

my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "admin/marctagstructure.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			     debug => 1,
			     });
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

if ($op) {
$template->param(script_name => $script_name,
						$op              => 1); # we show only the TMPL_VAR names $op
} else {
$template->param(script_name => $script_name,
						else              => 1); # we show only the TMPL_VAR names $op
}

################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($searchfield) {
		my $sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where tagfield=?");
		$sth->execute($searchfield);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	my $sth = $dbh->prepare("select distinct category from authorised_values");
	$sth->execute;
	my @authorised_values;
	push @authorised_values,"";
	while ((my $category) = $sth->fetchrow_array) {
		push @authorised_values, $category;
	}
	my $authorised_value  = CGI::scrolling_list(-name=>'authorised_value',
			-values=> \@authorised_values,
			-size=>1,
			-multiple=>0,
			-default => $data->{'authorised_value'},
 			class =>"inputFontNormal",
			);

	if ($searchfield) {
		$template->param(action => "Modify tag",
								searchfield => "<input type=\"hidden\" name=\"tagfield\" value=\"$searchfield\" />$searchfield");
		$template->param('heading-modify-tag-p' => 1);
	} else {
		$template->param(action => "Add tag",
								searchfield => "<input type=\"text\" name=\"tagfield\" size=\"5\" maxlength=\"3\" />");
		$template->param('heading-add-tag-p' => 1);
	}
	$template->param('use-heading-flags-p' => 1);
	$template->param(liblibrarian => $data->{'liblibrarian'},
							libopac => $data->{'libopac'},
							repeatable => CGI::checkbox('repeatable',$data->{'repeatable'}?'checked':'',1,''),
							mandatory => CGI::checkbox('mandatory',$data->{'mandatory'}?'checked':'',1,''),
							authorised_value => $authorised_value,
							);
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace marc_tag_structure (tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value) values (?,?,?,?,?,?)");
	my $tagfield       =$input->param('tagfield');
	my $liblibrarian  = $input->param('liblibrarian');
	my $libopac       =$input->param('libopac');
	my $repeatable =$input->param('repeatable');
	my $mandatory =$input->param('mandatory');
	my $authorised_value =$input->param('authorised_value');
	unless (C4::Context->config('demo') eq 1) {
		$sth->execute($tagfield,
							$liblibrarian,
							$libopac,
							$repeatable?1:0,
							$mandatory?1:0,
							$authorised_value
							);
	}
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=marctagstructure.pl?tagfield=$tagfield\"></html>";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select tagfield,liblibrarian,libopac,repeatable,mandatory,authorised_value from marc_tag_structure where tagfield=?");
	$sth->execute($searchfield);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;
	$template->param(liblibrarian => $data->{'liblibrarian'},
							searchfield => $searchfield,
							);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	my $dbh = C4::Context->dbh;
	unless (C4::Context->config('demo') eq 1) {
		$dbh->do("delete from marc_tag_structure where tagfield='$searchfield'");
		$dbh->do("delete from marc_subfield_structure where tagfield='$searchfield'");
	}
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	if  ($searchfield ne '') {
		 $template->param(searchfield => "<p>Ha buscado por <strong>$searchfield<strong></p>");
	}
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle='par';
	my @loop_data = ();
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
	  	if ($toggle eq 'par'){
			$toggle='impar';
	  	} else {
			$toggle='par';
	  	}
		my %row_data;  # get a fresh hash for the row data
		$row_data{tagfield} = $results->[$i]{'tagfield'};
		$row_data{liblibrarian} = $results->[$i]{'liblibrarian'};
		$row_data{repeatable} = $results->[$i]{'repeatable'};
		$row_data{mandatory} = $results->[$i]{'mandatory'};
		$row_data{authorised_value} = $results->[$i]{'authorised_value'};
		$row_data{subfield_link} ="marc_subfields_structure.pl?tagfield=".$results->[$i]{'tagfield'};
		$row_data{edit} = "$script_name?op=add_form&amp;searchfield=".$results->[$i]{'tagfield'};
		$row_data{delete} = "$script_name?op=delete_confirm&amp;searchfield=".$results->[$i]{'tagfield'};
		$row_data{clase} = $toggle;
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(isprevpage => $offset,
						prevpage=> $prevpage,
						searchfield => $searchfield,
						script_name => $script_name,
		 );
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(nextpage =>$nextpage,
						searchfield => $searchfield,
						script_name => $script_name,
		);
	}
} #---- END $OP eq DEFAULT

$template->param(loggeninuser => $loggedinuser);
output_html_with_http_headers $input, $cookie, $template->output;
