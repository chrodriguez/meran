#!/usr/bin/perl

#written 27/01/2000
#script to display borrowers reading record



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
use C4::Auth;
use C4::Output;
use C4::Date;
use C4::Interface::CGI::Output;
use CGI;
use C4::Search;
use HTML::Template;
use C4::AR::Estadisticas;

my $input=new CGI;

my ($template, $loggedinuser, $cookie)
= get_template_and_user({template_name => "opac-HistorialReservas.tmpl",
				query => $input,
				type => "opac",
				authnotrequired => 1,
				debug => 1,
				});

my $bornum=$loggedinuser;
#get borrower details
my $data=borrdata('',$bornum);
my $order=$input->param('order');
my $order2=$order;
if ($order2 eq ''){
  $order2="date_due desc";
}
my $limit=$input->param('limit');
if ($limit eq 'full'){
  $limit=0;
} else {
  $limit=50;
}

my ($count,$reservas_hashref)=&historialReservas($bornum,$order2,$limit);

=item
my @loop_reservas;
my $clase='par';
for (my $i=0;$i<$count;$i++){
 	my %line;
# 	$line{title}=$issues->[$i]->{'title'};
# 	$line{biblionumber}=$issues->[$i]->{'biblionumber'};
# 	$line{edicion}=$issues->[$i]->{'edicion'};
# 	$line{author}=$issues->[$i]->{'author'};
# 	$line{id}=$issues->[$i]->{'id'};	
# 	$line{date_due}=format_date($issues->[$i]->{'date_due'});
# 	$line{returndate}=format_date($issues->[$i]->{'returndate'});
# 	$line{volumeddesc}=$issues->[$i]->{'volumeddesc'};
# 	($line{grupos})=Grupos($issues->[$i]->{'biblionumber'},'intra');
	if ( $clase eq 'par' ) { $clase = 'impar'; } else {$clase = 'par'; }
        $line{'clase'}=$clase;
	push(@loop_reservas,\%line);
}
=cut

$template->param(title => $data->{'title'},
						initials => $data->{'initials'},
						surname => $data->{'surname'},
						bornum => $bornum,
						limit => $limit,
						firstname => $data->{'firstname'},
						cardnumber => $data->{'cardnumber'},
						showfulllink => ($count > 50),					
#  						loop_reservas => \@loop_reservas,
 						loop_reservas => $reservas_hashref
);

output_html_with_http_headers $input, $cookie, $template->output;



