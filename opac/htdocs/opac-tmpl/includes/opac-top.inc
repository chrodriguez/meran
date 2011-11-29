<!doctype html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

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
  <link rel="stylesheet" type="text/css" media="screen,projection,print" href="[% temas %]/[% user_theme %]/includes/opac.css" />

  <link rel="icon" type="image/x-icon" href="[% temas %]/[% user_theme %]/imagenes/favicon.ico" />
<!-- variables de entorno sacadas de las preferencias del sistema -->
  <script type="text/javascript">
    var token= '[% token %]';
    var imagesForJS = '[% temas %]/[% tema %]/imagenes';
// TODO no esta recuperando este valor
    var M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %] + "";
    var URL_PREFIX  = '[% url_prefix %]';

  </script>

  [% INCLUDE 'message_OPAC.inc' %]
  <script src="/includes/jquery/jquery.js" type="text/javascript"></script>
  <script src="/includes/AjaxHelper.js" type="text/javascript"></script>
  <script src="/includes/jquery/jquery.alerts.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui/ui-min.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui/core.js" type="text/javascript"></script>
  <script src="/includes/jquery/ui.stars.js" type="text/javascript"></script>
  <script src="/includes/jquery/jquery.wysiwyg.js" type="text/javascript"></script>
  <script src="/includes/json/jsonStringify.js" type="text/javascript"></script>
  [% INCLUDE 'AutocompleteHelper.inc'  %]
  <script src="/includes/MessageHelper.js" type="text/javascript"></script>
  <script src="/opac-tmpl/includes/circulacionOPAC.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.easing.1.3.js" type="text/javascript"></script>
  <script src="/includes/jquery/fancybox/jquery.fancybox.js" type="text/javascript"></script>
  <script type="text/javascript" src="/includes/jquery/modal/jquery.simplemodal.js"></script>
  <script src="/opac-tmpl/includes/favoritos.js" type="text/javascript"></script>
  <script type="text/javascript" src="/includes/jquery/jquery.expander.js"></script>
  <script src="/includes/util.js" type="text/javascript"></script>
  <script src="/includes/md5.js" type="text/javascript"></script>
  <script src="/includes/sha1.js" type="text/javascript"></script>
  <script src="/includes/jsthread.js" type="text/javascript"></script>
  <script type="text/javascript" src="/includes/jquery/jquery.tmpl.js"></script>	
  
  <link media="screen" rel="stylesheet" href="/includes/jquery/modal/basic-min.css" type="text/css" />

  <title>
    [% IF titulo_nombre_ui %]
        [% titulo_nombre_ui %]
    [% ELSE %]
        Meran - OPAC
    [% END %]
  </title>
  
  <script type="text/javascript">
      [% IF socio_data.usr_permisos_opac %]
	      [% IF !noAjaxRequests %]
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
      [% END %]
      [% END %]
      

	
  </script>

    <script type="text/javascript">    

        function enviar(){
              [% IF plainPassword == 0 %]
                  var nroRandom   = [% nroRandom %];
                  var hash        = b64_sha256(b64_sha256(b64_md5($("#password_plain").val()))+nroRandom);
                  $("#password").val(hash);
              [% ELSE %]
                  $("#password").val($("#password_plain").val());
              [% END %]
              return true;
      }
      var RecaptchaOptions = {
   
        theme : 'white',
//         lang : 'es,   
        
      }
      
      $(document).ready(function() {


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


                  //onEnter con foco en input, ejecuta la busqueda
                    var RecaptchaOptions = {
                        theme : 'blue', /* tema color blanco */
                        lang : 'es' /* idioma español */
                    };    

                    onEnter("password",enviar);


                    // When you click on #search
                    $("#search").focus(function(){

                        // If the value is equal to "Search..."
                        if($(this).val() == "Buscar...") {
                            // remove all the text and the class of .empty
                            $(this).val("").removeClass("empty");;
                        }

                    });

                    [% IF !loginFailed  %]
                        try {$("#search").focus();} catch (e){}
                    [% ELSE %]
                    try {$("#userid").focus();} catch (e){}
                    [% END %]

            $(".signin").click(function(e) {          
                e.preventDefault();
                $("fieldset#signin_menu").toggle();
                $(".signin").toggleClass("menu-open");
            });
            
            $("fieldset#signin_menu").mouseup(function() {
                return false
            });
            $(document).mouseup(function(e) {
                if($(e.target).parent("a.signin").length==0) {
                    $(".signin").removeClass("menu-open");
                    $("fieldset#signin_menu").hide();
                }
            });         
            
        });
</script>


</head>

<!-- Global IE fix to avoid layout crash when single word size wider than column width -->
<!--[if IE]><style type="text/css"> body {word-wrap: break-word;}</style><![endif]-->
    
<body lang="es-Es">
  <!-- Main Page Container -->
  <noscript> 
      <p>[% 'DEBE HABILITAR SOPORTE PARA JAVASCRIPT EN SU NAVEGADOR, DE LO CONTRARIO NO PODRA NAVEGAR EL SITIO.' | i18n %]</p> 
  </noscript>

[% IF mostrar_fondo_home %]
  <div class="page-container page-container-background">
[% ELSE %]
  <div class="page-container">
[% END %]
    <!-- For alternative headers START PASTE here -->
        [% INCLUDE 'opac-top-header.inc' %]
        [% INCLUDE 'opac-main_content.inc' %]
        [% INCLUDE 'opac-main_sub_content.inc' %]
        <div id="loading_items" class="loading_items"><br /></div>
        
  </div>
