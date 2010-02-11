<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <meta http-equiv="cache-control" content="no-cache" />
  <meta http-equiv="expires" content="3600" />
  <meta name="revisit-after" content="2 days" />
  <meta name="robots" content="index,follow" />
  <meta name="publisher" content="Your publisher infos here ..." />
  <meta name="copyright" content="Your copyright infos here ..." />
  <meta name="author" content="Design: G. Wolfgang www.1-2-3-4.info / Author: Your author infos here ..." />
  <meta name="distribution" content="global" />
  <meta name="description" content="Your page description here ..." />
  <meta name="keywords" content="Your keywords, keywords, keywords, here ..." />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/default/includes/setup.css" />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/default/includes/jquery.alerts.css" />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/default/includes/text.css" />
  <link rel="icon" type="image/x-icon" href="[% temas %]/default/imagenes/favicon.ico" />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/fancybox.css" />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/ui.stars.css" />
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/wysiwyg.css" />
  <script type="text/javascript">
    token= '[% token %]';
    imagesForJS = '[% temas %]/[% tema %]/imagenes';
  </script>
  [% INCLUDE 'message_OPAC.inc' %]
  <script src="/includes/jquery/jquery.js" type="text/javascript"></script>
  <script src="/includes/AjaxHelper.js" type="text/javascript"></script>
  <script src="/includes/jquery/jquery.alerts.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.core.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.mouse.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.draggable.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.stars.js" type="text/javascript"></script>
  <script src="/includes/jquery/jquery.wysiwyg.js" type="text/javascript"></script>
  <script src="/includes/json/jsonStringify.js" type="text/javascript"></script>
  [% INCLUDE 'AutocompleteHelper.inc'  %]
  <script src="/includes/MessageHelper.js" type="text/javascript"></script>
  <script src="/includes/circulacionOPAC.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.easing.1.3.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.fancybox-1.2.1.pack.js" type="text/javascript"></script>
  
  <title>
    [% IF titulo_nombre_ui %]
        [% titulo_nombre_ui %]
    [% ELSE %]
        Meran - OPAC
    [% END %]
  </title>
  
  <script type="text/javascript">
      [% IF socio %]
          $(document).ready(function() {
              infoReservas();
              infoSanciones();
          });
      [% END %]
  </script>
</head>

<!-- Global IE fix to avoid layout crash when single word size wider than column width -->
<!--[if IE]><style type="text/css"> body {word-wrap: break-word;}</style><![endif]-->

<body>
  <!-- Main Page Container -->
  <noscript> 
      <p>[% 'DEBE HABILITAR SOPORTE PARA JAVASCRIPT EN SU NAVEGADOR, DE LO CONTRARIO NO PODRA NAVEGAR EL SITIO.' | i18n %]</p> 
  </noscript>
  
  <div class="page-container">
    <!-- For alternative headers START PASTE here -->
      [% INCLUDE 'opac-top-header.inc' %]
        [% INCLUDE 'opac-main_content.inc' %]
        [% INCLUDE 'opac-main_sub_content.inc' %]
  </div>
