
function Init(){
	AddDiv();
	ShowState();
}

//crea un Div dinamicamente
function AddDiv(){
var contenedor = document.getElementById("state");
	if(contenedor == null){
		//creo un div
		contenedor= document.createElement('div');
		contenedor.id= "state";

		//creo un nodo de texto
		Texto = document.createTextNode('Cargando...');

		table= document.createElement('table');
		row= document.createElement('tr');
		row.style.background="red";
		//seteo el estilo
		row.setAttribute("class","state");
		cell= document.createElement('td');
		cell.appendChild(Texto);
		row.appendChild(cell);
		table.appendChild(row);
		//agrego la tabla al div
		contenedor.appendChild(table);
		//seteo parametros del div
		contenedor.style.position= 'absolute'; 
		contenedor.style.visibility = "visible";
		contenedor.style.display="block";

		//agrego el div al body
		document.getElementsByTagName("body")[0].appendChild(contenedor);
	}
		contenedor.style.left= "0px";//window.pageXOffset+'px';
		contenedor.style.top= "0px";//window.pageYOffset+'px';
}


//muestra el div
function ShowState(){
	ObjDiv = document.getElementById("state");
	ObjDiv.style.visibility = "visible";
	ObjDiv.style.display="block";
};

//oculta el div
function HiddeState(){
	ObjDiv = document.getElementById("state");
	ObjDiv.style.visibility="hidden";
	ObjDiv.style.display="none";
};

