<!-- *********************************Window Help********************************************* -->
<script>

function clearInput(){
	$('#campoUsuario').val("");
}

var objAH;//Objeto AjaxHelper.

$(document).ready(function() {
	
	CrearAutocompleteUsuarios({	IdInput: 'campoUsuario', 
								IdInputHidden: 'nro_socio_hidden', 
								callBackFunction: detalleDelUsuario
						});
});

function detalleDelUsuario(){
	var nro_socio= $('#nro_socio_hidden').val();
	USUARIO= new objeto_usuario();
	USUARIO.text= $('#campoUsuario').val();
	USUARIO.ID= nro_socio;
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


