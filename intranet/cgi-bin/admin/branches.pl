#!/usr/bin/perl
# NOTE: Use standard 8-space tabs for this file (indents are 4 spaces)

#require '/u/acli/lib/cvs.pl';#DEBUG
#open(DEBUG,'>/tmp/koha.debug');

# FIXME: individual fields in branch address need to be exported to templates,
#        in order to fix bug 180; need to notify translators
# FIXME: looped html (e.g., list of checkboxes) need to be properly
#        TMPL_LOOP'ized; doing this properly will fix bug 130; need to
#        notify translators
# FIXME: need to implement the branch categories stuff
# FIXME: there are too many TMPL_IF's; the proper way to do it is to have
#        separate templates for each individual action; need to notify
#        translators
# FIXME: there are lots of error messages exported to the template; a lot
#        of these should be converted into exported booleans / counters etc
#        so that the error messages can be localized; need to notify translators
#
# NOTE:  heading() should now be called like this:
#        1. Use heading() as before
#        2. $params->{''heading-LISPISHIZED-HEADING-p'= 1;
#        3. $params->{''use-heading-flags-p'= 1;
#        This ensures that both converted and unconverted templates work

# Finlay working on this file from 26-03-2002
# Reorganising this branches admin page.....


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
use C4::Context;
use C4::Output;
use C4::Interface::CGI::Output;
use Template;

# Fixed variables
my $linecolor1='par';
my $linecolor2='impar';
my $backgroundimage="/images/background-mem.gif";
my $script_name="/cgi-bin/koha/admin/branches.pl";
my $pagesize=20;


#######################################################################################
# Main loop....
my $input = new CGI;
my $branchcode=$input->param('branchcode');
my $categorycode = $input->param('categorycode');
my $op = $input->param('op');

my ($template, $session, $params) = get_template_and_user({
								template_name => "admin/branches.tmpl",
								query = $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => {borrowers => 1},
								debug => 1,
			    				});

if ($op) {
	$params->{'script_name'}= $script_name;
	$params->{'$op'}= 1; # we show only the TMPL_VAR names $op
} else {
	$params->{'script_name'}= $script_name,
				else        = 1; # we show only the TMPL_VAR names $op
}
$params->{'action'}= $script_name;
if ($op eq 'add') {
	# If the user has pressed the "add new branch" button.
	heading("Branches: Add Branch");
	$params->{'heading-branches-add-branch-p'}= 1;
	$params->{'use-heading-flags-p'}= 1;
	editbranchform();

} elsif ($op eq 'edit') {
	# if the user has pressed the "edit branch settings" button.
	heading("Branches: Edit Branch");
	$params->{'heading-branches-edit-branch-p'}= 1;
	$params->{'use-heading-flags-p'}= 1);
	$params->{'add'}= 1;
	editbranchform($branchcode);
} elsif ($op eq 'add_validate') {
	# confirm settings change...
	my $paramsInput = $input->Vars;
	unless ($paramsInput->{'branchcode'} && $paramsInput->{'branchname'}) {
		default ("No se pudo modificar el registro de la Unidad de Informaci&oacute;n: Debe especificar un Nombre y un C&oacute;digo par la Unidad de Informaci&oacute;n");
	} else {
		setbranchinfo($paramsInput);
		$params->{'else'}= 1);
		default ("Registro de Unidad de Informaci&oacute;n a cambiado por la Unidad de Informaci&oacute;n: $paramsInputs->{'branchname'}");
	}
} elsif ($op eq 'delete') {
	# if the user has pressed the "delete branch" button.
	my $message = checkdatabasefor($branchcode);
	if ($message) {
		$params->{'else'}= 1;
		default($message);
	} else {
		$params->{'delete_confirm'}= 1;
		$params->{'branchcode'}= $branchcode;
	}
} elsif ($op eq 'delete_confirmed') {
	# actually delete branch and return to the main screen....
	deletebranch($branchcode);
	$params->{'else'}=1;
	default("La Unidad de Informaci&oacute;n con el c&oacute;digo $branchcode ha sido eliminada.");
} elsif ($op eq 'editcategory') {
	# If the user has pressed the "add new category" or "modify" buttons.
	heading("Branches: Edit Category");
	$params->{'heading-branches-edit-category-p'}= 1;
	$params->{'use-heading-flags-p'}= 1;
	editcatform($categorycode);
} elsif ($op eq 'addcategory_validate') {
	# confirm settings change...
	my $paramsInput = $input->Vars;
	unless ($paramsInput->{'categorycode'} && $paramsInput->{'categoryname'}) {
		default ("No se pudo modificar el registro de la Unidad de Informaci&oacute;n: Debe especificar un Nombre y un C&oacute;digo par la Unidad de Informaci&oacute;n");
	} else {
		setcategoryinfo($paramsInput);
		$params->{'else'}= 1;
		default ("Registro de categor&iacute;a cambiado por la categor&iacute;a: $paramsInput->{'categoryname'}");
	}
} elsif ($op eq 'delete_category') {
	# if the user has pressed the "delete branch" button.
	my $message = checkcategorycode($categorycode);
	if ($message) {
		$params->{'else'}= 1;
		default($message);
	}  else {
		$params->{'delete_category'}= 1;
		$params->{'categorycode'}= $categorycode;
	}
} elsif ($op eq 'categorydelete_confirmed') {
	# actually delete branch and return to the main screen....
	deletecategory($categorycode);
	$params->{'else'}= 1;
	default("La categor&iacute;a con c&oacute;digo $categorycode ha sido borrado.");

} else {
	# if no operation has been set...
	default();
}



