#!/usr/bin/perl
use strict;
use CGI;
use C4::AR::Z3950;
use MARC::File::USMARC;
use C4::Auth;
use C4::Interface::CGI::Output;

use vars qw( $tagslib );
use vars qw( $is_a_modif );


my $input = new CGI;
my $dbh = C4::Context->dbh;
my $title = $input->param('title');
my $author = $input->param('author');

    my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "z3950/searchresult.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );


if (($title ne '') or ($author ne '')) {
my $search='';
if ($title ne ''){$search='title='.$title;
		if ($author ne ''){$search.=' and author='.$author;}
		}
	else	{$search='author='.$author;}

my @resultado = &buscarEnZ3950($search);

	$template->param(
		author 		=> $author,
		title		=> $title,
		resultado       => \@resultado,
	);
}
	print $input->header(
		-type   => guesstype( $template->output ),
		-cookie => $cookie
	),
	$template->output;

