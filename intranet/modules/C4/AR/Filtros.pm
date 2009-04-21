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
	&setComboLang
);


sub i18n {

	my ($text) = @_;
	my $session = CGI::Session->load();#si esta definida
# open(Z, ">>/tmp/debug.txt");
# print Z "\n";
## FIXME falta manejar cookie si el usuario no esta logueado
	my $type= $session->param('type') || 'opac';

 	my $locale = $session->param('locale')||C4::Context->config("defaultLang")||'es_ES';
# print Z "type: ".$type."\n";
# print Z "locale: ".$locale."\n";
# print Z "default lang: ".C4::Context->config("defaultLang")."\n";
# print Z "session locale: ".$session->param('locale')."\n";
	my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL
# print Z "path locale: ".C4::Context->config("locale")."\n";
	Locale::Maketext::Gettext::Functions::bindtextdomain($type, C4::Context->config("locale"));
	Locale::Maketext::Gettext::Functions::textdomain($type);
	Locale::Maketext::Gettext::Functions::get_handle($locale);
# print Z "\n";
# close(Z);
 	return __($text);
}

=item
Este filtro sirve para generar dinamicamente le combo para seleccionar el idioma.
Este es llamado desde el opac-top.inc o intranet-top.inc (solo una vez).
Se le parametriza si el combo es para la INTRA u OPAC
=cut
sub setComboLang {

    my ($type) = @_;
    my $session = CGI::Session->load();
# open(A, ">>/tmp/debug.txt");
# print A "desde putHTML: \n";
    my $html= '';
    my $lang_Selected= $session->param('locale');
## FIXME falta recuperar esta info desde la base es_ES => Español, ademas estaria bueno agregarle la banderita
    my @array_lang= ('es_ES', 'en_EN', 'nz_NZ', 'jp_JP');
    my $i;

    if($type eq 'OPAC'){
        $html="<form id='formLang' action='/cgi-bin/koha/opac-language.pl' method='POST' class='selectLang'>";
    }else{
        $html="<form id='formLang' action='/cgi-bin/koha/intra-language.pl' method='POST' class='selectLang'>";
    }

    $html .="<input id='lang_server' name='lang_server' type='hidden' value=''>";   
    $html .="<input id='url' name='url' type='hidden' value=''>";
    $html .="<select id='language' onChange='cambiarIdioma()'>";

    for($i=0;$i<scalar(@array_lang);$i++){
        if($session->param('locale') eq @array_lang[$i]){
            $html .="<option value='".@array_lang[$i]."' selected='selected'>".@array_lang[$i]."</option>"; 
        }else{
            $html .="<option value='".@array_lang[$i]."'>".@array_lang[$i]."</option>";
        }
    }

    $html .="</select>";
    $html .="</form>";
# close(A);
    return $html;
}
