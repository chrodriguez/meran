/*
 * LIBRERIA AutocompleteHelper v 1.0.1
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 *
 */



function _getId(IdObj, id){
    //guardo en hidden el id
    $('#'+IdObj).val(id);
}
    
/*
Esta funcion necesita:
Id = es el id del input sombre el que se va hacer ingreso de datos
IdHidden= id del input hidden donde se guarda el id del resultado seleccionado
url= url donde se realiza la consulta
*/


function _CrearAutocomplete(options){
/*
@params
IdInput= parametro para la busqueda
IdInputHidden= donde se guarda el ID de la busqueda
accion= filtro para autocompletablesDB.pl
function= funcion a ejecutar luego de traer la respuesta del servidor
*/
	if(!(options.IdInput)||!(options.IdInputHidden)){ 
		alert("AutocompleteHelper=> _CrearAutocomplete=> Error en parametros");
		return 0;
	}

    url = "/cgi-bin/koha/autocompletablesDB.pl?accion="+options.accion+"&token="+token;

    $("#"+options.IdInput).search();
    // q= valor de campoHelp
    $("#"+options.IdInput).autocomplete(url,{
        formatItem: function(row){
            return row[1];
        },
        minChars:3,
		matchSubset:1,
		matchContains:1,
        maxItemsToShow:10,
		cacheLength:10,
		selectOnly:1,
    });//end autocomplete
    $("#"+options.IdInput).result(function(event, data, formatted) {
        $("#"+options.IdInput).val(data[1]);
        _getId(options.IdInputHidden, data[0]);
		if(options.callBackFunction){
 			options.callBackFunction();
		}
    });
}

//Funciones publicas

function CrearAutocompleteCiudades(options){
    _CrearAutocomplete({	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_ciudades', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompletePaises(options){
    _CrearAutocomplete({	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_paises', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompleteLenguajes(options){
    _CrearAutocomplete({	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_lenguajes', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompleteAutores(options){
    _CrearAutocomplete({	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_autores', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompleteSoportes(options){
    _CrearAutocomplete({	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_soportes', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompleteUsuarios(options){
	_CrearAutocomplete(	{	IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_usuarios', 
							callBackFunction: options.callBackFunction,
					});
}

function CrearAutocompleteBarcodes(options){
    _CrearAutocomplete({
							IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_barcodes', 
							callBackFunction: options.callBackFunction,
					});	
}

function CrearAutocompleteBarcodesPrestados(options){
    _CrearAutocomplete({
							IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_barcodes_prestados', 
							callBackFunction: options.callBackFunction,
					});	
}

function CrearAutocompleteTemas(options){
    _CrearAutocomplete({
							IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_temas', 
							callBackFunction: options.callBackFunction,
					});	
}

function CrearAutocompleteEditoriales(options){
    _CrearAutocomplete({
							IdInput: options.IdInput, 
							IdInputHidden: options.IdInputHidden, 
							accion: 'autocomplete_editoriales', 
							callBackFunction: options.callBackFunction,
					});	
}

