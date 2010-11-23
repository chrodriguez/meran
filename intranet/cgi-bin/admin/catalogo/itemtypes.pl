#!/usr/bin/perl

#written 20/02/2002 by paul.poulain@free.fr
# This software is placed under the gnu General Public License, v2 (http://www.gnu.org/licenses/gpl.html)


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


# TODO esto es una MIERDA hay q arreglarlo
sub StringSearch  {
	my ($env,$searchstring,$type)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my @data=split(' ',$searchstring);
	my $count=@data;
	my $sth=$dbh->prepare("Select * from itemtypes  where (description like ?) order by itemtype");
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
my $script_name="/cgi-bin/koha/admin/itemtypes.pl";
my $itemtype=$input->param('itemtype');
my $pagesize=20;
my $op = $input->param('op');
$searchfield=~ s/\,//g;

my ($template, $session, $t_params) = C4::Auth::get_template_and_user({
						template_name => "admin/itemtypes.tmpl",
						query => $input,
						type => "intranet",
						authnotrequired => 0,
						flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
						debug => 1,
			    });

#Matias: Esta habiltada la Biblioteca Virtual?
my $virtuallibrary=C4::AR::Preferencias->getValorPreferencia("virtuallibrary");
$t_params->{'virtuallibrary'}= $virtuallibrary;
#


# FIXME VER ESTE IF!!!!!!!!!!!!!!!!!!!!!!!!!!
if ($op) {
    $t_params->{'script_name'}= $script_name;
    $t_params->{$op}= 1; # we show only the TMPL_VAR names $op
} else {
    $t_params->{'script_name'}= $script_name;
	else           => 1; # we show only the TMPL_VAR names $op
}
################## ADD_FORM ##################################
# called by default. Used to create form to add or  modify a record
if ($op eq 'add_form') {
	#start the page and read in includes
	#---- if primkey exists, it's a modify action, so read values to modify...
	my $data;
	if ($itemtype) {
		my $dbh = C4::Context->dbh;
		my $sth=$dbh->prepare("select itemtype,description,loanlength,renewalsallowed,rentalcharge,notforloan,search,detail from itemtypes where itemtype=?");
		$sth->execute($itemtype);
		$data=$sth->fetchrow_hashref;
		$sth->finish;

		$t_params->{'description'}= $data->{'description'};
                $t_params->{'loanlength'}= $data->{'loanlength'};
                $t_params->{'renewalsallowed'}= $data->{'renewalsallowed'};
                $t_params->{'rentalcharge'}= $data->{'rentalcharge'};
                $t_params->{'notforloan'}= $data->{'notforloan'};
                $t_params->{'search'}= $data->{'search'};
                $t_params->{'detail'}= $data->{'detail'}; #Para mod. el det.	


#Matias: Biblioteca Virtual
                if ($virtuallibrary) {
                                my $dbh = C4::Context->dbh;
                                my $sth=$dbh->prepare("select * from virtual_itemtypes where itemtype=?");
                                $sth->execute($itemtype);
                                $data=$sth->fetchrow_hashref;
                                $sth->finish;
                }
                
                if($data){
                    $t_params->{'virtual'}= 1;
                    $data->{'requesttype'} => 1;
                }
            #
            }
        $t_params->{'itemtype'}= $itemtype;
                                                                                                                # END $OP eq ADD_FORM
################## ADD_VALIDATE ##################################
# called by add_form, used to insert/modify data in DB
} elsif ($op eq 'add_validate') {
	my $dbh = C4::Context->dbh;
	my $query = "replace itemtypes (itemtype,description,loanlength,renewalsallowed,rentalcharge,search,notforloan) values (";
	$query.= $dbh->quote($input->param('itemtype')).",";
	$query.= $dbh->quote($input->param('description')).",";
	$query.= $dbh->quote($input->param('loanlength')).",";
	if ($input->param('renewalsallowed') ne 1) {
		$query.= "0,";
	} else {
		$query.= "1,";
	}


#Matias: Biblioteca Virtual
my $data;
  if ($virtuallibrary) {
	my $virtual=$input->param('virtual');
	if ($virtual eq 1){#Se Actualiza
		my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("replace virtual_itemtypes (itemtype,requesttype) values (? , ?)");
                $sth->execute($input->param('itemtype') , $input->param('requesttype'));
              $data=$sth->fetchrow_hashref;
                $sth->finish;
                }else { #Se Borra 
		 my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("delete from  virtual_itemtypes where itemtype = ? ");
                $sth->execute($input->param('itemtype'));
                $sth->finish;
			}
		
		}
#
	   $query.= $dbh->quote($input->param('rentalcharge')).",";
	 $query.= $dbh->quote($input->param('search')).",";
	 
	if ($input->param('notforloan') ne 1) {
		$query.= "0)";
	} else {
		$query.= "1)";
	}
	
	
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=itemtypes.pl\"></html>";
	exit;
													# END $OP eq ADD_VALIDATE
################## DELETE_CONFIRM ##################################
# called by default form, used to confirm deletion of data in DB
} elsif ($op eq 'delete_confirm') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;

	# Check both categoryitem and biblioitems, see Bug 199
	my $total = 0;
	for my $table ('categoryitem', 'biblioitems') {
	   my $sth=$dbh->prepare("select count(*) as total from $table where itemtype=?");
	   $sth->execute($itemtype);
	   $total += $sth->fetchrow_hashref->{'total'};
	   $sth->finish;
	}

	my $sth=$dbh->prepare("select itemtype,description,loanlength,renewalsallowed,rentalcharge,search from itemtypes where itemtype=?");
	$sth->execute($itemtype);
	my $data=$sth->fetchrow_hashref;
	$sth->finish;

#Matias: Biblioteca Virtual
my $datat;
  if ($virtuallibrary) {
                my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("select * from virtual_itemtypes where itemtype=?");
                $sth->execute($itemtype);
                $datat=$sth->fetchrow_hashref;
                $sth->finish;
                }

                if($datat){
                        $t_params->{'virtual'}= 1;
                        $datat->{'requesttype'} => 1;
                }
#


	$t_params->{'itemtype'}= $itemtype;
        $t_params->{'description'}= $data->{'description'};
        $t_params->{'loanlength'}= $data->{'loanlength'};
        $t_params->{'renewalsallowed'}= $data->{'renewalsallowed'};
        $t_params->{'rentalcharge'}= $data->{'rentalcharge'};
        $t_params->{'search'}= $data->{'search'};
        $t_params->{'total'}= $total;
													# END $OP eq DELETE_CONFIRM
################## DELETE_CONFIRMED ##################################
# called by delete_confirm, used to effectively confirm deletion of data in DB
} elsif ($op eq 'delete_confirmed') {
	#start the page and read in includes
	my $dbh = C4::Context->dbh;
	my $itemtype=uc($input->param('itemtype'));
	my $sth=$dbh->prepare("delete from itemtypes where itemtype=?");
	$sth->execute($itemtype);
	$sth->finish;

#Matias: Biblioteca Virtual
  if ($virtuallibrary) {#Se Borra
                 my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("delete from  virtual_itemtypes where itemtype = ? ");
                $sth->execute($input->param('itemtype'));
                $sth->finish;
                }
#


# FIXME 
	print "Content-Type: text/html\n\n<META HTTP-EQUIV=Refresh CONTENT=\"0; URL=itemtypes.pl\"></html>";
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
		$row_data{itemtype} = $results->[$i]{'itemtype'};
		$row_data{description} = $results->[$i]{'description'};
		$row_data{loanlength} = $results->[$i]{'loanlength'};
		$row_data{renewalsallowed} = $results->[$i]{'renewalsallowed'};
		$row_data{rentalcharge} = $results->[$i]{'rentalcharge'};
		$row_data{search} = $results->[$i]{'search'};
		$row_data{detail} = $results->[$i]{'detail'};
#Matias: Biblioteca Virtual
  	  if ($virtuallibrary) {
		my $data;
                my $dbh = C4::Context->dbh;
                my $sth=$dbh->prepare("select * from  virtual_itemtypes where itemtype= ? ;");
                $sth->execute($results->[$i]{'itemtype'});
                $data=$sth->fetchrow_hashref;
                $sth->finish;
		my $ty="NO";
		if ($data->{'requesttype'} eq 'print'){$ty='Para Imprimir';}
		elsif ($data->{'requesttype'} eq 'copy'){$ty='Para Copiar';}
		$row_data{requesttype} = $ty;
                }

#
		push(@loop_data, \%row_data);
	}
	$t_params->{'loop'}= \@loop_data;
	if ($offset>0) {
		my $prevpage = $offset-$pagesize;
		$t_params->{'previous'}= "$script_name?offset=".$prevpage;
	}
	if ($offset+$pagesize<$count) {
		my $nextpage =$offset+$pagesize;
		$t_params->{'next'}= "$script_name?offset=".$nextpage;
	}
} #---- END $OP eq DEFAULT

C4::Auth::output_html_with_http_headers($template, $t_params, $session);

# Local Variables:
# tab-width: 4
# End:
