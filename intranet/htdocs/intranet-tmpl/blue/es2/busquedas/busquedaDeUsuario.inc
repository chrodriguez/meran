<!-- *********************************Window Usuario********************************************* -->


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

function AutocompleteUsuario(idInput){
	$("#"+idInput).search();
	$("#"+idInput).autocomplete('/cgi-bin/koha/autocompletables/usuarioAutocomplete.pl',{
 		formatItem: function(row){
			return row[0];
		},
		minChars:1,
        	matchSubset:1,
        	matchContains:1,
		maxItemsToShow:10,
        	cacheLength:10,
        	selectOnly:1,
	});//end autocomplete
	$("#"+idInput).result(function(event, data, formatted) {
		//muestro en el input el usuario seleccioinado
		$("#"+idInput).val(data[0]);
//  		usuario= new object_usuario();
// 		usuario.text= data[0];
// 		usuario.ID= data[1];
		$("#nombre").val(data[0]);
	});
}

$(document).ready(function() {
	AutocompleteUsuario("usuario");
});

</script>

<div id=windowHelp class="window" style="display:none; height:300px; width:400px;">
<div class="windowBlur" style="display:none; height:304px; width:400px;">
</div> <!-- end div blur -->
	<div id="headerWindowHelp" class="headerWindowHelp">
		<span class="click" onClick="closeWindowHelp();">Cerrar</span>
	</div>
	<div id="title" class="title">Busqueda de usuario</div>
	<div id="contentWindow" class="formElemets">
	<ul>
	<li>
		<label for="usuario" style="float: left; width:15%" >
		Usuario:
		</label><br>
		<input type="text" id="usuario" class="campoHelp" onClick="clearInput();" name="campoHelp" style="width:90%;">
<!-- 		<input type="hidden" id="campoHelpId" name="campoHelpId"> -->
	</li>
	<li>
		<label for="nombre" style="float: left; width:25%" >
		Nombre del usuario:
		</label>
		<br>
		<textarea id="nombre" rows="2" style="width:90%;" readonly=readonly></textarea>
	</li>
	</ul>
	</div>
</div> <!-- end div windowBlur -->
</div>



<!-- *******************************Fin**Window Usuario********************************************* -->


