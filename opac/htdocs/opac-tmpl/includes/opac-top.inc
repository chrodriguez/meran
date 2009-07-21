<html>
<head>
<title>
    [% IF titulo_nombre_ui %]
        [% titulo_nombre_ui %]
    [% ELSE %]
        Meran - OPAC
    [% END %]
</title>

<script language="javascript" type="text/javascript">
    token= '[% token %]';
</script>

<script src="/includes/jquery/jquery.js"></script>
<script src="/includes/AjaxHelper.js"></script>
<script src="/includes/MessageHelper.js"></script>
<script src="/includes/json/jsonStringify.js"></script>
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
    <div class="buttonContainerHorizontal" style="width:100%">
        [% IF nro_socio %]
            <ul class="horizontal-list-default" style="float:right" >
                        <li>
                            [%  "OPAC" | setComboLang %]
                        </li>
                        &nbsp;
                        <li>
                            [% "Ingres&oacute; como:" | i18n %]<b> [% nro_socio %]</b>
                        </li>
                        &nbsp;
            </ul>
            <ul class="horizontal-list-default" style="float:left" >
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
                <li>
                    [%  "OPAC" | setComboLang %]
                </li>
            </ul>
        [% END %]
    </div>
</div>

<div id="marco_principal">
    <div id="marco_superior">  <div></div></div>
    <div id="end_top"></div>

<div id="marco_contenido" class="contenido">
    <div id="marco_busqueda">[% INCLUDE "opac-search.inc" %]</div>

<!--     <div id="menu-container" class="main-header"> -->

        <div class="buttonContainerHorizontal">
            <ul class="horizontal-list" >

                [% IF nro_socio %]

                        [% PERL %]
                            print C4::AR::Filtros::to_Button(   text    => "[% 'Ver mis favoritos' | i18n %]",
                                                                boton   => "boton_favoritos", 
                                                                width   => "125",
                                                                onClick => "consultarFavoritos();",
                                                                title   => "[% 'Ver mis favoritos' | i18n %]"
                                                        ) ;
                        [% END %]

                        [% PERL %]
                            print C4::AR::Filtros::to_Button( text    => "[% 'Historial de Prestamos' | i18n %]",
                                                            boton   => "boton_miembros",
                                                            width   => "150",
                                                            onClick => "mostrarHistorialPrestamos([% socio.getNro_socio %]);",
                                                            title   => "[% 'Mostrar Historial de Prestamos' | i18n %]"
                                                        ) ;
                        [% END %]

                        [% PERL %]
                            print C4::AR::Filtros::to_Button(   text    => "[% 'Historial de Reservas' | i18n %]",
                                                                boton   => "boton_favoritos", 
                                                                width   => "150",
                                                                onClick => "mostrarHistorialReservas([% socio.getNro_socio %]);",
                                                                title   => "[% 'Mostrar Historial de Reservas' | i18n %]"
                                                        ) ;
                        [% END %]

                [% END %]

                [% PERL %]
                    print C4::AR::Filtros::link_to( text    => "[% 'Registrarse' | i18n %]",
                                                    boton   => "boton_registrarse", 
                                                    width   => "95",
                                                    class   => "horizontal",
                                                    url     => "/join.html", 
                                                    title   => "[% 'Registrarse' | i18n %]"
                                                ) ;
                [% END %]  

                [% IF hiddesearch %]
                    <!-- Y ACA?????? DO NOTHING????? -->
                [% ELSE %]
                    [% PERL %]
                                print C4::AR::Filtros::link_to( text    => "[% 'Buscar' | i18n %]",
                                                                boton   => "boton_buscar", 
                                                                width   => "95",
                                                                url     => "/cgi-bin/koha/opac-search.pl", 
                                                                class   => "horizontal",
                                                                title   => "[% 'Buscar' | i18n %]"
                                                            ) ;
                    [% END %]  
                [% END %]

                [% PERL %]
                            print C4::AR::Filtros::link_to( text    => "[% 'Inicio' | i18n %]",
                                                            boton   => "boton_inicio", 
                                                            width   => "95",
                                                            class   => "horizontal",
                                                            url     => "/cgi-bin/koha/opac-user.pl", 
                                                            title   => "[% 'Inicio' | i18n %]"
                                                        ) ;
                [% END %]

            </ul>
    </div>
</div>
<!-- usado como referencia por el MessageHelper     -->

