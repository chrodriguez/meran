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

function _CrearAutocomplete(Id, IdHidden, url){
    $("#"+Id).search();
    // q= valor de campoHelp
    $("#"+Id).autocomplete(url,{
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
    $("#"+Id).result(function(event, data, formatted) {
        $("#"+Id).val(data[1]);
        _getId(IdHidden, data[0])
    });
}


//Funciones publicas

function CrearAutocompleteCiudades(Id, IdHidden, url){
    _CrearAutocomplete(Id, IdHidden, url);
}

function CrearAutocompletePaises(Id, IdHidden, url){
    _CrearAutocomplete(Id, IdHidden, url);
}

function CrearAutocompleteLenguajes(Id, IdHidden, url){
    _CrearAutocomplete(Id, IdHidden, url);
}

function CrearAutocompleteAutores(Id, IdHidden, url){
    _CrearAutocomplete(Id, IdHidden, url);
}

function CrearAutocompleteSoportes(Id, IdHidden, url){
    _CrearAutocomplete(Id, IdHidden, url);
}
