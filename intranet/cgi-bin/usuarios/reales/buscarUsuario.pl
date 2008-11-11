#!/usr/bin/perl

use strict;
use C4::Auth;
use C4::Interface::CGI::Output;
use CGI;
use Template;

my $input = new CGI;

# 
# my ($template, $loggedinuser, $cookie)
#     = get_template_and_user({template_name => "usuarios/reales/buscarUsuario2.tmpl",
# 			     query => $input,
# 			     type => "intranet",
# 			     authnotrequired => 0,
# 			     flagsrequired => {borrowers => 1},
# 			     debug => 1,
# 			     });


print $input->header;
my $template = Template->new({
	INCLUDE_PATH => [
				'/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/usuarios/reales',
 				'/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes',
				'/usr/local/koha/intranet/htdocs/intranet-tmpl/blue/es2/includes/menu'
			],
# 	RELATIVE => 1,
	ABSOLUTE => 1,
}) || die "$Template::ERROR\n";

my $file= "buscarUsuario.tmpl";

my $member=$input->param('member');

my $params = {

		'member'  => $member,
		'themelang' => '/intranet-tmpl/blue/es2/',	
	};

$template->process($file,$params) || die "Template process failed: ", $template->error(), "\n";