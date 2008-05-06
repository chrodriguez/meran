<!-- *********************************Window Help********************************************* -->

<!-- <script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.js"></script> -->
<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.bgiframe.min.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.dimensions.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.mouse.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.ext.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.js"></script>
<link href="/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.css" type="text/css" rel="stylesheet">


<script>

function closeWindowHelp(){
	$('.windowBlur').hide();
	$('.ac_results').hide();
	$('#windowHelp').hide();
}

function openWindowHelp(){
	$('.windowBlur').show();
	$('#windowHelp').draggable({opacity: 0.7777});
	$('#windowHelp').show();
}

function clearInput(){
	$('#campoHelp').val("");
	$('#subcampos').val("");
}

function getTagId(id){
//muestra los subcampos del campo seleccionado
$('#campoHelpId').val(id);
$('#subcampos').val("");

var campo= $('#campoHelpId').val();
var params= 'tipoAccion=Select&componente=ayudaCampoMARKsubcampo&campo=' + campo;

$.ajax({	type: "POST", 
		url: "/cgi-bin/koha/acqui.simple/estructuraCataloOpacDB.pl",
		data: params,
		beforeSend: Init,
		complete: function parsearSubCampos(ajax){
 			var response = ajax.responseText || "no response text";	
 			var arreglo=response.split("#");
 			var datos;
     			var textArea = $("#subcampos");	
 	
  				for(var i=0; i<arreglo.length - 1;i++){
 				  datos= arreglo[i].split("/");
				  textArea.val(textArea.val() + datos[1] + "\n");
  				}
			HiddeState();
 			}
	});

}



function CrearAutocompleteHelp(){
	// q= valor de campoHelp
	$("#campoHelp").search();
	$("#campoHelp").autocomplete(	'/cgi-bin/koha/acqui.simple/estructuraCataloOpacDB.pl',{
 		formatItem: function(row){
			return row[0]+" - "+row[1];
		},
		minChars:1,
        	matchSubset:1,
        	matchContains:1,
		maxItemsToShow:10,
        	cacheLength:10,
        	selectOnly:1,
		extraParams:{	tipoAccion:"Select", 
				componente:"ayudaCampoMARK"
			}	
	});//end autocomplete
	$("#campoHelp").result(function(event, data, formatted) {
		getTagId(data[0]);
		$("#campoHelp").val(data[0] + " - " + data[1]);
	});
}

$(document).ready(function() {
	
	CrearAutocompleteHelp();
});

</script>

<div style="text-align: right;"><span class="click" onClick="openWindowHelp();">Ayuda MARC</span>
</div>

<div id=windowHelp class="window" style="display:none; height:300px; width:400px;">
<div class="windowBlur" style="display:none; height:304px; width:400px;">
</div> <!-- end div blur -->
	<div id="headerWindowHelp" class="headerWindowHelp">
		<span class="click" onClick="closeWindowHelp();">Cerrar</span>
	</div>
	<div id="title" class="title">Ayuda campos MARC</div>
	<div id="contentWindow" class="formElemets">
	<ul>
	<li>
		<label for="campoHelp" style="float: left; width:15%" >
		Campo:
		</label><br>
		<input type="text" id="campoHelp" class="campoHelp" onClick="clearInput();" name="campoHelp" style="width:90%;">
		<input type="hidden" id="campoHelpId" name="campoHelpId">
	</li>
	<li>
		<label for="subcampo" style="float: left; width:25%" >
		Sub Campo:
		</label>
		<br>
		<textarea id="subcampos" name="subcampos" rows="7" style="width:90%;" readonly=readonly></textarea>
	</li>
	<li>
		<a href="http://www.loc.gov/marc/classification/eccdspa.html" target="_blanc">
		para mas informaci&oacute;n MARC</a>
	</li>
	<ul>
	</div>
</div> <!-- end div windowBlur -->
</div>



<!-- *******************************Fin**Window Help********************************************* -->


