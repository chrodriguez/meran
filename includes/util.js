/*
 * LIBRERIA UTIL.JS
 * Esta es una libreria creada para el sistema KOHA
 * Para poder utilizarla es necesario incluir en el tmpl la libreria jquery.js
 * @author Carbone Miguel, Di Costanzo Damian
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
	if(!$("#"+strAncla)){
		new Insertion.Before(id,"<a id="+strAncla+" name="+strAncla+"></a>");
	}
	ancla="#"+strAncla;
}

//luego de x segundos se ejecuta la funcion pasada por parametro
function delay(funcion, segundos){
	setTimeout(funcion, segundos*1000);
}



/*
 * crearForm
 * Esta funcion crea un formulario para pasar los parametros por el metodo post con input hidden con sus 
 * respectivos valores y nombres. Despues de crearlo se hace el submit.
 * Para que funcione el tmpl tiene que tener un DIV con el id formulario.
 * @param url: url donde va el formulario (action del form)
 * @param params: string con los paramatros a pasar por el formulario, concatenado con "&" entre parametros y con
 *                "=" entre nombre y valor del parametro.
 */
function crearForm(url,params){
	var arrayParam=params.split("&");
	var formu=$("#formulario");
	var inputs="";
	for(var i=0; i<arrayParam.length;i++){
		var nombre=arrayParam[i].split("=")[0];
		var valor=arrayParam[i].split("=")[1];
		inputs=inputs + "<input type='hidden' name="+nombre+" value="+valor+"><br>";
	}
    inputs=inputs + "<input type='hidden' name='token' value="+token+"><br>";
	formu.html("<form id='miForm' action="+url+" method='post'>"+inputs+"</form>");
    
	$("#miForm")[0].submit();
}

/*
 * zebra
 * Le da la clase de estilo a las filas de las tabla, dependiendo si es impar o par.
 * necesita jquery para funcionar, se le tiene que pasar el nombre de la clase de la tabla a la que se
 * le quiere realizar la zebra
 */
function zebra(classObj){

	$("."+ classObj + " tr:gt(0):odd").addClass("impar");
	$("."+ classObj + " tr:gt(0):even").addClass("par");		
}


//devuelve la hora en HH:MM:SS
function tomarTiempo(){
	var currentTime = new Date()
	var hours = currentTime.getHours()
	var minutes = currentTime.getMinutes()
	var seconds = currentTime.getSeconds();
	if (minutes < 10)
		minutes = "0" + minutes

	if (seconds < 10)
		seconds = "0" + seconds;
	return hours + ":" + minutes + " " + " " + seconds;
}

/*
 * checkedAll
 * Selecciona y deselecciona a todos los checkbox, cuando se toca el boton.
 * primer click selecciona, segundo click deselecciona. 
 */
function checkedAll(id,nombreCheckbox){
	var result_array= $("#"+id);
	//se verifica la existencia de la componente
	if(result_array.length == 0)return alert('util.js=> checkedAll=> No existe la componte con ID: '+id);

	$("#"+id).toggle(function(){
		$("input[name="+nombreCheckbox+"]").each(function(){
			this.checked=true;})
		},
		function(){
			$("input[name="+nombreCheckbox+"]").each(function(){
			this.checked=false;})
		}
	);
}

/*
 * onEnter
 * Funcion que se asigna el evento onEnter al input que viene el id pasado por parametro y se ejecuta la funcion
 * que se pasa por paramentro.
 */
function onEnter(idInput,funcion){
	var result_array= $("#"+idInput);
	//se verifica la existencia de la componente
	if(result_array.length == 0)return alert('util.js=> onEnter => No existe la componte con ID: '+idInput);

	$("#"+idInput).keypress(function (e) {
 		if(e.which == 13){
			if(this.value != ''){
			//si el campo es <> de blanco
 				funcion();
			}
 		}
	});
}

/*
Esta funcion registra el evento keypress en todas los tipos de componetes pasados por parametro
tipos de componentes = [input, etc]
*/
function registrarKeypress(typeObject){
	var componentes=["input", "INPUT"]; //se pueden agregar mas componetes
	var result= componentes.indexOf(typeObject);

	if(result == -1)return alert('util.js=> registrarKeypress => Componente Inválida');

    $(typeObject).keypress(function (e) {
        if(e.which == 13){
			if(this.value != ''){
			//si el campo es <> de blanco
            	buscar();
			}
        }
    });
}

/*
* Hace un scroll a donde se encuentra el id del objeto pasado por parametro
*
*/
function scrollTo(idObj){
	var result_array= $("#"+idObj);
	//se verifica la existencia de la componente
	if(result_array.length == 0)return alert('util.js=> scrollTo => No existe la componte con ID: '+idObj);

	var divOffset = $('#'+idObj).offset().top;
	$('html,body').animate({scrollTop: divOffset}, 1000);
}


/*
 * getRadioButtonSelectedValue
 * Funcion retorna el valor seleccionado en un radiobutton
 */

function getRadioButtonSelectedValue(ctrl){
    for(i=0;i<ctrl.length;i++)
        if(ctrl[i].checked) return ctrl[i].value;
}


function highlight(classesArray,idKeywordsArray){

    for (x = 0; x< idKeywordsArray.length; x++){
        stringArray = ($('#'+idKeywordsArray[x]).val()).split(' ');
        for (y = 0; y< stringArray.length; y++){
			if($.trim(stringArray[y]).length != 0){
				for (z = 0; z< classesArray.length; z++){
					$('.'+classesArray[z]).highlight(stringArray[y]);
// 					window.console.log(	"stringArray[y] => " + stringArray[y] + "\n");
				}
			}//END if($.trim(stringArray[y]).length != 0){
        }
    }

}
