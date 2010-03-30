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
# 				$url .= '&'.@$params->[$i];
                $url .= '&amp;'.@$params->[$i];  
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
		    $url .= '&amp;token='.$session->param('token'); #se agrega el token
        }else{
            $url .= '?token='.$session->param('token'); 
        }
	}

	$link= "<a href='".$url."'";
	if ($class ne ''){
        if (!$boton){ #Porque si es con boton, la clase la lleva el li
		    $link .= " class=".$class;
        }
	}

	if($title ne ''){
		$link .= " title='".$title."'";
	}

	$link .= " >";

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

    my $locale = C4::Auth::getUserLocale();

    
	my $setlocale= setlocale(LC_MESSAGES, $locale); #puede ser LC_ALL

	Locale::Maketext::Gettext::Functions::bindtextdomain($type, C4::Context->config("locale"));
	Locale::Maketext::Gettext::Functions::textdomain($type);
	Locale::Maketext::Gettext::Functions::get_handle($locale);

 	return __($text);
}

sub to_Button{
    my (%params_hash_ref) = @_;

    my $button= '';

    if ($params_hash_ref{'url'}){
      $button .="<a href="."$params_hash_ref{'url'}"."> ";
    }

    my $text= $params_hash_ref{'text'}; #obtengo el texto a mostrar
    my $boton= $params_hash_ref{'boton'}; #obtengo el boton
    my $onclick= $params_hash_ref{'onclick'} || $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onclick
    my $title= $params_hash_ref{'title'}; #obtengo el title de la componete
    my $width= length($text);
    if($params_hash_ref{'width'}){
        if ($params_hash_ref{'width'}=="auto"){
            $width =$width+4;
            $width= $width."ex";
        }
        else{ $width= $params_hash_ref{'width'};
        }
    }
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';
    $button .=  '<li  class="click boton_medio '.$alternClass.' " onclick="'.$onclick.'" style="width:'.$width.'"';

    if($title){
        $button .= ' title="'.$title.'"';
    }
    
    $button .=  '> ';
    $button .=  '    <div class="'.$boton.'"> ';
    $button .=  '   </div> ';
    $button .=  '   <div class="boton_der"> ';
    $button .=  '   </div> ';
    $button .=  '   <div class="boton_texto">'.$text.'</div> ';
    $button .=  '</li> ';

    if ($params_hash_ref{'url'}){
      $button .="</a>";
    }

    return $button;
}




sub to_Icon{
    my (%params_hash_ref) = @_;

    my $button= '';
    my $boton= $params_hash_ref{'boton'}; #obtengo el boton
    my $onclick= $params_hash_ref{'onclick'} || $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onclick
    my $title= $params_hash_ref{'title'}; #obtengo el title de la componete
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';

    my $open_elem = "<div ";
    my $close_elem = "</div>";
      
    my $style = $params_hash_ref{'style'} || '';
    if ($params_hash_ref{'elem'}){
        $open_elem = "<".$params_hash_ref{'elem'};
        $close_elem = "</".$params_hash_ref{'elem'}.">";
    }

    if($params_hash_ref{'li'}){
        $button .=  '<li class="click '.$alternClass.' '.$boton.' " onclick="'.$onclick.'"';
    }else{
        $button .=  $open_elem.' class="click '.$alternClass.' '.$boton.'" onclick="'.$onclick.'"'.' style="'.$style.'"';
    }

    if($title){
        $button .= ' title="'.$title.'"';
    }
    
    $button .= '> ';
    if($params_hash_ref{'li'}){
        $button .=  '&nbsp;</li> ';
    }else{
        $button .=  $close_elem;
    }

    return $button;
}

sub ayuda_marc{

    my $icon= to_Icon(  
                boton   => "icon_ayuda_marc",
                onclick => "abrirVentanaHelperMARC();",
                title   => i18n("Ayuda MARC"),
            ) ;

    return "<div style='text-align: right;'><span class='click'>".$icon."</span></div><div id='ayuda_marc_content'></div>";
}


=item   sub get_error_message
    Esta funcion muestra un error en el template cuando falta algun parametros  
    $params_hash_ref{'debug'}: mensaje para debug 
    $params_hash_ref{'msg'}: mensaje para el usuario, sino se ingresa nada muesrta mensaje por defecto "ERROR EN LOS PARAMETROS"
=cut
sub get_error_message{
    my (%params_hash_ref) = @_;

    my $mensaje = i18n('ERROR EN LOS PARAMETROS');

    if($params_hash_ref{'debug'}){
        C4::AR::Debug::debug("Filtro => error_en_parametros => ".$params_hash_ref{'debug'});
    }

    if($params_hash_ref{'msg'}){
        $mensaje = i18n($params_hash_ref{'msg'});
    }

    return "<div class='error_en_parametros'>".$mensaje."</div>";
}

