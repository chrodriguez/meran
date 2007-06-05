#!/usr/bin/perl
# Please use 8-character tabs for this file (indents are every 4 characters)

#written 8/5/2002 by Finlay
#script to execute issuing of books


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
use C4::Circulation::Circ2;
use C4::Search;
use C4::Reserves2;
use C4::Output;
use C4::Print;
use DBI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Koha;
use HTML::Template;
use C4::Date;
use Date::Manip;
use C4::AR::Issues;

my $input=new CGI;

my ($template, $loggedinuser, $cookie) = get_template_and_user
    ({
	template_name	=> 'circ/unauthorized.tmpl',
	query		=> $input,
	type		=> "intranet",
	authnotrequired	=> 0,
	flagsrequired	=> { circulate => 1 },
    });

my $borrower=$input->param('borrower');
my $usuario;
$usuario->{'borrowernumber'}=$borrower;
my @todaysissues; 
my @previousissues;
my @realprevissues;
my $linecolor1='par';
my $linecolor2='impar';
my $todaysdate;
my @realtodayissues;
my $issueslist = getissues($usuario);
    foreach my $it (keys %$issueslist) {
        my $issuedate = $issueslist->{$it}->{'timestamp'};
        $issuedate = substr($issuedate, 0, 8);
        if ($todaysdate == $issuedate) {
            push @todaysissues, $issueslist->{$it};
        } else {
            push @previousissues, $issueslist->{$it};
        }
    }
        my $tcolor = '';
        my $pcolor = '';
        my $od = ''; 
        foreach my $book (sort {$b->{'timestamp'} <=> $a->{'timestamp'}} @todaysissues){
                my $dd = $book->{'date_due'};
                my $datedue = $book->{'date_due'};

		my $err= "Error con la fecha";
    		my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err,2));
    		my $df=C4::Date::format_date_in_iso(DateCalc(vencimiento($book->{'itemnumber'}),"+0 days",\$err));

   		$book->{'df'} = format_date($df);

    		if (Date_Cmp($hoy,$df) > 0)
    		    {$book->{'color'} ='red';}

                $dd=format_date($dd);
                
                ($tcolor eq $linecolor1) ? ($tcolor=$linecolor2) : ($tcolor=$linecolor1);
                $book->{'dd'}=$dd;
                $book->{'clase'}=$tcolor;
                if ($book->{'author'} eq ''){
                    $book->{'author'}=' ';
                }
                push @realtodayissues,$book;
        }
    $pcolor='';
    foreach my $book (sort {$a->{'date_due'} cmp $b->{'date_due'}} @previousissues){
        my $dd = $book->{'date_due'};
        my $datedue = $book->{'date_due'};
	 my $err= "Error con la fecha";
                my $hoy=C4::Date::format_date_in_iso(DateCalc(ParseDate("today"),"+ 0 days",\$err,2));
                my $df=C4::Date::format_date_in_iso(DateCalc(vencimiento($book->{'itemnumber'}),"+0 days",\$err));

                $book->{'df'} = format_date($df);

                if (Date_Cmp($hoy,$df) > 0)
                    {$book->{'color'} ='red';}

        ($pcolor eq $linecolor1) ? ($pcolor=$linecolor2) : ($pcolor=$linecolor1);
        $book->{'dd'}=$dd;
        $book->{'clase1'}=$pcolor;
        if ($book->{'author'} eq ''){
            $book->{'author'}=' ';
        }
        push @realprevissues,$book
   };
$template->param(
		 tcolor		=> $linecolor1,
		 pcolor		=> $linecolor2,
		 previssues     => \@realprevissues,
		 todayissues    => \@realtodayissues);

output_html_with_http_headers $input, $cookie, $template->output;
