#!/usr/bin/perl

use strict;
use CGI;
use C4::Context;
use C4::Output;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use HTML::Template;

sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from issuetypes  where (description like ?) order by issuecode");
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
my $offset=$input->param('offset');
my $script_name="/cgi-bin/koha/admin/issuetypes.pl";
my $issuetype=$input->param('issuetype');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;
my ($template, $borrowernumber, $cookie)
    = get_template_and_user({template_name => "parameters/issuetypes.tmpl",
			     query => $input,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });



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
	#start the page and read in includes
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($issuetype) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select * from issuetypes where issuecode=?");
		$sth->execute($issuetype);
		$data=$sth->fetchrow_hashref;
		$sth->finish;

		$template->param(
                	description => $data->{'description'},
                        maxissues => $data->{'maxissues'},
			notforloan => $data->{'notforloan'},
			daysissues => $data->{'daysissues'},
			renew => $data->{'renew'},
			renewdays => $data->{'renewdays'},
			enabled => $data->{'enabled'},
			dayscanrenew => $data->{'dayscanrenew'}
		);


 
	}
		
	$template->param(issuetype => $issuetype);
;
													# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $query = "replace issuetypes	(issuecode,description,maxissues,renew,renewdays,daysissues,dayscanrenew,notforloan,enabled) values (";
	$query.= $dbh->quote($input->param('issuetype')).",";
	$query.= $dbh->quote($input->param('description')).",";
	$query.= $dbh->quote($input->param('maxissues')).",";
	$query.= $dbh->quote($input->param('renew')).",";
	$query.= $dbh->quote($input->param('renewdays')).",";
	$query.= $dbh->quote($input->param('daysissues')).",";	 
	$query.= $dbh->quote($input->param('dayscanrenew')).",";
	 
	if ($input->param('notforloan') ne 1) {
		$query.= "0,";
	} else {
		$query.= "1,";
	}
	
	if ($input->param('enabled') ne 1) {
		$query.= "0)";
	} else {
		$query.= "1)";
	}

	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=issuetypes.pl\"></html>";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;

	# Check both categoryitem and biblioitems, see Bug 199
	my $total = 0;
	   my $sth=$dbh->prepare("select count(*) as total from issues where issuecode=?");
	   $sth->execute($issuetype);
	   $total += $sth->fetchrow_hashref->{'total'};
	   $sth->finish;

	my $sth=$dbh->prepare("select * from issuetypes where issuecode=?");
	$sth->execute($issuetype);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;

	$template->param(issuetype => $issuetype,
		description => $data->{'description'},
		notforloan => $data->{'notforloan'},
		maxissues => $data->{'maxissues'},
		renew => $data->{'renew'},
		renewdays => $data->{'renewdays'},
		daysissues => $data->{'daysissues'},
		dayscanrenew => $data->{'dayscanrenew'},
		total => $total
	);
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;
	my $issuetype=uc($input->param('issuetype'));
	my $sth=$dbh->prepare("delete from issuetypes where issuecode=?");
	$sth->execute($issuetype);
	$sth->finish;

	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=issuetypes.pl\"></html>";
	exit;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my $toggle='par';
	my @loop_data;
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
		my %row_data;
		if ($toggle eq 'par'){
			$row_data{clase}='impar';
			$toggle='impar';
		} else {
			$row_data{clase}='par';
			$toggle='par';
		}
		$row_data{issuetype} = $results->[$i]{'issuecode'};
		$row_data{description} = $results->[$i]{'description'};
		$row_data{maxissues} = $results->[$i]{'maxissues'};
		$row_data{notforloan} = $results->[$i]{'notforloan'};
		$row_data{daysissues} = $results->[$i]{'daysissues'};
		$row_data{renew} = $results->[$i]{'renew'};
		$row_data{renewdays} = $results->[$i]{'renewdays'};
		$row_data{dayscanrenew} = $results->[$i]{'dayscanrenew'};
		$row_data{enabled} = $results->[$i]{'enabled'};
		 
		push(@loop_data, \%row_data);
	}
	$template->param(loop => \@loop_data);
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$template->param(previous => "$script_name?offset=".$prevpage);
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$template->param(next => "$script_name?offset=".$nextpage);
	}
} #---- END $OP eq DEFAULT
output_html_with_http_headers $input, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
