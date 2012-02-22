
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
	$('#campoUsuario').focus();
});


</script>



<div id="contentWindow" class="form-horizontal">
	<div class="modal-header">
		<a class="close" data-dismiss="modal">×</a>
		<h3>[% 'Buscar usuario para circular ejemplar' | i18n %]</h3>
	</div>
	
	<div class="modal-body">
	
		<input 	type="text" onClick="clearInput();" 
				id="campoUsuario" name="campoUsuario" autofocus="autofocus">
		<input id="nro_socio_hidden" type="hidden">

		<div id="detalleUsuario"></div>

	</div>
	
    <div class="modal-footer">
            [% PERL %]
                     print C4::AR::Filtros::to_Button(      text    => "[% 'Aceptar' | i18n %]",
                                                            boton   => "boton_buscar",
                                                            onClick => "confirmarPrestamo();",
                                                            title   => "[% 'Aceptar' | i18n %]",
                             ) ;
            [% END %]
    </div>   
</div>


