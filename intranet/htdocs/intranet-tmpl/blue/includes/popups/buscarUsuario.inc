<!-- *********************************Window Help********************************************* -->
<script>

function clearInput(){
	$('#campoUsuario').val("");
}

var objAH;//Objeto AjaxHelper.

/*
 * object_usuario
 * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
 */
// function object_usuario(){
// 	this.text;
// 	this.ID;
// }


/*
 * AutocompleteUsuario
 * Funcion que asigna al input que busca el usuario la funcion de autocomplete.
 */
// function AutocompleteUsuario(idInput,funcionDetalle,funcionUpdateInfo){
// function AutocompleteUsuario(idInput){
// 	// q= valor de campo de usuario
// 	$("#"+idInput).search();
// 	$("#"+idInput).autocomplete('/cgi-bin/koha/autocompletables/usuarioAutocomplete.pl',{
//  		formatItem: function(row){
// 			return row[0];
// 		},
// 		minChars:1,
//         	matchSubset:1,
//         	matchContains:1,
// 		maxItemsToShow:10,
//         	cacheLength:10,
//         	selectOnly:1,
// 	});//end autocomplete
// 	$("#"+idInput).result(function(event, data, formatted) {
// 		//muestro en el input el usuario seleccioinado
// 		$("#"+idInput).val(data[0]);
// 	
// 		//se crea el objeto para guardar la informacion del usuario al que se le va a 
// 		//realizar el prestamo	
//  		usuario= new object_usuario();
// 		usuario.text= data[0];
// 		usuario.ID= data[1];
// 	
// 	});
// }


$(document).ready(function() {
	
// 	AutocompleteUsuario('campoUsuario');
	CrearAutocompleteUsuarios({	IdInput: 'campoUsuario', 
								IdInputHidden: 'nro_socio_hidden', 
								callBackFunction: detalleDelUsuario
						});
});

function detalleDelUsuario(){
	var nro_socio= $('#nro_socio_hidden').val();
	usuario= new objeto_usuario();
	usuario.text= $('#campoUsuario').val();
	usuario.ID= nro_socio;
}

</script>

<div id="contentWindow" class="formElemets">
	<ul>
	<li>
		<label for="campoUsuario" style="float: left;" >
		<b>Ingrese Apellido y Nombres, DNI o Legajo del usuario</b>
		</label><br>
		<input 	type="text" id="campoUsuario" onClick="clearInput();" 
				id="campoUsuario" name="campoUsuario" style="width:90%;" tabindex="1">
				<input id="nro_socio_hidden" type="hidden">
	</li>
	<li>
		<div id="detalleUsuario"></div>
	</li>
	<li>
		<input type="button" value="Aceptar" onClick="confirmarPrestamo()">
	</li>
	</ul>
</div> <!--end div id="contentWindow"-->

<!-- *******************************Fin**Window Help********************************************* -->


