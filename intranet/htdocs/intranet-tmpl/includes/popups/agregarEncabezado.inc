<!-- *********************************Window Agregar Encabezado********************************************* -->

<script>

/******************************************Manejador para TextArea*********************************************/

function dataO(ID, text){
	this.ID= ID;
	this.text= text;
	return this;
}

var itemtypes_array= new Array();

function pushEncabezadoTipoItem(){
	
	var id= $('#tipo_documento').val();	

	if (!exist(id, itemtypes_array)){
		var itemtype= $('#tipo_documento')[0].options[$('#tipo_documento')[0].selectedIndex].text;

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
    objAH.debug= true;
	objAH.url= '/cgi-bin/koha/catalogacion/visualizacionOPAC/visualizacionOpacDB.pl';
	objAH.encabezado= $('#nomEncabezadoAlta').val();
	objAH.tabla= 'ENCABEZADO';
	objAH.tipoAccion= 'INSERT';
	objAH.nivel= $('#nivel').val();
// 	objAH.itemtypes= itemtypesJSON;
    objAH.itemtypes= itemtypes_array;
	//se envia la consulta
	objAH.sendToServer();
}

function updateSaveEncabezado(responseText){
 	$('#mensajes').html(responseText);
	clearDataTextArea();
	cargarTablaEncabezados();
}

</script>

<ul>
	<li class="sub_item">
		<label for="nomEncabezadoAlta">
		[% 'Encabezado' | i18n %]:
		</label>
		<input type="text" id="nomEncabezadoAlta">
	</li>
	<li class="sub_item">
    
        <label for="tipo_documento">
		[% 'Tipo de item' | i18n %]: 
        </label>
        [% combo_tipos_documento %]

        [% PERL %]
            print C4::AR::Filtros::to_Icon(  
                                                boton   => "icon_agregar",
                                                onClick => "pushEncabezadoTipoItem();",
                                                title   => "[% 'Agregar Tipo de Item' | i18n %]",
                    ) ;
        [% END %]

        [% PERL %]
            print C4::AR::Filtros::to_Icon(  
                                                boton   => "icon_borrar",
                                                onClick => "popEncabezadoTipoItem();",
                                                title   => "[% 'Sacar Tipo de Item' | i18n %]",
                    ) ;
        [% END %]

	</li>
	<li class="sub_item">
        <label for="textArearTiposItems">[% 'Tipo de Documento' | i18n %]</label>
		<textarea id="textArearTiposItems" style="height:60px; width:230px;" readonly></textarea>
	</li>

	<li>

         [% PERL %]
                     print C4::AR::Filtros::to_Button(      text    => "[% 'Agregar un Encabezado' | i18n %]",
                                                            boton   => "boton_agregar",
                                                            onClick => "validarDatosEncabezado();",
                                                            title   => "[% 'Agregar un Encabezado' | i18n %]",
                                                            width   => "180",
                                                            alternClass => "botonCentrado"
                             ) ;
        [% END %]

	</li>
</ul>
<!-- *******************************Fin**Window Agregar Encabezado**************************************** -->


