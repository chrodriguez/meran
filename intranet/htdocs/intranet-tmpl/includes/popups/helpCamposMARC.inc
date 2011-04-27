

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
		<fieldset>
              <ul id="ayuda_marc">
              <li>
                  <label for="campoHelp">Ingrese el campo o palabra:</label><br>
                  <input type="text" id="campoHelp" class="campoHelp" onClick="clearInput();" name="campoHelp" style="width:90%; max-width:100%;">
                  <input type="hidden" id="campoHelpId" name="campoHelpId">
              </li>
              <li>
      <!-- 			<label for="subcampo"> -->
                  Sub Campo:
      <!-- 			</label> -->
              </li>
              <li>
                  <textarea id="subcampos" name="subcampos" rows="7" style="width:90%; max-width:100%;" readonly=readonly></textarea>
              </li>
              <li >
                  <a href="http://www.loc.gov/marc/classification/eccdspa.html" target="_blanc">
                  para mas informaci&oacute;n MARC</a>
              </li>
              </ul>
        </fieldset>
	</div> <!--end div contentWindow-->
</div> <!--end div windowHelp-->

<!-- *******************************Fin**Window Help********************************************* -->