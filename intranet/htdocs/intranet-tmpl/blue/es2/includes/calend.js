<link rel="stylesheet" type="text/css" media="all" href="/intranet-tmpl/blue/es2/includes/calcss/calendar-win2k-cold-1.css" title="win2k-cold-1" />

<!-- main calendar program -->
<script type="text/javascript" src="/intranet-tmpl/blue/es2/includes/calendar.js"></script>

<!-- language for the calendar -->
<script type="text/javascript" src="/intranet-tmpl/blue/es2/includes/callang/calendar-es.js"></script>

<!-- the following script defines the Calendar.setup helper function, which makes
adding a calendar a matter of 1 or 2 lines of code. -->
<script type="text/javascript" src="/intranet-tmpl/blue/es2/includes/calendar-setup.js"></script>
<div id="output"></div>  
<table align="center" id="calendar-container"></table>

<script type="text/javascript">
//var MA = [];
var e = document.getElementById("output");

function in_array(arr,elem) {
	for (i=0; i<arr.length; i++) {
		if (arr[i] == elem) {
			return true;
		}
	}
	return false;
}

function delete_array_value(value, array)
/* Borra de un arreglo todas las ocurrencias de un dato */
{ 
	var a= new Array();
	for (var j=0; j<array.length; j++) {
		if (array[j] != value) {
			a[a.length]= array[j];
		}
	}
	return a;
}

function agregarFecha(fecha) {
	var ok=1;
	for (i=0;i<MA.length;i++) { if (MA[i]==fecha){ok=0;} }
	if(ok==1){
	MA[MA.length]=fecha;
		e.innerHTML += '<a href="#" onclick=eliminarFecha("'+fecha+'")>'+fecha+'</a><br>';
	}
	return(ok);
}

function eliminarFecha(fecha) {
	var aux=new Array();
	e.innerHTML='';
	for (i=0;i<MA.length;i++) {
		if (MA[i]!=fecha) {
			e.innerHTML += '<a href="#" onclick=eliminarFecha("'+MA[i]+'")>'+MA[i]+'</a><br>';
			aux[aux.length]=MA[i];
		} 
	}
	MA=aux;
}

function dateChanged(calendar) {
	// Beware that this function is called even if the end-user only
	// changed the month/year.  In order to determine if a date was
	// clicked you can use the dateClicked property of the calendar:
	if (calendar.dateClicked) {
		var m = calendar.date.getMonth() + 1 ;
		var d = calendar.date.getDate(); 
		var a = calendar.date.getYear() + 1900; 
		agregarFecha(d+'/'+m+'/'+a);
	}
}

/*
function dateClicked(calendar) {
	var m = calendar.date.getMonth() + 1 ;
	var d = calendar.date.getDate(); 
	var a = calendar.date.getYear(); 
	agregarFecha(m+'/'+d+'/'+a);
}
*/

function unDiaMas(calendar){
	fecha= calendar.date.print("%d/%m/%Y");
	if (in_array(nuevos_feriados,fecha)) {
		nuevos_feriados= delete_array_value(fecha, nuevos_feriados);
	}else{
		nuevos_feriados[nuevos_feriados.length]=fecha;
	}
}

function getDateText(date) {
	fecha= date.print("%d/%m/%Y");
	//if (in_array(feriados,fecha)) {
	if (feriados[fecha]) {
		return 'holiday';
	}else{
		return false;
	}
}

Calendar.setup(
{
align      : "BR",
showOthers : true,
flat       : "calendar-container",
flatCallback : dateChanged,
dateStatusFunc: getDateText,
multiple   : MA,
onUpdate   : unDiaMas,
}
);

</script>
