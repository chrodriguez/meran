var objAH;CAMPOS_ARRAY=new Array();SUBCAMPOS_ARRAY=new Array();function eliminarVista(vista_id){objAH=new AjaxHelper(updateAgregarVisualizacion);objAH.showOverlay=true;objAH.debug=true;objAH.url=URL_PREFIX+"/catalogacion/visualizacionINTRA/visualizacionIntraDB.pl";objAH.tipoAccion='ELIMINAR_VISUALIZACION';objAH.showOverlay=true;if(vista_id){jConfirm(ESTA_SEGURO_QUE_DESEA_BORRARLO,CATALOGO_ALERT_TITLE,function(confirmStatus){if(confirmStatus){objAH.vista_id=vista_id;objAH.sendToServer();}});}}
function agregarVisualizacion(){objAH=new AjaxHelper(updateAgregarVisualizacion);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+"/catalogacion/visualizacionINTRA/visualizacionIntraDB.pl";objAH.tipoAccion='AGREGAR_VISUALIZACION';var ejemplar=$("#tipo_nivel3_id").val();var campo=$.trim($("#campo").val());var subcampo=$.trim($("#subcampo").val());var liblibrarian=$.trim($("#liblibrarian").val());var pre=$.trim($("#pre").val());var post=$.trim($("#post").val());if((ejemplar)&&(campo)&&(subcampo)&&(liblibrarian)){objAH.ejemplar=ejemplar;objAH.campo=campo;objAH.subcampo=subcampo;objAH.liblibrarian=liblibrarian;objAH.pre=pre;objAH.post=post;objAH.sendToServer();}else{jAlert(SELECCIONE_VISTA_INTRA,CATALOGO_ALERT_TITLE);}}
function updateAgregarVisualizacion(responseText){var Messages=JSONstring.toObject(responseText);setMessages(Messages);if(!(hayError(Messages))){mostrarTabla();}}
function eleccionDeEjemplar(){var ejemplar=$("#tipo_nivel3_id").val();var ObjDiv=$("#result");if(!isNaN(ejemplar)){ObjDiv.hide();}else{ObjDiv.show();objAH=new AjaxHelper(updateEleccionDeNivel);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+"/catalogacion/visualizacionINTRA/visualizacionIntraDB.pl";objAH.tipoAccion='MOSTRAR_VISUALIZACION';objAH.ejemplar=ejemplar;objAH.sendToServer();}}
function updateEleccionDeNivel(responseText){$("#result").html(responseText);zebra("tabla_datos");}
function eleccionCampoX(){if($("#campoX").val()!=-1){objAH=new AjaxHelper(updateEleccionCampoX);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+"/catalogacion/visualizacionINTRA/visualizacionIntraDB.pl";objAH.campoX=$('#campoX').val();objAH.tipoAccion="GENERAR_ARREGLO_CAMPOS";objAH.sendToServer();}
else
enable_disableSelects();}
function updateEleccionCampoX(responseText){var campos_array=JSONstring.toObject(responseText);$("#campo").html('')
var options="<option value='-1'>Seleccionar CampoX</option>";for(x=0;x<campos_array.length;x++){CAMPOS_ARRAY[campos_array[x].campo]=$.trim(campos_array[x].liblibrarian);options+="<option value="+campos_array[x].campo+" >"+campos_array[x].campo+"</option>";}
$("#campo").append(options);enable_disableSelects();}
function eleccionCampo(){if($("#campo").val()!=-1){objAH=new AjaxHelper(updateEleccionCampo);objAH.debug=true;objAH.showOverlay=true;objAH.url=URL_PREFIX+"/catalogacion/visualizacionINTRA/visualizacionIntraDB.pl";objAH.campo=$('#campo').val();objAH.tipoAccion="GENERAR_ARREGLO_SUBCAMPOS";objAH.sendToServer();}
else
enable_disableSelects();}
function updateEleccionCampo(responseText){$('#nombre_campo').html(CAMPOS_ARRAY[$("#campo").val()]);var subcampos_array=JSONstring.toObject(responseText);$("#subcampo").html('');var options="<option value='-1'>Seleccionar SubCampo</option>";for(x=0;x<subcampos_array.length;x++){var subcampo=new Object;subcampo.liblibrarian='';subcampo.obligatorio='';subcampo.liblibrarian=$.trim(subcampos_array[x].liblibrarian);subcampo.obligatorio=$.trim(subcampos_array[x].obligatorio);SUBCAMPOS_ARRAY[subcampos_array[x].subcampo]=subcampo;options+="<option value="+subcampos_array[x].subcampo+" >"+subcampos_array[x].subcampo+"</option>";}
$("#subcampo").append(options);enable_disableSelects();}
function enable_disableSelects(){$("#campo").removeAttr('disabled');$("#subcampo").removeAttr('disabled');$("#tablaRef").removeAttr('disabled');$("#tipoInput").removeAttr('disabled');$("#divCamposRef").show();if($('#campoX').val()==-1){$("#campo").attr('disabled',true);$("#subcampo").attr('disabled',true);$("#tablaRef").attr('disabled',true);$("#tipoInput").attr('disabled',true);$("#divCamposRef").hide();}
else
if($('#campo').val()==-1){$("#subcampo").attr('disabled',true);$("#tablaRef").attr('disabled',true);$("#tipoInput").attr('disabled',true);$("#divCamposRef").hide();}
else
if($('#subcampo').val()==-1){$("#tablaRef").attr('disabled',true);$("#tipoInput").attr('disabled',true);$("#divCamposRef").hide();}
else
if($('#tablaRef').val()==-1){$("#divCamposRef").hide();}}
function eleccionSubCampo(){if($('#subcampo').val()!=-1){$('#liblibrarian').val(SUBCAMPOS_ARRAY[$('#subcampo').val()].liblibrarian);}
else
enable_disableSelects();}
function mostrarTablaRef(){objAH=new AjaxHelper(updateMostrarTablaRef);objAH.showOverlay=true;objAH.debug=true;objAH.url=URL_PREFIX+"/utils/utilsDB.pl";objAH.tipoAccion="GENERAR_ARREGLO_TABLA_REF";objAH.sendToServer();}