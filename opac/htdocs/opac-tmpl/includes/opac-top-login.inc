
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
<script src="/includes/jquery/jquery-highlight.js"></script>
<script src="/includes/util.js"></script>
<script src="/opac-tmpl/includes/opac-searchFunciones.js"></script>
<script src="/opac-tmpl/includes/favoritos.js"></script>
<script src="/opac-tmpl/includes/message_OPAC.inc"></script>
<script src="/includes/AutocompleteHelper.js"></script>

<link rel="stylesheet" type="text/css" href="[% temas %]/default/includes/opac.css">
<link rel="stylesheet" type="text/css" href="[% temas %]/[% tema %]/includes/opac.css">
</head>
<script language="javascript" type="text/javascript">

// FIXME esto esta repetido en el opac-top.inc, ver si se puede unificar
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
                <b>[% 'Su navegador no soporta o no tiene habilidato Javascript' | i18n %]</b>
        </font>
    </div>
</noscript>


[% IF nro_socio %]
    &nbsp;Ingres&oacute; como:<b> [% nro_socio %]</b>

    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Miembros' | i18n %]",
                                        url     => "/cgi-bin/koha/opac-user.pl", 
                                        title   => "[% 'Miembros' | i18n %]",
                                        boton   => "boton_miembros",
                                        width   => "95",
                                    ) ;
    [% END %]    
   
    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Salir' | i18n %]",
                                        url     => "/cgi-bin/koha/opac-main.pl?logout.x=1", 
                                        title   => "[% 'Salir' | i18n %]",
                                        boton   => "boton_salir",
                                        width   => "95",
                                    ) ;
    [% END %]    

[% ELSE %]
	[%  "OPAC" | setComboLang %]
[% END %]


[% INCLUDE 'opac-search.inc' %]

<div class="titulos_interior">[% pagetitle %]</div>

[% IF hiddesearch %]
[% ELSE %]
 <div class="buttonContainerHorizontal">
            <ul class="horizontal-list" >
    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Buscar' | i18n %]",
                                        url     => "/cgi-bin/koha/opac-search.pl", 
                                        title   => "[% 'Buscar' | i18n %]",
                                        boton   => "boton_registrarse",
                                        width   => "95",
                                    ) ;
    [% END %]    


    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Registrarse' | i18n %]",
                                        url     => "/cgi-bin/koha/join.html", 
                                        title   => "[% 'Registrarse' | i18n %]",
                                        boton   => "boton_registrarse",
                                        width   => "95",
                                    ) ;
    [% END %]    

[% END %]

    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Registrarse' | i18n %]",
                                        url     => "/cgi-bin/koha/opac-main.pl", 
                                        title   => "[% 'Registrarse' | i18n %]",
                                        boton   => "boton_registrarse",
                                        width   => "95",
                                    ) ;
    [% END %]    


    [% PERL %]
        print C4::AR::Filtros::link_to( text    => "[% 'Inicio' | i18n %]",
                                        url     => "/cgi-bin/koha/opac-main.pl", 
                                        title   => "[% 'Inicio' | i18n %]",
                                        boton   => "boton_inicio",
                                        width   => "95",
                                    ) ;
    [% END %]
</ul> 
</div>
	
<!-------------------------MAIN BODY OF PAGE-------------------------->
