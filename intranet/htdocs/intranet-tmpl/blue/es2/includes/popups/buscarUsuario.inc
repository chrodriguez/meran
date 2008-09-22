<!-- *********************************Window Help********************************************* -->

<link href="/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.css" type="text/css" rel="stylesheet">
<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.js"></script>


<script>

// ## FIXME NO FUNCIONA, DEBERIA CARGAR DE MANERA CONDICIONAL
// if (typeof($.Autocompleter) != "function"){
		
	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/jquery.bgiframe.min.js");
	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/jquery.dimensions.js");
	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.mouse.js");
	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.js");
	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.ext.js");
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/jquery.autocomplete.js");
// }

function closeWindow(){
	$('.windowBlur').hide();
	$('.ac_results').hide();
	$('#windowUser').hide();
}

function openWindow(){
	$('.windowBlur').show();
	$('#windowUser').draggable({opacity: 0.7777});
	$('#windowUser').show();
	$('#windowUser').centerObject();	
	$('#campoUsuario').focus();
}

function clearInput(){
	$('#campoUsuario').val("");
}


var infoPrestamos_array= new Array();//Arreglo que contendra los objetos, con info que pertenece a los prestamos.
var objAH;//Objeto AjaxHelper.

/*
 * infoPrestamo
 * Representa al objeto que contendra la informacion para poder prestar el item. 
 * Que se pasara con json al servidor, en un arreglo (infoPrestamos_array).
 * prestamos.tmpl
 */
function infoPrestamo(){
	this.id3= '';
	this.id3Old= '';
	this.tipoPrestamo; //este es el tipo de prestamo para el id3
}

/*
 * object_usuario
 * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
 */
function object_usuario(){
	this.text;
	this.ID;
}


/*
 * AutocompleteUsuario
 * Funcion que asigna al input que busca el usuario la funcion de autocomplete.
 */
// function AutocompleteUsuario(idInput,funcionDetalle,funcionUpdateInfo){
function AutocompleteUsuario(idInput){
	// q= valor de campo de usuario
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
	
		//se crea el objeto para guardar la informacion del usuario al que se le va a 
		//realizar el prestamo	
 		usuario= new object_usuario();
		usuario.text= data[0];
		usuario.ID= data[1];
	
	});
}


$(document).ready(function() {
	
	AutocompleteUsuario('campoUsuario');
});

</script>

<div id=windowUser class="window" style="display:none; height:200px; width:500px;">
	<div class="windowBlur" style="display:none; height:204px; width:500px;"></div> <!-- end div blur -->
		<div id="headerWindow" class="headerWindow">
			<span class="click" onClick="closeWindow();">Cerrar</span>
		</div>

		<div id="title" class="title">Buscar Usuario</div>
		<div id="contentWindow" class="formElemets">
			<ul>
			<li>
				<label for="campoUsuario" style="float: left;" >
				<b>Ingrese Apellido y Nombres, DNI o Legajo del usuario</b>
				</label><br>
				<input 	type="text" id="campoUsuario" onClick="clearInput();" 
					name="campoUsuario" style="width:90%;">
			</li>
			<li>
				<div id="detalleUsuario"></div>
			</li>
			<li>
				<input type="button" value="Aceptar" onClick="confirmarPrestamo()">
			</li>
			</ul>
		</div> <!--end div id="contentWindow"-->
</div> <!-- end div window -->

<!-- *******************************Fin**Window Help********************************************* -->


