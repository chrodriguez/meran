#!/usr/bin/perl

# $Id: usmarc_field_952v.pl,v 1.1.2.1 2005/12/09 16:53:45 kados Exp $

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

require Exporter;
use C4::AR::AuthoritiesMarc;
use C4::AR::Auth;

use CGI;
use MARC::Record;

=head1

plugin_parameters : other parameters added when the plugin is called by the dopop function

=cut
sub plugin_parameters {
my ($dbh,$record,$tagslib,$i,$tabloop) = @_;
return "";
}

=head1

plugin_javascript : the javascript function called when the user enters the subfield.
contain 3 javascript functions :
* one called when the field is entered (OnFocus). Named FocusXXX
* one called when the field is leaved (onBlur). Named BlurXXX
* one called when the ... link is clicked (<a href="javascript:function">) named ClicXXX

returns :
* XXX
* a variable containing the 3 scripts.
the 3 scripts are inserted after the <input> in the html code

=cut
sub plugin_javascript {
my ($dbh,$record,$tagslib,$field_number,$tabloop) = @_;
my $function_name= "210c".(int(rand(100000))+1);

# find today's date
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                                               localtime(time);
$year +=1900;
$mon +=1;
my $date = "$year-$mon-$mday";
my $res  = "
<script>
function Blur$function_name(index) {
//need this?
}

function Focus$function_name(subfield_managed) {
	for (i=0 ; i<document.f.field_value.length ; i++) {
                if (document.f.tag[i].value == '952' && document.f.subfield[i].value == 'v') {
                        document.f.field_value[i].value = '$date';
                }
        }
return 0;
}

function Clic$function_name(subfield_managed) {
}
</script>
";
return ($function_name,$res);
}

=head1

plugin : the true value_builded. The screen that is open in the popup window.

=cut

sub plugin {
my ($input) = @_;
return "";
}

1;
