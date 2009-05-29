<!-- *********************************Window Agregar Encabezado********************************************* -->

<script>

// ## FIXME NO FUNCIONA, DEBERIA CARGAR DE MANERA CONDICIONAL
// if (!$.ui.draggable){

//  	$.getScript("/intranet-tmpl/blue/includes/jquery/jquery.bgiframe.js");
// 	$.getScript("/intranet-tmpl/blue/includes/jquery/jquery.dimensions.js");
// 	$.getScript("/intranet-tmpl/blue/includes/jquery/ui.mouse.js");
// 	$.getScript("/intranet-tmpl/blue/includes/jquery/ui.draggable.js");
// 	$.getScript("/intranet-tmpl/blue/includes/jquery/ui.draggable.ext.js");
// 	alert("se cargo desde agregar encabezado");
// }

function openWindow(){
	$('.windowBlur').show();
	$('#window').draggable({opacity: 0.7777});
 	$('#window').show();
	
}

function closeWindow(){
	$('.windowBlur').hide();
	$('#window').hide();
	clearDataTextArea();
}

/******************************************Manejador para TextArea*********************************************/

function dataO(ID, text){
	this.ID= ID;
	this.text= text;
	return this;
}

var itemtypes_array= new Array();

function pushEncabezadoTipoItem(){
	
	var id= $('#comboTiposItemsAltaEncabezado').val();	

	if (!exist(id, itemtypes_array)){
		var itemtype= $('#comboTiposItemsAltaEncabezado')[0].options[$('#comboTiposItemsAltaEncabezado')[0].selectedIndex].text;

		$('#textArearTiposItems').val(itemtype + '\n' + $('#textArearTiposItems').val() );
	
		d= new dataO(id, itemtype);
		itemtypes_array.push(d);
	}else{
		alert("Ya existe el elmento");
	}

	//si hay elementos habilito el boton pop
	if(itemtypes_array.length > 0){
		$('#pop').attr('disabled', false);
	}
}

function exist(ID, vector){
	var found= false;
	var long= vector.length;
	var i= 0;
	while (!(found) && (i<long)){
		if(vector[i].ID == ID){
			found= true;
		}else{
			i++;
		}
	}
	return found;
}

function mapToTextArea(idTextArea, vector){
	var itemtype;

	$('#'+idTextArea).val('');
	for (var i=0;i<vector.length;i++){
		itemtype= vector[i].text;
		$('#'+idTextArea).val(itemtype + '\n' + $('#'+idTextArea).val() );
	}
}

function popEncabezadoTipoItem(){
	var obj= itemtypes_array.pop();
// 	alert('tipoItem: ' + obj.text + ' ID: ' + obj.ID);
	mapToTextArea('textArearTiposItems', itemtypes_array);
	//si se vacia, deshabilito el boton pop
	if(itemtypes_array.length == 0){
		$('#pop').attr('disabled', true);
	}
}

function clearDataTextArea(){
	//clear inputs
	$('#textArearTiposItems').val('');
	$('#nomEncabezadoAlta').val('');
	//clear data
	itemtypes_array= new Array();
}

/*****************************************Fin**Manejador para TextArea*****************************************/

function saveEncabezado(){
	
	var itemtypesJSON;
	itemtypesJSON=JSONstring.make(itemtypes_array);

	objAH=new AjaxHelper(updateSaveEncabezado);
	objAH.url= '/cgi-bin/koha/catalogacion/visualizacionOPAC/visualizacionOpacDB.pl';
	objAH.encabezado= $('#nomEncabezadoAlta').val();
	objAH.tabla= 'ENCABEZADO';
	objAH.tipoAccion= 'INSERT';
	objAH.nivel= $('#nivel').val();
	objAH.itemtypes= itemtypesJSON;
	//se envia la consulta
	objAH.sendToServer();
}

function updateSaveEncabezado(responseText){
 	$('#mensajes').html(responseText);
	clearDataTextArea();
	cargarTablaEncabezados();
}

</script>

<div id=window class=window style="display:none; height:270px; width:350px;">
  <div class="windowBlur" style="display:none; height:270px; width:350px;"></div>
	<div id="headerWindow" class="headerWindow">
		<span class="click" onClick="closeWindow();">Cerrar</span>
	</div>
	<div id="title" class="title">Titulo</div>	
	<div id="contentWindow" class="contentWindow">
	  <ul>
	  	<li>
			<label for="textoMod" style="float: left; width:25%" >
			Encabezado:
			</label>
			<input type="text" id="nomEncabezadoAlta">
		</li>
		<li>
			Tipo de item: <!-- TMPL_VAR NAME="selectItemTypeAltaEncabezado" -->
		</li>
		<li>
			<input 	id="push" type="button" onClick="pushEncabezadoTipoItem();" value=">>" 
				title="Agregar Tipo de Item" > 
			<input 	id="pop" type="button" onClick="popEncabezadoTipoItem();" value="<<" 
				title="Sacar Tipo de Item" disabled=true>
		</li>
		<li>
			<textarea id="textArearTiposItems" style="height:60px; width:230px;" readonly></textarea>
		</li>
	</div> <!--end div contentWindow-->

	<div class="controls" id="controls">
		<p>
		   <a onClick="validarDatosEncabezado();">
			<img 	id="save" border="0" src="/intranet-tmpl/blue/images/guardar.png" 
				alt="Guardar" name="save" title="Guardar Encabezado"/>
		   </a>
		</p>
	</div>
</div> <!--end div window-->


<!-- *******************************Fin**Window Agregar Encabezado**************************************** -->


