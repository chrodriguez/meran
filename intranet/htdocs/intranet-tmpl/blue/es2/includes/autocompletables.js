/*
 * En este archivo se inserta la funcion de autocomplete a los input correspondientes.
 */

function crearAuto(id,tabla,accion,otroId,campos,orden,separador){
	var url;
	var params="?campos="+campos+"&orden="+orden+"&separador="+separador;
	switch (tabla) {
		case "temas":
			url="/cgi-bin/koha/temasAutocomplete.pl"+params;
			break;
		case "autores":
			url="/cgi-bin/koha/autorAutocomplete.pl"+params;
			break;
		case "countries":
			url="/cgi-bin/koha/paisesAutocomplete.pl"+params;
			break;
		case "branches":
			url="/cgi-bin/koha/bibliosAutocomplete.pl"+params;//CAMBIAR POR EL DE BRANCH
			break;
	}
	crearAutocomplete(id,url,accion,otroId);
}

/*
 * crearAutocomplete
 * Se le asigna al componente con id = id la funcion de ser autocompletable
 * params: id, identificador del input text que va a tener la funcion.
 *	   url, direccion donde tiene que buscar los datos.
 *	   accion, indica si se tiene que reemplazar o concantenar el valor anterior con el nuevo valor.
 *	   otroId, identificador donde se guardan los ids de los valores ingresados.
 */
function crearAutocomplete(id,url,accion,otroId){
	var comp=$('#'+id);//componente autocompletable.
	comp.search();
	// q= valor que va al pl
	comp.autocomplete(url,
        		{
			minChars:1,
                       	matchSubset:1,
                       	matchContains:1,
			maxItemsToShow:10,
                       	cacheLength:10,
                       	selectOnly:1,
			highlight:0,
       			});//end autocomplete
	// funcion que se ejecuta cuando se selecciona un elemento de la lista.
	comp.result(function(event, data, formatted) {
		if(accion=="reemplazar"){
			$("#"+otroId).val(data[1]);
		}
		else{//concatena el resultado
			var valor=$("#"+otroId).val();
			var textA=$("#texta"+otroId).val();
			if(valor == ""){
				valor=data[1];
				textA=data[0];
			}
			else{
				valor=valor+"#"+data[1];
				textA=textA+"\n"+data[0];
			}
			$("#"+otroId).val(valor);//se guardan (concatenan) los id en un hidden de lo seleccionado
			$("#texta"+otroId).val(textA);//se escribe en el textarea el texto seleccionado.
			comp.focus();
		}
	});
}