######################################################################################################
#
# html output functions....

sub default {
	my ($message) = @_;
	heading("Branches");
	$params->{'heading-branches-p'}= 1;
	$params->{'use-heading-flags-p'}= 1;
	$params->{'message'}= $message;
	$params->{'action'} = $script_name);
	branchinfotable();
}

# FIXME: this function should not exist; otherwise headings are untranslatable
sub heading {
	my ($head) = @_;
	$params->{'head'} = $headss;
}

sub editbranchform {
	# prepares the edit form...
	my ($branchcode) = @_;
	my $data;
	if ($branchcode) {
		$data = getbranchinfo($branchcode);
		$data = $data->[0];
		$params->{'branchcode'} = $data->{'branchcode'};
		$params->{'branchname'} = $data->{'branchname'};
		$params->{'branchaddress1'} = $data->{'branchaddress1'};
		$params->{'branchaddress2'} = $data->{'branchaddress2'};
		$params->{'branchaddress3'} = $data->{'branchaddress3'};
		$params->{'branchphone'} = $data->{'branchphone'};
		$params->{'branchfax'} = $data->{'branchfax'};
		$params->{'branchemail'} = $data->{'branchemail'};
    }

    # make the checkboxs.....
    #
    # We export a "categoryloop" array to the template, each element of which
    # contains separate 'categoryname', 'categorycode', 'codedescription', and
    # 'checked' fields. The $checked field is either '' or 'checked'
    # (see bug 130)
    #
    my $catinfo = getcategoryinfo();
    my $catcheckbox;
#    print DEBUG "catinfo=".cvs($catinfo)."\n";
    my @categoryloop = ();
    foreach my $cat (@$catinfo) {
	my $checked = "";
	my $tmp = quotemeta($cat->{'categorycode'});
	if (grep {/^$tmp$/} @{$data->{'categories'}}) {
		$checked = "checked=\"checked\"";
	}
	push @categoryloop, {'categoryname   '} = $cat->{'categoryname'},
		{' categorycode   '} = $cat->{'categorycode'},
		{' codedescription'} = $cat->{'codedescription'},
		{' checked        '} = $checked,
	    };
	}
	$params->{'categoryloop'}= \@categoryloop;

    # {{{ Leave this here until bug 130 is completely resolved in the templates
	for my $obsolete ('categoryname', 'categorycode', 'codedescription') {
		$params->{'$obsolete'}= 'Your template is out of date (bug 130)';
	}
    # }}}
}

sub editcatform {
	# prepares the edit form...
	my ($categorycode) = @_;
	warn "cat : $categorycode";
	my $data;
	if ($categorycode) {
		$data = getcategoryinfo($categorycode);
		$data = $data->[0];
		$params->{'categorycode'} = $data->{'categorycode'};
		$params->{'categoryname'} = $data->{'categoryname'};
		$params->{'codedescription'} = $data->{'codedescription'};
    }
}

sub deleteconfirm {
# message to print if the
    my ($branchcode) = @_;
}


