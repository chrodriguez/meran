
//este codigo debe ser incluido luego del codigo que se genera para manejar AJAX
var alto= screen.width;
    ancho= screen.height;

function Init(){
	AddDiv();
	ShowState();
}

//crea un Div dinamicamente
function AddDiv(){

var contenedor = $('#state')[0];
	if(contenedor == null){
		$('body').append("<div id='state' class='loading' style='position:absolute'></div>");
		$('#state').html("<img src='/intranet-tmpl/blue/es2/images/indicator.gif' />");
		$('#state')[0].style.top= window.pageXOffset+'px';
		$('#state')[0].style.left= window.pageYOffset+'px';
	}else{
		$('#state')[0].style.top= window.pageXOffset+'px';
		$('#state')[0].style.left= window.pageYOffset+'px';
	}
}


//muestra el div
function ShowState(){
	$('#state').show();
};

//oculta el div
function HiddeState(){
 	$('#state').hide();
};

