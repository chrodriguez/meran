
function toggleChecks(){

    var total_checked=($("#total").attr("checked"))?1:0;
    var registrados_checked=($("#registrados:checked").attr("checked"))?1:0;
    var categorias=$("#categoria_socio_id");
    var f_inicio=$("#f_inicio");
    var f_fin=$("#f_fin");

    $("#registrados:checked").removeAttr("disabled");
    categorias.removeAttr("disabled");
    f_inicio.removeAttr("disabled");
    f_fin.removeAttr("disabled");

    if (total_checked){
        $("#registrados:checked").attr("disabled","disabled");
        categorias.attr("disabled","disabled");
        f_inicio.attr("disabled","disabled");
        f_fin.attr("disabled","disabled");
    }
    else{
        if (!registrados_checked){
            categorias.attr("disabled","disabled");
        }
    }
}

function consultarColecciones(){
    var ui=$("#id_ui").val();
    var item_type=$("#tipo_nivel3_id").val();

    objAH=new AjaxHelper(updateInfo);
    objAH.debug= true;
    objAH.url= "/cgi-bin/koha/estadisticas/colecciones.pl";
    objAH.ui= ui;
    objAH.item_type= item_type;
    //se envia la consulta
    objAH.sendToServer();
}

function updateInfo(responseText){
    $("#result_chart").html(responseText);
}

function consultarAccesosOPAC(){
    var total=($("#total").attr("checked"))?1:0;
    var registrados=($("#registrados:checked").attr("checked"))?1:0;
    var tipo_socio=$("#categoria_socio_id").val();
    var f_inicio=$("#f_inicio").val();
    var f_fin=$("#f_fin").val();
    
    objAH=new AjaxHelper(updateInfo);
    objAH.debug= true;
    objAH.url= "/cgi-bin/koha/estadisticas/consultas_opac.pl";
    objAH.total= total;
    objAH.registrados= registrados;
    objAH.tipo_socio= tipo_socio;
    objAH.f_inicio= f_inicio;
    objAH.f_fin= f_fin;
    //se envia la consulta
    objAH.sendToServer();
}