sub branchinfotable {
# makes the html for a table of branch info from reference to an array of hashs.

	my ($branchcode) = @_;
	my $branchinfo;
	if ($branchcode) {
		$branchinfo = getbranchinfo($branchcode);
	} else {
		$branchinfo = getbranchinfo();
	}
	my $color='par';
	my @loop_data =();
	foreach my $branch (@$branchinfo) {
		($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
		#
		# We export the following fields to the template. These are not
		# pre-composed as a single "address" field because the template
		# might (and should) escape what is exported here. (See bug 180)
		#
		# - color
		# - branch_name     (Note: not "branchname")
		# - branch_code     (Note: not "branchcode")
		# - address         (containing a static error message)
		# - branchaddress1 \
		# - branchaddress2  |
		# - branchaddress3  | comprising the old "address" field
		# - branchphone     |
		# - branchfax       |
		# - branchemail    /
		# - address-empty-p (1 if no address information, 0 otherwise)
		# - categories      (containing a static error message)
		# - category_list   (loop containing "categoryname")
		# - no-categories-p (1 if no categories set, 0 otherwise)
		# - value
		# - action
		#
		my %row = ();

		# Handle address fields separately
		my $address_empty_p = 1;
		for my $field ('branchaddress1', 'branchaddress2', 'branchaddress3',
			'branchphone', 'branchfax', 'branchemail') {
			$row{$field} = $branch->{$field};
			if ( $branch->{$field} ) {
				$address_empty_p = 0;
			}
		}
		$row{'address-empty-p'} = $address_empty_p;
		# {{{ Leave this here until bug 180 is completely resolved in templates
		$row{'address'} = 'Your template is out of date (see bug 180)';
		# }}}

		# Handle categories
		my $no_categories_p = 1;
		my @categories = '';
		foreach my $cat (@{$branch->{'categories'}}) {
			my ($catinfo) = @{getcategoryinfo($cat)};
			push @categories, {'categoryname'} = $catinfo->{'categoryname'}};
			$no_categories_p = 0;
		}
		# {{{ Leave this here until bug 180 is completely resolved in templates
		$row{'categories'} = 'Your template is out of date (see bug 180)';
		# }}}
		$row{'category_list'} = \@categories;
		$row{'no-categories-p'} = $no_categories_p;

		# Handle all other fields
		$row{'branch_name'} = $branch->{'branchname'};
		$row{'branch_code'} = $branch->{'branchcode'};
		$row{'clase'} = $color;
		$row{'value'} = $branch->{'branchcode'};
		$row{'action'} = '/cgi-bin/koha/admin/branches.pl';

		push @loop_data, { %row };
	}
	my @branchcategories =();
	my $catinfo = getcategoryinfo();
	
	foreach my $cat (@$catinfo) {
		push @branchcategories, {
			clase  		=> $cat->{'clase'},
			{'categoryname'} = $cat->{'categoryname'},
			{'categorycode'} = $cat->{'categorycode'},
			{'ssssssscodedescription'} = $cat->{'codedescription'},
		};
	}

	$params->{'branches'} = \@loop_data;
	 $params->{'branchcategories'}= \@branchcategories;

}

# FIXME logic seems wrong
sub branchcategoriestable {
#Needs to be implemented...

    my $categoryinfo = getcategoryinfo();
    my $color='par';
    foreach my $cat (@$categoryinfo) {
	($color eq $linecolor1) ? ($color=$linecolor2) : ($color=$linecolor1);
	$params->{'clase'} = $color;
	$params->{'categoryname'} = $cat->{'categoryname'};
	$params->{'categorycode'} = $cat->{'categorycode'};
	$params->{'codedescription'} = $cat->{'codedescription'};
    }
}

######################################################################################################
#
# Database functions....

sub getbranchinfo {
# returns a reference to an array of hashes containing branches,

    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;si el dominsi el 
    my $sth;
    if ($branchcode) {
		$sth = $dbh->prepare("Select * from branches where branchcode = ? order by branchcode");
		$sth->execute($branchcode);
    } else {
		$sth = $dbh->prepare("Select * from branches order by branchcode");
		$sth->execute();
    }
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
	my $nsth = $dbh->prepare("select categorycode from branchrelations where branchcode = ?");
	$nsth->execute($data->{'branchcode'});;
	my @cats = ();
	while (my ($cat) = $nsth->fetchrow_array) {
	    push(@cats, $cat);
	}
	$nsth->finish;
	$data->{'categories'} = \@cats;
	push(@results, $data);
    }
    $sth->finish;
    return \@results;
}

