<!DOCTYPE html>
<html lang="es-ES">

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
  <meta http-equiv="cache-control" content="no-cache" />
  <meta http-equiv="expires" content="3600" />
  <meta name="revisit-after" content="2 days" />
  <meta name="robots" content="index,follow" />
  <meta name="publisher" content="Grupo Meran" />
  <meta name="copyright" content="" />
  <meta name="author" content="Grupo Meran" />
  <meta name="distribution" content="global" />
  <meta name="description" content="OPAC" />
  <meta name="keywords" content="Your keywords, keywords, keywords, here ..." />

  <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
  <!--[if lt IE 9]>
    <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->
   
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/[% user_theme %]/includes/opac.css" />
  <link media="screen" rel="stylesheet" href="/includes/css/fancybox.css" type="text/css">
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/ui.stars.css" />
  <link rel="icon" type="image/x-icon" href="[% temas %]/[% user_theme %]/imagenes/favicon.ico" />

  <script type="text/javascript">
    var token               = '[% token %]';
    var imagesForJS         = '[% temas %]/[% tema %]/imagenes';
    var M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %] + "";
    var URL_PREFIX          = '[% url_prefix %]';
  </script>

  [% INCLUDE 'message_OPAC.inc' %]
  [% INCLUDE 'BootstrapToolkit.inc' %]
  <script src="/includes/AjaxHelper.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui/ui-min.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui/core.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.stars.js" type="text/javascript"></script>
  [% INCLUDE 'AutocompleteHelper.inc' %]
  <script src="/includes/jquery/jquery.wysiwyg.js" type="text/javascript"></script>
  <script src="/includes/json/jsonStringify.js" type="text/javascript"></script>
  <script src="/includes/MessageHelper.js" type="text/javascript"></script>
  <script src="/opac-tmpl/includes/circulacionOPAC.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.easing.1.3.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.fancybox.js" type="text/javascript"></script>
  <script src="/opac-tmpl/includes/favoritos.js" type="text/javascript"></script>
  <script type="text/javascript" src="/includes/jquery/jquery.expander.js"></script>
  <script src="/includes/util.js" type="text/javascript"></script>
  <script src="/includes/md5.js" type="text/javascript"></script>
  <script src="/includes/sha1.js" type="text/javascript"></script>
  <script src="/includes/jsthread.js" type="text/javascript"></script>
  <script type="text/javascript" src="/includes/opac.js"></script>	
  
  <title>
    [% IF titulo_nombre_ui %]
        [% titulo_nombre_ui %]
    [% ELSE %]
        Meran - OPAC
    [% END %]
  </title>

  [% IF socio_data.usr_permisos_opac %]
        [% IF !noAjaxRequests %]
        <script type="text/javascript">
          $(document).ready(function() {
            infoReservas();
            infoSanciones();
            setInterval(infoReservas,[% IF timeInterval %]
                                        [% timeInterval %]
                                     [% ELSE %]
                                        300000
                                     [% END %]
                                     );
            setInterval(infoSanciones,[% IF timeInterval %]
                                        [% timeInterval %]
                                     [% ELSE %]
                                        300000
                                     [% END %]
                                     );
          });
          </script>
        [% END %]
    [% END %]

    <script type="text/javascript">    

      $(document).ready(function() {
			$('.popover_button').popover({delay: { show: 800, hide: 100 }, placement: 'left',});
			$(".alert").alert();
          
                    $(function () {
                        var $alert = $('#alert_msg_main');
                        if($alert.length)
                        {
                            $alert.animate({height: $alert.css('line-height') || '50px'}, 200)
                            .click(function () {
                                window.close;
                                $alert.animate({height: '0'}, 200);
                            });
                        }
                    });
        });
	</script>
	
	
	</head>
	
	<!-- Global IE fix to avoid layout crash when single word size wider than column width -->
	<!--[if IE]><style type="text/css"> body {word-wrap: break-word;}</style><![endif]-->
	    
	<body lang="es-Es">
	<!-- POAR AHORA ES LA NAV -->
	   [% INCLUDE 'opac-top-header.inc' %]
		<div class="container">		   
			        [% IF content_title %]
			            <div class="title">[% content_title %]</div>  
			        [% END %]
			        [% IF partial_template %]
			              [% INCLUDE $partial_template %]
			        [% END %]
		        
