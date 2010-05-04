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