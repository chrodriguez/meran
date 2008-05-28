/*
 * LIBRERIA UTIL.JS
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria prototype.js
 * @author Carbone Miguel, Di Costanzo Damián
 * Fecha de creacion 11/09/2007
 *
 */


//Utilidad del Ancla <a name=#name></a>

/*
 * esta variable ancla se setea cuando se crea el ancla con el string correspondiente al tag <a>
 */
var ancla="";

/*
 * Esta funcion crea un ancla antes del elemento con el id que viene como parametro
 * @param id es el id del elemento antes del cual se va crea el ancla.
 * @param strAncla es el nombre y el id del ancla 
 */
function crearAncla(id,strAncla){
	if(!$(strAncla)){
		new Insertion.Before(id,"<a id="+strAncla+" name="+strAncla+"></a>");
	}
	ancla="#"+strAncla;
}

/*
 * Esta funcion situa la vista de la pagina en el ancla creada.
 * Se recomienda usarla cuando se termina de ejecutar la funcion de ajax
 */
function redirect(){
	if(ancla != ""){
		location.href=ancla;
		ancla="";
	}
}

//FIN Utilidad ancla