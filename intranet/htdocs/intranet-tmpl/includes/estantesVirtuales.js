/*
 * LIBRERIA Estantes Virtuales v 1.0
 *
 */
function zebra(classObj){$("."+classObj+" tr:gt(0):odd").addClass("impar");$("."+classObj+" tr:gt(0):even").addClass("par");}

function changePage(ini){
        objAH.changePage(ini);
    }

function ordenar(orden){
            objAH.sort(orden);
        }

        function verEstantes(){
                objAH=new AjaxHelper(updateVerEstantes);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.tipo= 'VER_ESTANTES';
                objAH.sendToServer();
        }

        function updateVerEstantes(responseText){
                $('#estante').html(responseText);
		$('#subestante').html('');
                makeToggle('datos_tabla_div_estantes','trigger',null,false);
        }

	function agregarNuevoSubEstante(estante,padre){
		    $('#padre_nuevo_sub_estante').val(padre);
		    $('#estante_nuevo_sub_estante').val(estante);
		    objAH=new AjaxHelper();
		    objAH.showOverlay       = true;
		    $('#nuevo_sub_estante').modal({   containerCss:{
			    backgroundColor:"#fff",
			    height:100,
			    padding:0,
			    width:215
			},
		    });
	}
	
        function agregarSubEstante(){
	    
	    if ( objAH.valor= $("#input_nuevo_sub_estante").val() ) {
                objAH=new AjaxHelper(updateAgregarSubEstante);
                objAH.debug= true;
		objAH.padre= $("#padre_nuevo_sub_estante").val();
                objAH.estante= $("#estante_nuevo_sub_estante").val();
                objAH.valor= $("#input_nuevo_sub_estante").val();
                objAH.url= 'estanteDB.pl';
                objAH.tipo= 'AGREGAR_SUBESTANTE';
                objAH.sendToServer();
		$.modal.close();
	    }
        }

        function updateAgregarSubEstante(responseText){
                var Messages= JSONstring.toObject(responseText);
                setMessages(Messages);
                 verSubEstantes(objAH.estante,objAH.padre);
        }


        function verSubEstantes(estante,padre){
                objAH=new AjaxHelper(updateVerSubEstantes);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.estante= estante;
		objAH.padre= padre;
                objAH.tipo= 'VER_SUBESTANTE';
                objAH.sendToServer();
        }

        function updateVerSubEstantes(responseText){
            if(objAH.padre == 0){
                $('#subestante').html(responseText);
                $('.datos_tabla_div_estantes').hide();
            }
            else{
                $('#subestante-'+ objAH.padre).html(responseText);
                zebra('datos_tabla');
                $('.datos_tabla_div_subestante_'+objAH.padre).hide();
            }
        }

        function borrarEstantesSeleccionados(estante,padre) {
            var checks;
            if(estante == 0) { checks=$(".ul_tabla_div_estante_0 input[type='checkbox']:checked");}
                else { checks=$(".ul_tabla_div_subestante_"+estante+" input[type='checkbox']:checked");}
            var array=checks.get();
            var theStatus="";
            var estantes=new Array();
            var cant=checks.length;
            if (cant>0){
                theStatus= ELIMINAR_LOS_ESTANTES+":\n";

                for(i=0;i<checks.length;i++) {
                    theStatus=theStatus+array[i].name+"\n";
                    estantes[i]=array[i].value;
                }
                theStatus=theStatus + ESTA_SEGURO+"?";
                jConfirm(theStatus,ELIMINAR_ESTANTE_TITLE, function(confirmStatus){if (confirmStatus) borrarEstantes(estantes,estante,padre);});
            }
            else{ jAlert(NO_SE_SELECCIONO_NINGUN_ESTANTE,ELIMINAR_ESTANTE_TITLE);}
        }

        function borrarEstantes(estantes,estante,padre) {
                objAH=new AjaxHelper(updateBorrarEstantesSeleccionados);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.estante= estante;
                objAH.padre= padre;
                objAH.estantes= estantes;
                objAH.tipo= 'BORRAR_ESTANTES';
                objAH.sendToServer();
        }

        function updateBorrarEstantesSeleccionados(responseText){
         var Messages= JSONstring.toObject(responseText);
         setMessages(Messages);
         if (objAH.estante == 0) {verEstantes();} 
            else {verSubEstantes(objAH.estante,objAH.padre);}
        }

  function borrarContenidoSeleccionado (estante,padre) {
            var checks=$(".datos_tabla_div_contenido_"+estante+" input[type='checkbox']:checked");
            var array=checks.get();
            var theStatus="";
            var contenido=new Array();
            var cant=checks.length;
            if (cant>0){
                theStatus= ELIMINAR_EL_CONTENIDO+":\n";

                for(i=0;i<checks.length;i++) {
                    theStatus=theStatus+array[i].name+"\n";
                    contenido[i]=array[i].value;
                }
                theStatus=theStatus + ESTA_SEGURO+"?";
                jConfirm(theStatus,ELIMINAR_CONTENIDO_TITLE, function(confirmStatus){if (confirmStatus) borrarContenido(contenido,estante,padre);});
            }
            else{ jAlert(NO_SE_SELECCIONO_NINGUN_CONTENIDO ,ELIMINAR_CONTENIDO_TITLE);}
        }

        function borrarContenido(contenido,estante,padre) {
                objAH=new AjaxHelper(updateBorrarContenidoSeleccionado);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.estante= estante;
                objAH.padre= padre;
                objAH.contenido= contenido;
                objAH.tipo= 'BORRAR_CONTENIDO';
                objAH.sendToServer();
        }

        function updateBorrarContenidoSeleccionado(responseText){
         var Messages= JSONstring.toObject(responseText);
         setMessages(Messages);
         verSubEstantes(objAH.estante,objAH.padre);
        }

	function agregarNuevoEstante(){
	    objAH=new AjaxHelper();
	    objAH.showOverlay       = true;
	    $('#nuevo_estante').modal({   containerCss:{
		    backgroundColor:"#fff",
		    height:100,
		    padding:0,
		    width:215
		},
	    });
	}

        function agregarEstante(){
	    if($("#input_nuevo_estante").val()){
                objAH=new AjaxHelper(updateAgregarEstante);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
		objAH.padre=0;
                objAH.estante=$("#input_nuevo_estante").val();
                objAH.tipo= 'AGREGAR_ESTANTE';
                objAH.sendToServer();
		$.modal.close();
	    }
        }

        function updateAgregarEstante(responseText){
            var Messages= JSONstring.toObject(responseText);
            setMessages(Messages);
            if (!(hayError(Messages))){
                    verEstantes();
            }
        }


        function editarEstante(estante,id,padre,abuelo){

		    $('#input_id_estante').val(id);
		    $('#input_valor_estante').val(estante);
		    $('#input_padre_estante').val(padre);
		    $('#input_abuelo_estante').val(abuelo);
		    objAH=new AjaxHelper();
		    objAH.showOverlay       = true;
		    $('#editar_estante').modal({   containerCss:{
			    backgroundColor:"#fff",
			    height:100,
			    padding:0,
			    width:215
			},
		    });
        }

	function modificarEstante(){
	    if($('#input_valor_estante').val()){
                objAH=new AjaxHelper(updateModificarEstante);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.estante= $('#input_id_estante').val();
		objAH.abuelo= $('#input_abuelo_estante').val();
                objAH.padre= $('#input_padre_estante').val();
                objAH.valor=$('#input_valor_estante').val();
                objAH.tipo= 'MODIFICAR_ESTANTE';
                objAH.sendToServer();
		$.modal.close();
	    }
        }

        function updateModificarEstante(responseText){
            var Messages= JSONstring.toObject(responseText);
            setMessages(Messages);
            if (!(hayError(Messages))){
		$('#resultBusqueda').html(responseText);
                if (objAH.padre == 0){
                    verEstantes();
                    $('.datos_tabla_div_estantes').hide();
                }
                else {
                    verSubEstantes(objAH.padre,objAH.abuelo);
                }
            }
        }
        
        function agregarContenido(estante,padre){
		$('#input_contenido_id_estante').val(estante);
		$('#input_contenido_id_padre_estante').val(padre);
		objAH=new AjaxHelper();
		objAH.showOverlay       = true;
		$('#contenido_estante').modal({
			    containerCss:{
			    backgroundColor:"#fff",
			    height:500,
			    padding:0,
			    width:800
			},
		    });
	}
	
	function buscarContenido(){
                objAH=new AjaxHelper(updateBuscarContenido);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
		objAH.showStatusIn  = 'busqueda_contenido_estante';
		objAH.funcion = "changePage";
                objAH.valor=$('#input_busqueda_contenido').val();
                objAH.tipo= 'BUSCAR_CONTENIDO';
                objAH.sendToServer();
        }

        function updateBuscarContenido(responseText){
		$('#resultado_contenido_estante').html(responseText);
		zebra('datos_tabla');
        }

        function agregarContenidoAEstante(id2 ){
	        objAH=new AjaxHelper(updateAgregarContenidoAEstante);
                objAH.debug= true;
                objAH.url= 'estanteDB.pl';
                objAH.estante=$('#input_contenido_id_estante').val();
		objAH.padre=$('#input_contenido_id_padre_estante').val();
		objAH.id2=id2;
                objAH.tipo= 'AGREGAR_CONTENIDO';
                objAH.sendToServer();
		$.modal.close();
	}
	
	function updateAgregarContenidoAEstante(responseText){
            var Messages= JSONstring.toObject(responseText);
            setMessages(Messages);
            if (!(hayError(Messages))){
                    verSubEstantes(objAH.estante,objAH.padre);
                }
        }
	