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
	&link_to
    &to_Button
);


=item
Esta funcion genera un link de la forma <a href="url?parametros" title="title">texto</a>, concatenando a los parametros
el parametro "token" utilizado 
@params
$params_hash_ref{'params'}, arreglo con los parametros enviados por get a la url
$params_hash_ref{'text'}, texto a mostrar en el link
$params_hash_ref{'url'}, url 
$params_hash_ref{'title'}, titulo a mostrar cuando se pone el puntero sobre el link

El objetivo principal de la funcion es la de evitar CSRF (Cross Site Request Forgery), esto es llevado a cabo con la inclusion del token
en cada link.
=cut
sub link_to {
	my (%params_hash_ref) = @_;

	my $link= '';
	my $params= $params_hash_ref{'params'} || []; #obtengo los paraametros
	my $text= $params_hash_ref{'text'}; #obtengo el texto a mostrar
	my $url= $params_hash_ref{'url'}; #obtengo la url
	my $title= $params_hash_ref{'title'}; #obtengo el title a mostrar
	my $class= $params_hash_ref{'class'}; #obtengo la clase
    my $boton= $params_hash_ref{'boton'}; #obtengo el title a mostrar
    my $width= $params_hash_ref{'width'};
	my $cant= scalar(@$params);
# C4::AR::Debug::debug("link_to => cant params: ".$cant);

	if($cant > 0){$url .= "?";
	#lleva parametros
		for(my $i=0; $i < $cant; $i++ ){
			if($i > 0){
			#se procesan el resto de los parametros
				$url .= '&'.@$params->[$i]; 
			}else{
			#se procesa el primer parametro
				$url .= @$params->[$i];
			}
		}
	}

	my $session = CGI::Session->load();
 	if($session->param('token')){
# 	if(defined $session){
	#si hay sesion se usa el token, sino no tiene sentido
         #SI NO HUBO PARAMETROS, EL TOKEN ES EL UNICO EN LA URL, O SEA QUE SE PONE ? EN VEZ DE &
        if ($cant > 0){
		    $url .= '&token='.$session->param('token'); #se agrega el token
        }else{
            $url .= '?token='.$session->param('token'); 
        }
	}

	$link= "<a href=".$url;
	if ($class ne ''){
        if (!$boton){ #Porque si es con boton, la clase la lleva el li
		    $link .= " class=".$class;
        }
	}

	if($title ne ''){
		$link .= " Title='".$title."'";
	}

	$link .= " tabindex='-1'>";

    my $button;

    if($boton){
        $button .=  "<li id='boton_medio' style='width:".$width."px' class='".$class."' > ";
        $button .=  $link;
        $button .=  "   <div id=".$boton."> ";
        $button .=  "   </div> ";
        $button .=  "   <div id='boton_der'> ";
        $button .=  "   </div> ";
        $button .=  "   <div id='boton_texto'>".$text."</div> ";
        $button .=  "   </a> ";
        $button .=  "</li> ";

        return $button;
    }else{
        $link .= $text."</a>"; 
    }

#  	C4::AR::Debug::debug("url: ".$url);
#  	C4::AR::Debug::debug("link: ".$link);

	return $link;
}

=item
Esta funcion es utilizada para la Internacionalizacion, lo que hace es tomar el parametro "text" del template
y hacer la traduccion del mismo, obteniedola del binario correspondiente, por ej. en_EN/LC_MESSAGES/intranet.mo
=cut
sub i18n {

	my ($text) = @_;
	my $session = CGI::Session->load();#si esta definida
	my $type= $session->param('type') || 'opac';

 	my $locale = $session->param('locale')||C4::Context->config("defaultLang")||'es_ES';
	my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL

	Locale::Maketext::Gettext::Functions::bindtextdomain($type, C4::Context->config("locale"));
	Locale::Maketext::Gettext::Functions::textdomain($type);
	Locale::Maketext::Gettext::Functions::get_handle($locale);

 	return __($text);
}

sub to_Button{
    my (%params_hash_ref) = @_;

    my $button= '';
    my $text= $params_hash_ref{'text'}; #obtengo el texto a mostrar
    my $boton= $params_hash_ref{'boton'}; #obtengo el boton
    my $onClick= $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onClick
    my $title= $params_hash_ref{'title'}; #obtengo el title de la componete
    my $width= length($text);

    if($params_hash_ref{'width'}){
#         C4::AR::Debug::debug("to_Button => width: ".$params_hash_ref{'width'});
        $width= $params_hash_ref{'width'};
    }else{
        $width += 90;
    }
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';
    $button .=  "<li id='boton_medio' class='click ".$alternClass. "' onClick='".$onClick."' style='width:".$width."px'";
    if($title){
        $button .= " title='".$title."'";
    }
    
    $button .= "> ";
    $button .=  "    <div id=".$boton."> ";
    $button .=  "   </div> ";
    $button .=  "   <div id='boton_der'> ";
    $button .=  "   </div> ";
    $button .=  "   <div id='boton_texto'>".$text."</div> ";
    $button .=  "</li> ";
    return $button;
}

sub to_Icon{
    my (%params_hash_ref) = @_;

    my $button= '';
    my $boton= $params_hash_ref{'boton'}; #obtengo el boton
    my $onClick= $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onClick
    my $title= $params_hash_ref{'title'}; #obtengo el title de la componete
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';
#     $button .=  "<span id='".$boton."' class='click ".$alternClass. "' onClick=".$onClick;
    $button .=  "<div id='".$boton."' class='click ".$alternClass. "' onClick=".$onClick;
    if($title){
        $button .= " title='".$title."'";
    }
    
    $button .= "> ";
#     $button .=  "</span> ";
    $button .=  "</div> ";

    return $button;
}

=item
Este filtro sirve para generar dinamicamente le combo para seleccionar el idioma.
Este es llamado desde el opac-top.inc o intranet-top.inc (solo una vez).
Se le parametriza si el combo es para la INTRA u OPAC
=cut
sub setComboLang {

    my ($type) = @_;
    my $session = CGI::Session->load();
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
    $html .="<select id='language' onChange='cambiarIdioma()' tabindex='-1'>";

    for($i=0;$i<scalar(@array_lang);$i++){
        if($session->param('locale') eq @array_lang[$i]){
            $html .="<option value='".@array_lang[$i]."' selected='selected'>".@array_lang[$i]."</option>"; 
        }else{
            $html .="<option value='".@array_lang[$i]."'>".@array_lang[$i]."</option>";
        }
    }

    $html .="</select>";
    $html .="</form>";

    return $html;
}