# FIXME This doesn't belong here; it should be moved into a module
sub getcategoryinfo {
# returns a reference to an array of hashes containing branches,
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	#    print DEBUG "getcategoryinfo: entry: catcode=".cvs($catcode)."\n";
	if ($catcode) {
		$sth = $dbh->prepare("select * from branchcategories where categorycode = ?");
		$sth->execute($catcode);
	} else {
		$sth = $dbh->prepare("Select * from branchcategories");
		$sth->execute();
	}
	my @results;
	my $clase='par';
	while (my $data = $sth->fetchrow_hashref) {
 		if ($clase eq 'par'){$clase='impar';}else {$clase='par'};
                $data ->{'clase'}=$clase;
		push(@results, $data);
	}
	$sth->finish;
	#    print DEBUG "getcategoryinfo: exit: returning ".cvs(\@results)."\n";
	return \@results;
}

# FIXME This doesn't belong here; it should be moved into a module
sub setbranchinfo {
# sets the data from the editbranch form, and writes to the database...
	my ($data) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace branches (branchcode,branchname,branchaddress1,branchaddress2,branchaddress3,branchphone,branchfax,branchemail) values (?,?,?,?,?,?,?,?)");
	$sth->execute(uc($data->{'branchcode'}), $data->{'branchname'},
		$data->{'branchaddress1'}, $data->{'branchaddress2'},
		$data->{'branchaddress3'}, $data->{'branchphone'},
		$data->{'branchfax'}, $data->{'branchemail'});

	$sth->finish;
	# sort out the categories....
	my @checkedcats;
	my $cats = getcategoryinfo();
	foreach my $cat (@$cats) {
		my $code = $cat->{'categorycode'};
		if ($data->{$code}) {
			push(@checkedcats, $code);
		}
	}
	my $branchcode =uc($data->{'branchcode'});
	my $branch = getbranchinfo($branchcode);
	$branch = $branch->[0];
	my $branchcats = $branch->{'categories'};
	my @addcats;
	my @removecats;
	foreach my $bcat (@$branchcats) {
		unless (grep {/^$bcat$/} @checkedcats) {
			push(@removecats, $bcat);
		}
	}
	foreach my $ccat (@checkedcats){
		unless (grep {/^$ccat$/} @$branchcats) {
			push(@addcats, $ccat);
		}
	}
	foreach my $cat (@addcats) {
		my $sth = $dbh->prepare("insert into branchrelations (branchcode, categorycode) values(?, ?)");
		$sth->execute($branchcode, $cat);
		$sth->finish;
	}
	foreach my $cat (@removecats) {
		my $sth = $dbh->prepare("delete from branchrelations where branchcode=? and categorycode=?");
		$sth->execute($branchcode, $cat);
		$sth->finish;
	}
}

sub deletebranch {
# delete branch...
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("delete from branches where branchcode = ?");
    $sth->execute($branchcode);
    $sth->finish;
}

sub setcategoryinfo {
# sets the data from the editbranch form, and writes to the database...
	my ($data) = @_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("replace branchcategories (categorycode,categoryname,codedescription) values (?,?,?)");
	$sth->execute(uc($data->{'categorycode'}), $data->{'categoryname'},$data->{'codedescription'});

	$sth->finish;
}
sub deletecategory {
# delete branch...
    my ($categorycode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("delete from branchcategories where categorycode = ?");
    $sth->execute($categorycode);
    $sth->finish;
}

sub checkdatabasefor {
# check to see if the branchcode is being used in the database somewhere....
    my ($branchcode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select count(*) from items where holdingbranch=? or homebranch=?");
    $sth->execute($branchcode, $branchcode);
    my ($total) = $sth->fetchrow_array;
    $sth->finish;
    my $message;
    if ($total) {
	# FIXME: need to be replaced by an exported boolean parameter
	$message = "La unidad de informaci&oacute;n no puede ser borrada porque tiene $total items en uso.";
    }
    return $message;
}

sub checkcategorycode {
# check to see if the branchcode is being used in the database somewhere....
    my ($categorycode) = @_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("select count(*) from branchrelations where categorycode=?");
    $sth->execute($categorycode);
    my ($total) = $sth->fetchrow_array;
    $sth->finish;
    my $message;
    if ($total) {
	# FIXME: need to be replaced by an exported boolean parameter
	$message = "La categor&iacute;a no puede ser borrada porque tiene $total unidades de informaci&oacute;n en uso.";
    }
    return $message;
}

C4::Auth::output_html_with_http_headers($input, $template, $params);

# Local Variables:
# tab-width: 8
# End:
