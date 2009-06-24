#!/usr/bin/perl

#script to administer the senction rules
#written 25/07/2005 by Luciano Iglesias (li@info.unlp.edu.ar)
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

my $input = new CGI;
my $dbh = C4::Context->dbh;

my $action= $input->param('accion') || undef;
if ($action eq 'delete') {
        my $sanctionrulecode= $input->param('sanctionrulecode');
        my $sth = $dbh->prepare("delete from sanctionrules where sanctionrulecode = ?");
        $sth->execute($sanctionrulecode);
} elsif ($action eq 'add') {
        my $delaydays= $input->param('delaydays');
        my $sanctiondays= $input->param('sanctiondays');
        my $sth = $dbh->prepare("insert into sanctionrules (delaydays, sanctiondays) values (?,?)");
        $sth->execute($delaydays, $sanctiondays);
}

my ($template, $loggedinuser, $cookie) = get_template_and_user({
                            template_name => "admin/sanctionrules.tmpl",
                            query => $input,
                            type => "intranet",
			                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
			                authnotrequired => 0,
                            debug => 1,
                });


my $sth = $dbh->prepare("select * from sanctionrules order by delaydays, sanctiondays");
$sth->execute();
my @sanctionsarray;
while (my $res = $sth->fetchrow_hashref) {
        push (@sanctionsarray, $res);
}
$sth->finish;

$template->param(
	loop_sanctions_rules => \@sanctionsarray
);

output_html_with_http_headers $input, $cookie, $template->output;
