<html>
<head>
<title>[% titulo_nombre_ui %]</title>

<script language="javascript" type="text/javascript">
    token= '[% token %]';
</script>

<script src="/includes/jquery/jquery.js"></script>
<script src="/includes/AjaxHelper.js"></script>
<script src="/includes/MessageHelper.js"></script>
<script src="/includes/json/jsonStringify.js"></script>
<script src="/opac-tmpl/includes/navegador.js"></script>
<script src="/includes/jquery/jquery-highlight.js"></script>
<script src="/includes/util.js"></script>
<script src="/opac-tmpl/includes/opac-searchFunciones.js"></script>
<script src="/opac-tmpl/includes/circulacionOPAC.js"></script>
<script src="/opac-tmpl/includes/favoritos.js"></script>
<script src="/opac-tmpl/includes/message_OPAC.inc"></script>
<script src="/includes/AutocompleteHelper.js"></script>


[% INCLUDE  'AutocompleteHelper.inc'  %]

<meta http-equiv="Content-Type" content="text/html; charset=utf-8">

<link rel="stylesheet" type="text/css" href="[% temas %]/default/includes/opac.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/opac.css">
</head>
<script language="javascript" type="text/javascript">

function swap(id,src){
	document.getElementById(id).src=src;
}

function cambiarIdioma() {
	$('#lang_server').val($('#language').val());
	$('#url').val(location.pathname);
	$('#formLang').submit();
}

</script>
<body>

<noscript>
    <div class='tableMsgUser'>
        <font class='fontMsgUser'>
                <b>[% "Su navegador no soporta o no tiene habilidato Javascript" | i18n %]</b>
        </font>
    </div>
</noscript>

<div id="login-container">
[% IF nro_socio %]
    [%  "OPAC" | setComboLang %]

    [% "Ingres&oacute; como:" | i18n %]<b> [% nro_socio %]</b>

    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Miembros' | i18n %]",
                                        boton   => "boton_miembros",
                                        width   => "95",
                                        url     => "/cgi-bin/koha/opac-user.pl", 
                                        title   => "[% 'Miembros' | i18n %]"
                                    ) ;
    [% END %]

    [% PERL %]
            print C4::AR::Filtros::link_to( text    => "[% 'Salir' | i18n %]",
                                            boton   => "boton_salir", 
                                            width   => "95",
                                            url     => "/cgi-bin/koha/opac-main.pl?logout.x=1", 
                                            title   => "[% 'Salir' | i18n %]"
                                    ) ;
    [% END %]

[% ELSE %]

    [%  "OPAC" | setComboLang %]

[% END %]
</div>

<div id="marco_principal">
    <div id="marco_superior">  <div></div></div>

<div id="marco_contenido" class="contenido">
    <div id="marco_busqueda">[% INCLUDE "opac-search.inc" %]</div>

    <div id="menu-container" class="main-header">

    [% IF nro_socio %]

            [% PERL %]
                print C4::AR::Filtros::to_Button(   text    => "[% 'Ver mis favoritos' | i18n %]",
                                                    boton   => "boton_favoritos", 
                                                    width   => "125",
                                                    onClick => "consultarFavoritos();",
                                                    title   => "[% 'Ver mis favoritos' | i18n %]"
                                            ) ;
            [% END %]

    [% END %]  

        [% PERL %]
            print C4::AR::Filtros::link_to( text    => "[% 'Registrarse' | i18n %]",
                                            boton   => "boton_registrarse", 
                                            width   => "95",
                                            url     => "/join.html", 
                                            title   => "[% 'Registrarse' | i18n %]"
                                        ) ;
        [% END %]  

        [% IF hiddesearch %]
        [% ELSE %]
            [% PERL %]
                        print C4::AR::Filtros::link_to( text    => "[% 'Buscar' | i18n %]",
                                                        boton   => "boton_buscar", 
                                                        width   => "95",
                                                        url     => "/cgi-bin/koha/opac-search.pl", 
                                                        title   => "[% 'Buscar' | i18n %]"
                                                    ) ;
            [% END %]  
        [% END %]

        [% PERL %]
                    print C4::AR::Filtros::link_to( text    => "[% 'Inicio' | i18n %]",
                                                    boton   => "boton_inicio", 
                                                    width   => "95",
                                                    url     => "/cgi-bin/koha/opac-main.pl", 
                                                    title   => "[% 'Inicio' | i18n %]"
                                                ) ;
        [% END %]  

    </div>

<div id="marco_contenido_datos" class="contenido">

<!-- usado como referencia por el MessageHelper     -->
<div id="end_top"></div>
	
