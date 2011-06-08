#!/usr/bin/perl

#script to administer the branches table
#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)

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

use strict;
use CGI;
use C4::AR::Auth;


sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select host,port,db,userid,password,name,id,checked,rank,syntax from z3950servers where (name like ?) order by rank,name");
	$sth->execute("$data[0]\%");
	my @results;
	while (my $data=$sth->fetchrow_hashref) {
	    push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	$dbh->disconnect;
	return (scalar(@results),\@results);
}

my $input = new CGI;
my $searchfield=$input->param('searchfield');
my $offset=$input->param('offset');
my $script_name= C4::AR::Utilidades::getUrlPrefix()."/admin/catalogo/MARC/z3950servers.pl";

my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $session, $t_params)= get_template_and_user({template_name => "admin/z3950/z3950servers.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
                                    debug => 1,
                                    });

$t_params->{'script_name'} = $script_name;
$t_params->{'searchfield'} = $searchfield;

#FIXME: sacar SQL!!


################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
    $t_params->{'add_form'} = 1;
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($searchfield) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select host,port,db,userid,password,name,id,checked,rank,syntax from z3950servers where (name = ?) order by rank,name");
		$sth->execute($searchfield);
		$data=$sth->fetchrow_hashref;
		$sth->finish;
	}
	
        $t_params->{'host'} = $data->{'host'};
        $t_params->{'port'} = $data->{'port'};
        $t_params->{'db'} = $data->{'db'};
        $t_params->{'userid'} = $data->{'userid'};
        $t_params->{'password'} = $data->{'password'};
        $t_params->{'checked'} = $data->{'checked'};
        $t_params->{'rank'} = $data->{'rank'};

# END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
    $t_params->{'add_validate'} = 1;
	
	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("select * from z3950servers where name=?");
	$sth->execute($input->param('searchfield'));
	if ($sth->rows) {
		$sth=$dbh->prepare("update z3950servers set host=?, port=?, db=?, userid=?, password=?, name=?, checked=?, rank=?,syntax=? where name=?");
		$sth->execute($input->param('host'),
		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
			 $input->param('syntax'),
		      $input->param('searchfield'),
		      );
	} else {
		$sth=$dbh->prepare("insert into z3950servers (host,port,db,userid,password,name,checked,rank,syntax) values (?, ?, ?, ?, ?, ?, ?, ?,?)");
		$sth->execute($input->param('host'),
		      $input->param('port'),
		      $input->param('db'),
		      $input->param('userid'),
		      $input->param('password'),
		      $input->param('searchfield'),
		      $input->param('checked'),
		      $input->param('rank'),
			 $input->param('syntax'),
		      );
	}
	$sth->finish;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
    $t_params->{'delete_confirm'} = 1;
	my $dbh = C4::Context->dbh;

	my $sth2=$dbh->prepare("select host,port,db,userid,password,name,id,checked,rank,syntax from z3950servers where (name = ?) order by rank,name");
	$sth2->execute($searchfield);
	my $data=$sth2->fetchrow_hashref;
	$sth2->finish;

        $t_params->{'host'} = $data->{'host'};
        $t_params->{'port'} = $data->{'port'};
        $t_params->{'db'} = $data->{'db'};
        $t_params->{'userid'} = $data->{'userid'};
        $t_params->{'password'} = $data->{'password'};
        $t_params->{'checked'} = $data->{'checked'};
        $t_params->{'rank'} = $data->{'rank'};
        $t_params->{'id'} = $data->{'id'};

													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
    $t_params->{'delete_confirmed'} = 1;

	my $dbh=C4::Context->dbh;
	my $sth=$dbh->prepare("delete from z3950servers where id=?");
	$sth->execute($searchfield);
	$sth->finish;
													# END $OP eq DELETE_CONFIRMED
################## DEFAULT ##################################
} else { # DEFAULT
    $t_params->{'else'} = 1;

	my $env;
	my ($count,$results)=StringSearch($env,$searchfield,'web');
	my @loop;
	my $toggle = 'par';
	for (my $i=$offset; $i < ($offset+$pagesize<$count?$offset+$pagesize:$count); $i++){
			
		my $urlsearchfield=$results->[$i]{name};
		$urlsearchfield=~s/ /%20/g;
		my %row	= ( name => $results->[$i]{'name'},
			host => $results->[$i]{'host'},
			port => $results->[$i]{'port'},
			db => $results->[$i]{'db'},
			userid =>$results->[$i]{'userid'},
			password => ($results->[$i]{'password'}) ? ('#######') : ('&nbsp;'),
			checked => $results->[$i]{'checked'},
			rank => $results->[$i]{'rank'},
			syntax => $results->[$i]{'syntax'},
			clase => $toggle);
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
    $t_params->{'loop'} = \@loop;
	if ($offset>0) {
        $t_params->{'offsetgtzero'} = 1;
        $t_params->{'prevpage'} =  $offset-$pagesize;

	}
	if ($offset+$pagesize<$count) {
        $t_params->{'ltcount'} = 1;
        $t_params->{'nextpage'} =  $offset+$pagesize;
	}
} #---- END $OP eq DEFAULT

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
