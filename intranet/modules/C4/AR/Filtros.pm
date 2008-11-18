package C4::AR::Filtros;

use strict;
require Exporter;
use POSIX;
use Locale::Maketext::Gettext::Functions;
use Template::Plugin::Filter;
use base qw( Template::Plugin::Filter );

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 

	&i18n
);


sub i18n {

	my ($text) = @_;
my $session = CGI::Session->load();
# print $session->header;
# 	my $locale = "es_ES";
	my $locale = $session->param('lang');
	my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL
	bindtextdomain("usuarios", "/usr/local/koha/intranet/locale/");
	textdomain("usuarios");
# # # 	get_handle("es_ES");
	get_handle($session->param('lang'));
        # ...mungify $text...

 	return __($text);
}

