<!doctype html>
<html>
	<head>
	[% INCLUDE "message_INTRA.inc" %]
	<script type="text/javascript">
	//     <!-- variables de entorno sacadas de las preferencias del sistema -->
	    token       = '[% token %]';
	    imagesForJS = '[% temas %]/[% tema %]/imagenes';
	    M_LIMITE_RESULTADOS = [% limite_resultados_autocompletables %] + 0;
	    var URL_PREFIX  = '[% url_prefix %]';
	    var UNLOAD		= '[% unload_alert %]';
	    
	</script>
	
	[% IF page_sub_title %]
	    <title>Meran::UNLP::[% page_sub_title %]</title>
	[% ELSE %]
	    <title>Meran::UNLP</title>
	[% END %]
	
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<META HTTP-EQUIV="cache-control" content="public">
	<link rel="stylesheet" type="text/css" href="[% temas %]/[% user_theme_intra %]/includes/completo.css">
	<script type="text/javascript" src="/includes/json/jsonStringify.js"></script>
	<script type="text/javascript" src="/includes/completo-intranet-top.js"></script>
	<script type="text/javascript" src="/includes/jquery/modal/jquery.simplemodal.js"></script>
	<link media="screen" rel="stylesheet" href="/includes/jquery/modal/basic-min.css" type="text/css">
	<script type="text/javascript" src="/includes/jquery/fancybox/jquery.easing.1.3.js"></script>
	<script type="text/javascript" src="/includes/jquery/fancybox/jquery.fancybox.js"></script>
	<script type="text/javascript" src="/includes/jquery/fancybox/jquery.mousewheel.js"></script>
	<script type="text/javascript" src="/includes/jquery/jquery-ui-1.8.9.custom.min.js"></script>
	<script type="text/javascript" src="/includes/shiftSelectTr.js"></script>
	<script type="text/javascript" src="/includes/jquery/jquery.expander.js"></script>
	<script type="text/javascript">
	
		function swap(id,src){
			   document.getElementById(id).src=src;
		}
		
		function cambiarIdioma() {
			$('#lang_server').val($('#language').val());
			$('#url').val(location.pathname);
			$('#formLang').submit();
		}
			
		function searchesText(objectId){
			
			var text              = [% "'Que quiere buscar?'" | i18n %];
			var search            =  $('#'+objectId);
			
	        if ($.trim(search.val()) == ''){
	        	search.val(text);
	        	search.addClass("search-title");
	        }
		}
		
		function searchBoxFocus(object){	
	        object.value='';
		}
		
	    function checkTr(){
	        // click sobre los <tr>, para darle estilo
	        $('tr').click(function() {
	            var clase = $(this).attr('class').split(' ');
	            //solo los <tr> que tengan en el primer <td> un input checkbox
	            if($(this).children(':first-child').children(':first-child').attr('type') == 'checkbox'){
	                if(clase[1] == 'marked'){
	                    $(this).removeClass("marked"); 
	                    $(this).children(':first-child').children(':first-child').removeAttr('checked');
	                }else{
	                    $(this).addClass("marked");
	                    $(this).children(':first-child').children(':first-child').attr('checked','true');
	                }
	            }
	        });     
	        //seleccion con shift
	        $(function() {
	            $('tr').shiftClick();
	        }); 
	    }
		
		$(document).ready(function(){
			checkTr();
			$('input[type="text"]').focus(function() {  
			    $(this).removeClass("textInput").addClass("focusInput");  
			});
	        $('input[type="text"]').addClass("textInput");    

			if (UNLOAD)
		        $(window).bind('beforeunload', function(){ 
		        	return("[% 'ATENCION: Se perderan los elementos que no haya guardado' | i18n %]");
		        });
	    });
	</script>
	</head>
	<body>
	  <noscript>
	      <div class='tableMsgUser'>
	          <font class='fontMsgUser'>
	                  <b>[% 'Su navegador no soporta o no tiene habilidato Javascript' | i18n %]</b>
	          </font>
	      </div>
	  </noscript>
	  
	  <div style="display: none;" id="ajax-indicator">
	    <div><p>[% 'Cargando...' | i18n %]</p></div>
	  </div>

	  <header>
	  	[% INCLUDE   'menu.inc'  %]
	  </header>
	<!--  </div> -->
	  
	  <div id="marco_principal">
	     <div id="marco_contenido" class="contenido">
	  
	  
		  <div id="marco_contenido_datos" class="contenido">
		  <!--  usado como referencia por el MessageHelper -->
		  <div id="end_top">
		    [% IF mensaje %]
		        <div class="mensajes_informacion">
		            <div id="mensajes" style="opacity: 90; display: block;">
		                <div class="message_text">[% mensaje %]</div>
		            </div>
		        </div>
		    [% END %]
		  </div>
	
	    <div id="basic-modal-content"></div>
