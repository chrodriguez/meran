#!/usr/bin/perl
use HTML::Template;
use strict;
require Exporter;
# use C4::Database;
use C4::Output;  # contains gettemplate
use C4::Interface::CGI::Output;
use C4::Auth;
use C4::Context;
use CGI;

my $dbh = C4::Context->dbh;
my $query = new CGI;
my ($template, $loggedinuser, $cookie)
    = get_template_and_user({template_name => "availdetail.tmpl",
			     query => $query,
			     type => "intranet",
			     authnotrequired => 0,
			     flagsrequired => {parameters => 1},
			     debug => 1,
			     });
my $item=$query-param('item');
my $biblio=$query-param('biblio');
my $biblioitem=$query-param('biblioitem');

 my $dbh = C4::Context->dbh;
 my $sth=$dbh->prepare("Select *  from available where item=?  order by date");
        $sth->execute($item);

my @loop;

        $template->param(loop => \@loop);
        while (my $data=$sth->fetchrow_hashref){
       	     my %row = ( printername => $results->[$i]{'printername'},
                            printqueue  => $results->[$i]{'printqueue'},
                            printtype   => $results->[$i]{'printtype'},
                            toggle      => $toggle);
                push @loop, \%row;
        }

        $template->param(loop => \@loop,
			  item =>$item);
        $sth->finish;

output_html_with_http_headers $query, $cookie, $template->output;
