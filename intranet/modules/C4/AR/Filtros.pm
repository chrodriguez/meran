package C4::AR::Filtros;

use strict;
require Exporter;
#use POSIX;
use Locale::Maketext::Gettext::Functions qw(__);
use Template::Plugin::Filter;
use CGI::Session;
use base qw( Template::Plugin::Filter );

use vars qw(@EXPORT_OK @ISA);
@ISA=qw(Exporter);
@EXPORT_OK=qw( 
    setHelpIco
    i18n
    link_to
    to_Button
    action_link_button
    action_button
    setHelpInput
    action_set_button
);

=item
    Esta funcion despliega un texto sobre un icono, una especia de ayuda.
=cut
sub setHelpIcon{
    my (%params_hash_ref) = @_;

    my $help    = '';
    $help       =  "<div class='hover_ico' title='".i18n($params_hash_ref{'text'})."'></div>";

    return $help;
}


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

    my $link    = '';
    my $params  = $params_hash_ref{'params'} || []; #obtengo los paraametros
    my $text    = $params_hash_ref{'text'}; #obtengo el texto a mostrar
    my $url     = $params_hash_ref{'url'}; #obtengo la url
    my $title   = $params_hash_ref{'title'}; #obtengo el title a mostrar
    my $class   = $params_hash_ref{'class'}; #obtengo la clase
    my $boton   = $params_hash_ref{'boton'}; #obtengo el title a mostrar
    my $width   = $params_hash_ref{'width'};
    my $blank   = $params_hash_ref{'blank'} || 0;
    my $cant    = scalar(@$params);
    my @result;
    
    foreach my $p (@$params){
        @result = split(/=/,$p);

        $url = C4::AR::Utilidades::addParamToUrl($url,@result[0],@result[1]);
    }

    my $session = CGI::Session->load();
    if($session->param('token')){
    #si hay sesion se usa el token, sino no tiene sentido
        my $status = index($url,'?');
         #SI NO HUBO PARAMETROS, EL TOKEN ES EL UNICO EN LA URL, O SEA QUE SE PONE ? EN VEZ DE &
        if (($cant > 0)||($status != -1)){
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

    if($blank){
        $link .= " target='blank'";
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

#   C4::AR::Debug::debug("url: ".$url);
#   C4::AR::Debug::debug("link: ".$link);

    return $link;
}

=item
Esta funcion es utilizada para la Internacionalizacion, lo que hace es tomar el parametro "text" del template
y hacer la traduccion del mismo, obteniedola del binario correspondiente, por ej. en_EN/LC_MESSAGES/intranet.mo
=cut
sub i18n {
    my ($text)      = @_;
# La inicializacion se paso toda a auth => checkauth
    return __($text);
}



sub to_Button__{
    my (%params_hash_ref) = @_;

    my $button= '';

    if ($params_hash_ref{'url'}){
      $button .="<a href="."$params_hash_ref{'url'}"."> ";
    }

    my $text    = $params_hash_ref{'text'}; #obtengo el texto a mostrar
    my $boton   = $params_hash_ref{'boton'}; #obtengo el boton
    my $onclick = $params_hash_ref{'onclick'} || $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onclick
    my $title   = $params_hash_ref{'title'}; #obtengo el title de la componete
    my $width   = length($text);
    my $id      = $params_hash_ref{'id'}; #obtengo el id del boton
    if($params_hash_ref{'width'}){
        if ($params_hash_ref{'width'}=="auto"){
            $width =$width+4;
            $width= $width."ex";
        }
        else{ $width= $params_hash_ref{'width'};
        }
    }
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';
    $button .=  '<li class="click boton_medio '.$alternClass.' " onclick="'.$onclick.'" style="width:'.$width.'"';

    if($title){
        $button .= ' title="'.$title.'"';
    }

    if(C4::AR::Utilidads::validateString($id)){
        $button .= ' id="'.$id.'"';
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

    #C4::AR::Debug::debug("Filtros => to_Button => ".$button);
    return $button;
}


sub to_Button{
    my (%params_hash_ref) = @_;

    my $button= '';


    my @array_clases_buttons = ('clean-gray','thoughtbot', 'btn btn-large btn-primary', 'btn btn-large', 'btn btn-primary','btn');  

    if ($params_hash_ref{'url'}){
      $button .="<a href="."$params_hash_ref{'url'}"."> ";
    }

    my $text    = $params_hash_ref{'text'}; #obtengo el texto a mostrar
    
    my $boton   = $params_hash_ref{'boton'} || "btn btn-primary"; #obtengo el boton
    
    if (!C4::AR::Utilidades::existeInArray($boton,@array_clases_buttons)){
        $boton = "btn btn-primary";
    }
    
    my $onclick     = $params_hash_ref{'onclick'} || $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onclick
    my $title       = $params_hash_ref{'title'}; #obtengo el title de la componete
    my $type        = $params_hash_ref{'type'} || 0; #obtengo el title de la componete
    my $show_inline = $params_hash_ref{'inline'} || 0; #obtengo el title de la componete
    my $width       = length($text);
    my $id          = $params_hash_ref{'id'}; #obtengo el id del boton
    if($params_hash_ref{'width'}){
        if ($params_hash_ref{'width'}=="auto"){
            $width =$width+4;
            $width= $width."ex";
        }
        else{ $width= $params_hash_ref{'width'};
        }
    }
    
    my $alternClass  = $params_hash_ref{'alternClass'} || 'horizontal';

    if($title){
    }

    if ($type){
        $type = "type= ".$type;
    }
    
    if (!$show_inline){
        $button .=  '<p style="text-align: center; margin: 0;">';
    }

    $button .=  '<button id="'.$id.'" class="'.$boton.' '.$alternClass.'" onclick="'.$onclick.'" '.$type.'>'.$text.'</button>';
    
    if (!$show_inline){
        $button .=  '</p>';
    }

    if ($params_hash_ref{'url'}){
      $button .="</a>";
    }

    #C4::AR::Debug::debug("Filtros => to_Button => ".$button);
    return $button;
}

sub setHelp{
    my (%params_hash_ref) = @_;

    my $help    = '';
#     $help       =  "<div class='reference'>".i18n($params_hash_ref{'text'})."</div>";
    $help       =  "<span class='help-inline'>".i18n($params_hash_ref{'text'})."</span>";
    return $help;
}


=item 
Ffuncion que crea los mensajes de ayuda en los inputs
Recibe como parametro una hash con:
    textLabel: texto del label
    class: clase del label (para darle colores, sino pone una por default)
    text: texto de ayuda
    
Ejemplo:
        text        => "[% 'El M&eacute;todo se agrega deshabilitado por defecto.' | i18n %]",
        class       => "info",
        textLabel   => "NOTA:"    
=cut
sub setHelpInput{

    my (%params_hash_ref)       = @_;
    
    my @array_clases_labels     = ('success','warning', 'important', 'info');
    
    my $classLabel              = $params_hash_ref{'class'} || "label";
    my $textLabel               = $params_hash_ref{'textLabel'} || "";
    my $help                    = "";
    
    if (!C4::AR::Utilidades::existeInArray($classLabel,@array_clases_labels)){
        $classLabel = "label";
    }
    
    if($classLabel ne "label"){
        $classLabel = "label label-" . $classLabel;
    }
    
    if($textLabel eq ""){
    
        $help                    = "<p class='help-block'>"
                                    . $params_hash_ref{'text'} . "</p>";
    
    }else{
       
        $help                    = "<p class='help-block'><span class='"
                                        . $classLabel . "'>"
                                        . $params_hash_ref{'textLabel'} . "</span>"
                                        . $params_hash_ref{'text'} . "</p>";
                                    
    }

    return $help;                                    
   
}


sub to_Icon{
    my (%params_hash_ref) = @_;

    my $button  = '';
    my $boton   = $params_hash_ref{'boton'}; #obtengo el boton
    my $onclick = $params_hash_ref{'onclick'} || $params_hash_ref{'onClick'}; #obtengo el llamado a la funcion en el evento onclick
    my $title   = $params_hash_ref{'title'}; #obtengo el title de la componete
    
    my $alternClass     = $params_hash_ref{'alternClass'} || 'horizontal';

    my $open_elem       = "<div ";
    my $close_elem      = "</div>";

    if ($params_hash_ref{'id'}){
        $open_elem     .= "id='".$params_hash_ref{'id'}."' ";
    }
      
    my $style = $params_hash_ref{'style'} || '';
    if ($params_hash_ref{'elem'}){
        $open_elem  = "<".$params_hash_ref{'elem'};
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

sub show_componente {
    my (%params_hash_ref) = @_;

    my $campo               = $params_hash_ref{'campo'};
    my $subcampo            = $params_hash_ref{'subcampo'};
    my $dato                = $params_hash_ref{'dato'};
    my $id1                 = $params_hash_ref{'id1'};
    my $id2                 = $params_hash_ref{'id2'};

    my $session             = CGI::Session->load();
    my $session_type        = $session->param('type') || 'opac';
     
    if(($campo eq "245")&&($subcampo eq "a")) {

      my $catRegistroMarcN1   = C4::AR::Nivel1::getNivel1FromId1($id1);

#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => campo, subcampo: ".$campo.", ".$subcampo); 
#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => DENTRO => dato: ".$dato);

        if($catRegistroMarcN1){
            my %params_hash;
            my $text        = $catRegistroMarcN1->getTitulo(); 
            %params_hash    = ('id1' => $catRegistroMarcN1->getId1());
            my $url;

            if ($session_type eq 'intranet'){
                $url         = C4::AR::Utilidades::url_for("/catalogacion/estructura/detalle.pl", \%params_hash);
            }else{
                $url         = C4::AR::Utilidades::url_for("/opac-detail.pl", \%params_hash);
            }

            return C4::AR::Filtros::link_to( text => $text, url => $url , blank => 1);
        }
        
        return "NO_LINK";
    }
    
    if(($campo eq "856")&&($subcampo eq "u")) {


        C4::AR::Debug::debug("C4::AR::Filtros::show_componente => campo, subcampo: ".$campo.", ".$subcampo); 
        C4::AR::Debug::debug("C4::AR::Filtros::show_componente => DENTRO => dato: ".$dato);
        
        return C4::AR::Filtros::link_to( text => $dato, url => $dato , blank => 1);

    }

    if(($campo eq "773")&&($subcampo eq "a")&&($dato ne "")) {

            
        my $nivel2_object       = C4::AR::Nivel2::getNivel2FromId2($dato);

    if(!$nivel2_object){
        return "NO_LINK";
    }   

        $id1                    = $nivel2_object->getId1();
        my $catRegistroMarcN1   = C4::AR::Nivel1::getNivel1FromId1($id1);

#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => campo, subcampo: ".$campo.", ".$subcampo); 
#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => DENTRO => dato: ".$dato);

        if($catRegistroMarcN1){
            my %params_hash;
            my $text        = $catRegistroMarcN1->getTitulo(); 
            %params_hash    = ('id1' => $catRegistroMarcN1->getId1());
            my $url;

            if ($session_type eq 'intranet'){
                $url         = C4::AR::Utilidades::url_for("/catalogacion/estructura/detalle.pl", \%params_hash);
            }else{
                $url         = C4::AR::Utilidades::url_for("/opac-detail.pl", \%params_hash);
            }

#             C4::AR::Debug::debug("C4::AR::Filtros::show_componente => DENTRO => url: ".$url);

            return C4::AR::Filtros::link_to( text => $text, url => $url , blank => 1);
        }
        
        return "NO_LINK";
    }

    return "NO_LINK";
}


# sub show_componente {
#     my (%params_hash_ref) = @_;
# 
#     my $campo               = $params_hash_ref{'campo'};
#     my $subcampo            = $params_hash_ref{'subcampo'};
#     my $dato                = $params_hash_ref{'dato'};
#     my $itemtype            = $params_hash_ref{'itemtype'};
#     my $type                = $params_hash_ref{'type'};
# 
#     my $session             = CGI::Session->load();
#     my $session_type        = $session->param('type') || 'opac';
#      
#     if(($campo eq "245")&&($subcampo eq "a")) {
# 
#       my $catRegistroMarcN2   = C4::AR::Nivel2::getNivel2FromId2($dato);
# 
#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => campo, subcampo: ".$campo.", ".$subcampo); 
# 
#       C4::AR::Debug::debug("C4::AR::Filtros::show_componente => DENTRO => dato: ".$dato);
# 
#         if($catRegistroMarcN2){
#             my %params_hash;
#             my $text        = $catRegistroMarcN2->nivel1->getTitulo()." (".$catRegistroMarcN2->nivel1->getAutor().") - ".$catRegistroMarcN2->toString; 
#             %params_hash    = ('id1' => $catRegistroMarcN2->getId1());
#             my $url;
# 
#             if ($session_type eq 'intranet'){
#               $url         = C4::AR::Utilidades::url_for("/catalogacion/estructura/detalle.pl", \%params_hash);
#             }else{
#                 $url         = C4::AR::Utilidades::url_for("/opac-detail.pl", \%params_hash);
#             }
# 
#             return C4::AR::Filtros::link_to( text => $text, url => $url );
#         }
#         
#     } elsif($type eq "INTRA") {
#         if(($campo eq "773")&&($subcampo eq "a")){
#             my $catRegistroMarcN2   = C4::AR::Nivel2::getNivel2FromId2($dato);
#     
# # TODO FIXEDDDDDDDDDD en el futuro esto se debe levantar de la configuracion
#             if($catRegistroMarcN2){
# 
#                 #obtengo las analiticas
#                 my $cat_reg_marc_n2_analiticas = $catRegistroMarcN2->getAnaliticas();
#   
#                 if(scalar(@$cat_reg_marc_n2_analiticas) > 0){
#                      #no tiene analiticas
#                     C4::AR::Debug::debug("C4::AR::Filtros::show_componente => TIENE ANALITICAS"); 
#                     my %params_hash;
#                     my $text        = $catRegistroMarcN2->nivel1->getTitulo()." (".$catRegistroMarcN2->nivel1->getAutor().") - ".$catRegistroMarcN2->toString; 
#                     %params_hash    = ('id1' => $catRegistroMarcN2->getId1());
#                     my $url         = C4::AR::Utilidades::url_for("/catalogacion/estructura/detalle.pl", \%params_hash);
# 
#                     return C4::AR::Filtros::link_to( text => $text, url => $url );
#                 }
# 
# #                 aca tengo que identificar si este nivel 2 es padre o hijo de una analitica para cambiar el link               
#             } else {
#                 C4::AR::Debug::debug("C4::AR::Filtros::show_componente => NO TIENE ANALITICAS"); 
#             }
#         }
#     } else {
# # TODO FIXEDDDDDDDDDD en el futuro esto se debe levantar de la configuracion
#         if(($campo eq "773")&&($subcampo eq "a")){
#             my $catRegistroMarcN2 = C4::AR::Nivel2::getNivel2FromId2($dato);
#     
#             if($catRegistroMarcN2){
#                 return $catRegistroMarcN2->nivel1->getTitulo()." (".$catRegistroMarcN2->nivel1->getAutor().") - ".$catRegistroMarcN2->toString; 
#             }
#         }
#     }
# 
#     return $dato;
# }

sub ayuda_marc{

    my $icon= to_Icon(  
                boton   => "icon_ayuda_marc",
                onclick => "abrirVentanaHelperMARC();",
                title   => i18n("Ayuda MARC"),
            ) ;

    return "<div style='float: right;'><span class='click'>".$icon."</span></div><div id='ayuda_marc_content'></div>";
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

    my ($type,$theme) = @_;
    my $session = CGI::Session->load();
    my $html= '<ul class="culture_selection">';
    my $lang_Selected= $session->param('usr_locale');
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

    my $token   =   $session->param('token');
    my $url = $ENV{'REQUEST_URI'};
    if($type eq 'OPAC'){
        $href = C4::AR::Utilidades::getUrlPrefix().'/opac-language.pl?token='.$token.'&amp;';
    }else{
        $href = C4::AR::Utilidades::getUrlPrefix().'/intra-language.pl?token='.$token.'&amp;';
    }

    my $flags_dir = C4::Context->config('temasOPAC').'/'.$theme.'/imagenes/flags';
    if ($type eq 'INTRA'){
        $flags_dir = C4::Context->config('temas').'/'.$theme.'/imagenes/flags';
    }
    foreach my $hash_temp (@array_lang){
            $html .='<li><a href='."$href"."lang_server=".$hash_temp->{'lang'}.' title="'.$hash_temp->{'title'}.'"><img src='."$flags_dir".'/'.$hash_temp->{'flag'}.' alt="'.i18n("Cambio de lenguaje").'" /></a></li>';
    }
    $html .="</ul>";

    return $html;
}

sub getComboMatchMode {
    my $html= '';

    $html .="<select id='match_mode' tabindex='-1'>";
    $html .="<option value='SPH_MATCH_PHRASE'>".i18n("Coincidir con la frase exacta")."</option>";
    $html .="<option value='SPH_MATCH_ANY'>".i18n("Coincidir con cualquier palabra")."</option>";
    $html .="<option value='SPH_MATCH_BOOLEAN'>".i18n("Coincidir con valores booleanos (&), OR (|), NOT (!,-)")."</option>";
    $html .="<option value='SPH_MATCH_EXTENDED' selected='selected'>".i18n("Coincidencia Extendida")."</option>";
    $html .="<option value='SPH_MATCH_ALL'>".i18n("Coincidir con todas las palabras")."</option>";
    $html .="</select>";

    return $html;
}

sub getComboLang {
    my $html= '';

    my @languages = ("es_ES","en_EN");
    my %languages_name = {};
    $languages_name{'es_ES'} = "Espa&ntilde;ol";
    $languages_name{'en_EN'} = "English";


    my $user_lang = C4::AR::Auth::getUserLocale(); 
    my $default = "";

    $html .="<select id='language' name='language' tabindex='-1' style='width:170px;'>";

    foreach my $lang (@languages){
        if ($user_lang eq $lang){
           $default = "selected='selected'";
           $html .="<option value='$lang' $default>".$languages_name{$lang}."</option>";
        }else{
           $html .="<option value='$lang '>".$languages_name{$lang}."</option>";
            
        }
    }
    
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

sub action_link_button{

    my (%params_hash_ref) = @_;

    my $url      = $params_hash_ref{'url'} || $params_hash_ref{'url'}; #obtengo el llamado a la funcion en el evento onclick
    my $button   = $params_hash_ref{'button'}; #obtengo el boton
    my $icon     = $params_hash_ref{'icon'} || undef;  #obtengo el boton
    my $params   = $params_hash_ref{'params'} || $params_hash_ref{'url'}; #obtengo el llamado a la funcion en el evento onclick
    my $title    = $params_hash_ref{'title'}; #obtengo el title de la componete
    my @result;
    
    foreach my $p (@$params){
        @result = split(/=/,$p);

        $url = C4::AR::Utilidades::addParamToUrl($url,@result[0],@result[1]);
    }
    
    my $html = "<a class='".$button."' href='".$url."'><i class='".$icon."'></i>".$title."</a>";
    
    return $html;
}

sub action_button{

    my (%params_hash_ref) = @_;

    my $action    = $params_hash_ref{'action'};
    my $button   = $params_hash_ref{'button'}; #obtengo el boton
    my $icon     = $params_hash_ref{'icon'} || undef;  #obtengo el boton
    my $title    = $params_hash_ref{'title'}; #obtengo el title de la componete

    $button.= " click";
    
    my $html = "<a class='".$button."' onclick='".$action."'><i class='".$icon."'></i>".$title."</a>";
    
    return $html;
}


sub action_set_button{
	my (%params_hash_ref) = @_;
	
    my $title       = $params_hash_ref{'title'}; #obtengo el title de la componete
    my $icon  = $params_hash_ref{'icon'} || 'icon white user'; #obtengo el title de la componete

    my $actions     = $params_hash_ref{'actions'} || [];
    
    my $button   = $params_hash_ref{'button'} || "btn btn-primary";
    
     my $html = "<div class='btn-group'><a class='$button' class='click'><i class='$icon'></i>$title</a>";
    $html.= "<a class='$button dropdown-toggle' data-toggle='dropdown' href='#'><span class='caret'></span></a>";
    $html.= "<ul class='dropdown-menu'>";
    
    foreach my $action (@$actions){
        my $name = $action->{'title'};
        my $func = $action->{'action'};
        my $url  = $action->{'url'};
        my $icon = $action->{'icon'};
        if ($func){
            $html .= "<li><a class='click' onclick='$func' ><i class='$icon' ></i> $name</a></li>";
        }else{
            my $params   =  $action->{'params'} ||  $action->{'url'};
            my @result;
            foreach my $p (@$params){
                @result = split(/=/,$p);
                $url = C4::AR::Utilidades::addParamToUrl($url,@result[0],@result[1]);
            }
            $html .= "<a class='click' href='$url'><i class='$icon'></i>$title</a>";
        }

    }

    $html.= "</ul></div>";
    
    return $html;	
}

sub tableHeader{
    my (%params_hash_ref) = @_;
    
    my $id          = $params_hash_ref{'id'}; 
    my $class       = $params_hash_ref{'class'} || undef;
    my $select_all  = $params_hash_ref{'selectAll_id'} || undef;
    
    my $columns     = $params_hash_ref{'columns'};
    
    my $html = "<table id=$id class='table table-striped $class'><thead>";
    
    if ($select_all){
        $html .= "<th>S_ALL</th>";
    }
    
    foreach my $column (@$columns){
        $html .= "<th>$column</th>";

    }

    $html .= "</thead>";
    
    return $html;	
}

sub action_group_link_button{
	my (%params_hash_ref) = @_;
	
    my $actions     = $params_hash_ref{'actions'} || [];
    
    
    my $html = "<div class='btn-group'>";
   
    foreach my $action (@$actions){
        my $url   =  $action->{'url'}; #obtengo la url si es un link 
        my $title = $action->{'title'};
		my $icon  = $action->{'icon'};
		my $class = $action->{'class'};
		
        if($url){
			#ES UN LINK
			my $params   =  $action->{'params'} ||  $action->{'url'}; #obtengo el llamado a la funcion en el evento onclick
			my @result;
			foreach my $p (@$params){
				@result = split(/=/,$p);
				$url = C4::AR::Utilidades::addParamToUrl($url,@result[0],@result[1]);
			}
			$html .= "<a class='click btn $class' href='$url'><i class='$icon'></i>$title</a>";
		}
		else{
			#ES UNA ACCION
			my $func = $action->{'action'}; #obtengo la funcion si es una accion
			$html .= "<a class='click btn $class' onclick='$func' ><i class='$icon'></i>$title</a>";
		}

    }

    $html.= "</div>";
    
    return $html;	
}

END { }       # module clean-up code here (global destructor)

1;
__END__
