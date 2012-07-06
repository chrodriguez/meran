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



function cambiarSentidoOrd(){
      if (ASC){
        $('#icon_'+ ORDEN).attr("class","icon-chevron-up click");
      } else {
        $('#icon_'+ ORDEN).attr("class","icon-chevron-down click");
      }
}


function mostrarResultados(responseText){
	$('#'+result_div_id).html(responseText);
	$('#'+result_div_id).show();
	scrollTo(result_div_id);
}


function agregarAlIndice(){
	var checks=$("#tablaResult_registros input[@type='checkbox']:checked");
	var array=checks.get();
	var theStatus="";
	var id1s=new Array();
	var cant=checks.length;
	var accion=$("#accion").val();
	if (cant>0){
		theStatus= HABILITAR_POTENCIALES_CONFIRM; 
	
		for(i=0;i<checks.length;i++){
			id1s[i]=array[i].value;
		}

		addRegistrosAlindice(cant,id1s);
	}
	else{ 
		jAlert (NO_SE_SELECCIONO_NINGUN_USUARIO);
	}
}	


function addRegistrosAlindice(cant,array_id1){
	objAH=new AjaxHelper(updateInfoActualizar);
    objAH.url           = URL_PREFIX+'/reports/catalogoDB.pl';
    objAH.tipoAccion    =  "ADD_REGISTRO_AL_INDICE";
	objAH.debug= true;
	objAH.showOverlay = true;
	objAH.cantidad= cant;
	objAH.array_id1= array_id1;
	objAH.funcion= "changePage";
	objAH.sendToServer();
}

function updateInfoActualizar(responseText){

 	var Messages=JSONstring.toObject(responseText);
 	setMessages(Messages);
 	generarReporteRegistrosNoIndexados();
	
}












