var report_obj;
var result_div_id;

function generarEtiquetas(id){
	report_obj                   	= new AjaxHelper(mostrarResultados);
	result_div_id					= id;
	report_obj.showOverlay       	= true;
	report_obj.debug             	= true;
	report_obj.url               	= URL_PREFIX+'/reports/usuariosDB.pl';
	report_obj.debug             	= true; 
	report_obj.action         	 	= "GENERAR_ETIQUETAS"
	report_obj.user_category		= $("#user_category").val();
	report_obj.name					= $("#name").val();
	report_obj.base_age				= $("#base_age").val();
	report_obj.base_age_check		= ( $('#base_age_check').attr('checked') )?1:0;
	report_obj.statistics_check		= ( $('#statistics_check').attr('checked') )?1:0;	
	report_obj.sort_by				= $("#sort_by").val();
    report_obj.sendToServer();
}





function mostrarResultados(responseText){
	$('#'+result_div_id).html(responseText);
	$('#'+result_div_id).show();
	scrollTo(result_div_id);
}