#!/usr/bin/perl

# $Id: unimarc_field_60X.pl,v 1.2.2.1 2004/01/08 17:31:35 slef Exp $

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
use C4::AR::Auth;
use CGI;
use C4::AR::Authorities;

sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "100".(int(rand(100000))+1);
my $res="
<script>
function Focus$function_name(subfield_managed) {
return 1;
}

function Blur$function_name(subfield_managed) {
	return 1;
}

function Clic$function_name(index) {
	defaultvalue=document.f.field_value[index].value;
	newin=window.open(\"../plugin_launcher.pl?plugin_name=unimarc_field_60X.pl&index=\"+index+\"&result=\"+defaultvalue,\"unimarc 700\",'width=700,height=300,toolbar=false,scrollbars=yes');

}
</script>
";

return ($function_name,$res);
}
sub plugin {
	my ($input) = @_;
	my %env;
	my $dbh = C4::Context->dbh;
	my $index= $input->param('index');
	my $result= $input->param('result');
	my $search_string= $input->param('search_string');
	my $op = $input->param('op');
	my $id = $input->param('id');
	my $insert = $input->param('insert');
	my %stdlib;
	my $select_list;
	if ($op eq "add") {
		newauthority($dbh,'NC',$insert,$insert,'',1,'');
		$search_string=$insert;
	}
	if ($op eq "select") {
		my $sti = $dbh->prepare("select stdlib from bibliothesaurus where id=?");
		$sti->execute($id);
		my ($freelib_text) = $sti->fetchrow_array;
		$result = $freelib_text;
	}
	my $Rsearch_string="$search_string%";
	my $authoritysep = C4::AR::Preferencias::getValorPreferencia('authoritysep');
	my @splitted = /$authoritysep/,$search_string;
	my $level = $#splitted+1;
	my $sti;
	if ($search_string) { # if no search pattern, returns only the 50 1st top level values
		$sti=$dbh->prepare("select distinct freelib,father,level from bibliothesaurus where category='NC' and freelib like ? order by father,freelib");
	} else {
		$sti=$dbh->prepare("select distinct freelib,father,level from bibliothesaurus where category='NC' and level=0 and freelib like ? order by father,freelib limit 0,50");
	}
	$sti->execute($Rsearch_string);
	my @results;
	while (my ($freelib,$father,$level)=$sti->fetchrow) {
		my %line;
		if ($father) {
			$line{value} = "$father $freelib";
		} else {
			$line{value} = "$freelib";
		}
		$line{level} = $level+1;
		$line{father} = $father;
		push @results, \%line;
	}
	my @DeeperResults = SearchDeeper('NC',$search_string);
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "value_builder/unimarc_field_60X.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1},
					debug => 1,
					});
# builds collection list : search isbn and editor, in parent, then load collections from bibliothesaurus table
	$template->param(index => $index,
							result =>$result,
							search_string => $search_string?$search_string:$result,
							results => \@results,
							deeper => \@DeeperResults,
				);
	print $input->header(-cookie => $cookie),$template->output;
}

1;
