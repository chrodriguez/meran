 var http = false;

//estados 
//0 Uninitialized
//1 Loading
//2 Loaded
//3 Interactive
//4 Complete
	
//se crea el objeto XMLHttpRequest, para hacer los requerimientos al servidor
if (window.ActiveXObject)
	{
		//para Internet Explorer
		http=new ActiveXObject("Microsoft.XMLHTTP")
	}
	else
		if (window.XMLHttpRequest)
		{	//para Mozilla/Safari
			http=new XMLHttpRequest()
		}

if (!http)
  window.alert("ERROR AL INICIALIZAR!");
  

var url = "/cgi-bin/koha/ajax.pl?param="; 
var userInput2=null;
function getagent(param2,id) {
//window.alert("Entro en fuction getagent ");

userInput2=param2;
http.abort();
//window.alert('parametro ' + param2 + ' tipo: ' + id);
//lo que necesitemos es pasado en la URL al servidor
http.open("GET", url + escape(param2) + "&amp;tipo="+id+"&amp;rand=0", true);
http.onreadystatechange = handleHttpResponse;
http.send(null); 
}

function handleHttpResponse() {
//window.alert("Entro en fuction handleHttpResponse ");
	//si se completo el requerimiento al servidor
  	if (http.readyState == 4) {
		content=http.responseText;
		if (content) {
			runMatchingLogic(userInput2);
			if (siw.matchCollection && (siw.matchCollection.length > 0)){ 			selectSmartInputMatchItem(0);
				content2 = getSmartInputBoxContent();
			}
			if (content2) {
				modifySmartInputBoxContent(content2);
				showSmartInputFloater();
			} else hideSmartInputFloater();		
		} else hideSmartInputFloater()
	} 
}