sub ayuda_in_line{
    my ($text) = @_;
    
    my $icon= to_Icon(  
                boton   => "icon_ayuda",
                title   => i18n("Ayuda"),
            ) ;

    my $ayuda = "<div id='ayuda' style='text-align: left;'><span class='click'>".$icon."</span>";
    $ayuda .= "<div id='ayuda_in_line' style='display:none'>".$text."</div></div>";

    return $ayuda;
}
=item
Este filtro sirve para generar dinamicamente le combo para seleccionar el idioma.
Este es llamado desde el opac-top.inc o intranet-top.inc (solo una vez).
Se le parametriza si el combo es para la INTRA u OPAC
=cut
sub setFlagsLang {

    my ($type) = @_;
    my $session = CGI::Session->load();
    my $html= '<ul>';
    my $lang_Selected= $session->param('locale');
## FIXME falta recuperar esta info desde la base es_ES => Español, ademas estaria bueno agregarle la banderita
    my @array_lang;


    my %hash_flags = {};
    $hash_flags{'lang'} = 'es_ES';
    $hash_flags{'flag'} = 'es.png';
    $hash_flags{'title'} = 'Espa&ntilde;ol';
    push (@array_lang, \%hash_flags);
    my %hash_flags = {};
    $hash_flags{'lang'} = 'en_EN';
    $hash_flags{'flag'} = 'en.png';
    $hash_flags{'title'} = 'English';
    push (@array_lang, \%hash_flags);
    my $href;


    my $url = $ENV{'REQUEST_URI'};
    if($type eq 'OPAC'){
        $href = '/cgi-bin/koha/opac-language.pl?url='.$url.'&amp;';
    }else{
        $href = '/cgi-bin/koha/intra-language.pl?';
    }

    my $flags_dir = C4::Context->config('temasOPAC').'/default/imagenes/flags';
    foreach my $hash_temp (@array_lang){
            $html .='<li><a href='."$href"."lang_server=".$hash_temp->{'lang'}.' title="'.$hash_temp->{'title'}.'"><img src='.$flags_dir.'/'.$hash_temp->{'flag'}.' alt="'.i18n("Cambio de lenguaje").'" /></a></li>';
    }
    $html .="</ul>";

    return $html;
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
    my $socio = C4::Auth::getSessionNroSocio();
    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();

    if($type eq 'OPAC'){
        $html="<form id='formLang' action='/cgi-bin/koha/opac-language.pl' method='POST' class='selectLang'><fieldset>";
    }else{
        $html="<form id='formLang' action='/cgi-bin/koha/intra-language.pl' method='POST' class='selectLang'>";
    }

    $html .="<input id='lang_server' name='lang_server' type='hidden' value=''>";   
    $html .="<input id='url' name='url' type='hidden' value=''>";

    $html .="<label for='language' class='left' >".i18n("Idioma").":";
    $html .="<p><select id='language' onChange='cambiarIdioma()' tabindex='-1'>";

    for($i=0;$i<scalar(@array_lang);$i++){
        if($session->param('locale') eq @array_lang[$i]){
            $html .="<option value='".@array_lang[$i]."' selected='selected'>".@array_lang[$i]."</option>"; 
        }elsif ( ($socio) && ($socio->getLocale() eq @array_lang[$i]) ){
            $html .="<option value='".@array_lang[$i]."' selected='selected'>".@array_lang[$i]."</option>"; 
        }else{
            $html .="<option value='".@array_lang[$i]."'>".@array_lang[$i]."</option>";
        }
    }

    $html .="</select></p></label>";
    if($type eq 'OPAC'){
        $html .="</fieldset>";
    }
    $html .="</form>";

    return $html;
}


sub getComboMatchMode {
    my $html= '';

    $html .="<select id='match_mode' tabindex='-1'>";
    $html .="<option value='SPH_MATCH_ANY' title='ASKLDNAKSJNDKJASNDNASKNKSD'>Coincidir con cualquier palabra</option>";
    $html .="<option value='SPH_MATCH_PHRASE'>Coincidir con la frase exacta</option>";
    $html .="<option value='SPH_MATCH_BOOLEAN'>Coincidir con valores booleanos (&), OR (|), NOT (!,-)</option>";
    $html .="<option value='SPH_MATCH_EXTENDED'>Coincidencia Extendida</option>";
    $html .="<option value='SPH_MATCH_ALL'>Coincidir con todas las palabras</option>";
    $html .="</select>";

    return $html;
}

sub getComboValidadores {
    my $html= '';

    $html .="<select id='combo_validate' tabindex='-1'>";
    my $validadores_hash_ref = C4::AR::Referencias::getValidadores();
    while ( my ($key, $value) = each(%$validadores_hash_ref) ) {
        $html .="<option value=".$key.">".$value."</option>";
    }

    $html .="</select>";

    return $html;
}

END { }       # module clean-up code here (global destructor)

1;
__END__