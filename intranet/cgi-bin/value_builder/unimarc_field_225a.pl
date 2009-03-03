#!/usr/bin/perl

# $Id: unimarc_field_225a.pl,v 1.5.2.1 2004/01/26 10:43:50 tipaul Exp $

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
=head1 SYNOPSIS

This plugin is used to map isbn/editor with collection.
It need :
  in thesaurus, a category named EDITORS
  in this category, datas must be entered like following :
  isbn separator editor separator collection.
  for example :
  2204 -- Cerf -- Cogitatio fidei
  2204 -- Cerf -- Le Magist�re de l'Eglise
  2204 -- Cerf -- Lectio divina
  2204 -- Cerf -- Lire la Bible
  2204 -- Cerf -- Pour lire
  2204 -- Cerf -- Sources chr�tiennes

  when the user clic on ... on 225a line, the popup shows the list of collections from the selected editor
  if the biblio has no isbn, then the search if done on editor only
  If the biblio ha an isbn, the search is done on isbn and editor. It's faster.

=over 2

=cut

use strict;
use C4::Auth;
use CGI;


=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut
sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

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
// find the 010a value and the 210c. it will be used in the popup to find possibles collections
	var isbn_found;
	for (i=0 ; i<document.f.field_value.length ; i++) {
		if (document.f.tag[i].value == '010' && document.f.subfield[i].value == 'a') {
			isbn_found=document.f.field_value[i].value;
		}
	}
	var editor_found;
	for (i=0 ; i<document.f.field_value.length ; i++) {
		if (document.f.tag[i].value == '210' && document.f.subfield[i].value == 'c') {
			editor_found=document.f.field_value[i].value;
		}
	}

	defaultvalue=document.f.field_value[index].value;
	newin=window.open(\"../plugin_launcher.pl?plugin_name=unimarc_field_225a.pl&index=\"+index+\"&result=\"+defaultvalue+\"&isbn_found=\"+isbn_found+\"&editor_found=\"+editor_found,\"unimarc 225a\",'width=500,height=200,toolbar=false,scrollbars=no');

}
</script>
";

return ($function_name,$res);
}
sub plugin {
my ($input) = @_;
	my %env;

#	my $input = new CGI;
	my $index= $input->param('index');
	my $result= $input->param('result');
	my $editor_found = $input->param('editor_found');
	my $isbn_found = $input->param('isbn_found');
	my $dbh = C4::Context->dbh;
	my $authoritysep = C4::AR::Preferencias->getValorPreferencia("authoritysep");
	my ($template, $loggedinuser, $cookie)
	= get_template_and_user({template_name => "value_builder/unimarc_field_225a.tmpl",
					query => $input,
					type => "intranet",
					authnotrequired => 0,
					flagsrequired => {parameters => 1},
					debug => 1,
					});
# builds collection list : search isbn and editor, in parent, then load collections from bibliothesaurus table
	# if there is an isbn, complete search
		my @collections;
	if ($isbn_found) {
		my $sth = $dbh->prepare("select stdlib from bibliothesaurus where father=? and category='EDITORS' order by stdlib");
		my @splited = split //, $isbn_found;
		my $isbn_rebuild='';
		foreach my $x (@splited) {
			$isbn_rebuild.=$x;
			$sth->execute("$isbn_rebuild $authoritysep $editor_found $authoritysep");
			while (my ($line)= $sth->fetchrow) {
				push @collections,$line;
			}
		}
	} else {
	# if there is no isbn, search with %
		my $sth = $dbh->prepare("select stdlib from bibliothesaurus where father like ? and category='EDITORS' order by stdlib");
		$sth->execute("\%$authoritysep $editor_found $authoritysep");
		while (my ($line)= $sth->fetchrow) {
			push @collections,$line;
		}
	}
#	my @collections = ["test"];
	my $collection =CGI::scrolling_list(-name=>'f1',
												-values=> \@collections,
												-default=>"$result",
												-size=>1,
												-multiple=>0,
												);
	$template->param(index => $index,
							collection => $collection);
	print $input->header(-cookie => $cookie),$template->output;
}

1;
