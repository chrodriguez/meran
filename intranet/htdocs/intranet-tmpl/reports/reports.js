function openLink(url) {

	window.location.href = url;

}

function hideTableColumn(column_number, hide_param) {
	// FUNCIONA SOLAMENTE SI HAY UNA SOLA TABLA EN EL DOCUMENTO
	// $('td:nth-child(2)').hide();
	// if your table has header(th), use this
	$('td:nth-child(' + column_number + '),th:nth-child(' + column_number + ')')
			.hide();
	$('#' + hide_param).val(1);

}

function submitForm(form_id) {

	$('#' + form_id).submit();
}

function consultarAltas() {
	var ui = $("#id_ui").val();
	var item_type 		= $("#tipo_nivel3_id").val();
	var date_begin 		= $("#dateselected").val();
	var date_end 		= $("#dateselectedEnd").val();
	objAH 				= new AjaxHelper(updateInfo);
	objAH.debug 		= true;
    objAH.showOverlay       = true;
	objAH.url 			= URL_PREFIX+"/reports/altas_registro_result.pl";
	objAH.item_type 	= item_type;
	objAH.date_begin 	= date_begin;
	objAH.date_end 		= date_end;
	objAH.funcion		= 'changePage';
	// se envia la consulta
	objAH.sendToServer();
}


function consultarEstantes() {
	var ui = $("#id_ui").val();
	var estante 		= $("#estante_id").val();
	objAH 				= new AjaxHelper(updateInfo);
	objAH.debug 		= true;
    objAH.showOverlay       = true;
	objAH.url 			= URL_PREFIX+"/reports/estantes_virtuales_result.pl";
	objAH.estante 	= estante;
	objAH.funcion		= 'changePage';
	// se envia la consulta
	objAH.sendToServer();
}

function updateInfo(responseText) {
	$("#result").html(responseText);
	zebra('datos_tabla');
}