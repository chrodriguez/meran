[% INCLUDE  'AutocompleteHelper.inc'  %] 

<!-- *********************************Window Help********************************************* -->
<script>

function clearInput(){
	$('#campoHelp').val("");
	$('#subcampos').val("");
}

function obtenerSubCampos(){
	objAH=new AjaxHelper(updateObtenerSubCampos);
    objAH.debug= true;
    objAH.url="/cgi-bin/koha/catalogacion/estructura/estructuraCataloDB.pl";
    objAH.campo = $('#campoHelpId').val();
    objAH.tipoAccion= 'MOSTRAR_SUBCAMPOS_DE_CAMPO';
    objAH.sendToServer();
}

function updateObtenerSubCampos(responseText){
	var response = responseText || "no response text";	
	var arreglo=response.split("#");
	var datos;
	var textArea = $("#subcampos");	

	for(var i=0; i<arreglo.length - 1;i++){
		datos= arreglo[i].split("/");
		textArea.val(textArea.val() + $.trim(datos[1]) + "\n");
	}
}

$(document).ready(function() {
	
	CrearAutocompleteAyudaMARC({IdInput: 'campoHelp', IdInputHidden: 'campoHelpId', callBackFunction: obtenerSubCampos})
});

</script>

<div id=windowHelp>
	<div id="contentWindow" class="formElemets">
		<ul>
		<li>
			<label for="campoHelp">
			Ingrese el campo o palabra:
			</label>
			<input	type="text" id="campoHelp" class="campoHelp" onClick="clearInput();" name="campoHelp" style="width:70%;">
			<input type="hidden" id="campoHelpId" name="campoHelpId">
		</li>
		<li>
			<label for="subcampo">
			Sub Campo:
			</label>
			<textarea 	id="subcampos" name="subcampos" rows="7" style="width:70%;" readonly=readonly></textarea>
		</li>
		<li>
			<a href="http://www.loc.gov/marc/classification/eccdspa.html" target="_blanc">
			para mas informaci&oacute;n MARC</a>
		</li>
		</ul>
	</div> <!--end div contentWindow-->
</div> <!--end div windowHelp-->

<!-- *******************************Fin**Window Help********************************************* -->