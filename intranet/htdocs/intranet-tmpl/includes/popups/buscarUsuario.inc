
[% INCLUDE  'AutocompleteHelper.inc'  %]

<!-- *********************************Window Help********************************************* -->
<script>

function clearInput(){
	$('#campoUsuario').val("");
}

var objAH;//Objeto AjaxHelper.


function detalleDelUsuario(){
	var nro_socio= $('#nro_socio_hidden').val();
	USUARIO= new objeto_usuario();
	USUARIO.text= $('#campoUsuario').val();
	USUARIO.ID= nro_socio;
}

$(document).ready(function() {
	
	CrearAutocompleteUsuarios({	IdInput: 'campoUsuario', 
								IdInputHidden: 'nro_socio_hidden', 
								callBackFunction: detalleDelUsuario
						});
});


</script>

<div id="contentWindow" class="formElemets">
	<ul>
	<li>
<!-- 		<label for="campoUsuario"> -->
		<b>Ingrese Apellido y Nombres, DNI o Legajo del usuario</b>
<!-- 		</label><br> -->
		<input 	type="text" id="campoUsuario" onClick="clearInput();" 
				id="campoUsuario" name="campoUsuario" style="width:90%;" tabindex="1">
				<input id="nro_socio_hidden" type="hidden">
	</li>
	<li>
		<div id="detalleUsuario"></div>
	</li>
	<li>
<!--     <div class="botonCentrado"> -->
            [% PERL %]
                     print C4::AR::Filtros::to_Button(      text    => "[% 'Aceptar' | i18n %]",
                                                            boton   => "boton_buscar",
                                                            onClick => "confirmarPrestamo();",
                                                            title   => "[% 'Aceptar' | i18n %]",
                             ) ;
            [% END %]
<!--     </div> -->
	</li>
	</ul>
</div> <!--end div id="contentWindow"-->

<!-- *******************************Fin**Window Help********************************************* -->


