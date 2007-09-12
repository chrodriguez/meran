 var http = false;
if (window.ActiveXObject)
	{
		http=new ActiveXObject("Microsoft.XMLHTTP")
	}
	else
		if (window.XMLHttpRequest)
		{
			http=new XMLHttpRequest()
		}

/* try {
  http = new XMLHttpRequest();
  } catch (trymicrosoft) {
  try {
	  http = new ActiveXObject("Msxml2.XMLHTTP");
  } catch (othermicrosoft) {
  try {
  http = new ActiveXObject("Microsoft.XMLHTTP");
  } catch (failed) {
	  http = false;
  } 
  }
  }*/
if (!http)
  window.alert("ERROR AL INICIALIZAR!");
  

var url = "/cgi-bin/koha/ajax.pl?param="; 
var userInput2=null;
function getagent(param2,id) {

userInput2=param2;
//var myRandom = parseInt(Math.random()*99999999); // cache buster
http.abort();
http.open("GET", url + escape(param2) + "&amp;tipo="+id+"&amp;rand=0", true);
http.onreadystatechange = handleHttpResponse;
http.send(null); }

function handleHttpResponse() {
  	if (http.readyState == 4) {
	content=http.responseText;
	if (content) {
		//runMatchingLogic(userInput2);
		runMatchingLogic(userInput2);
		if (siw.matchCollection && (siw.matchCollection.length > 0)) selectSmartInputMatchItem(0);
		content2 = getSmartInputBoxContent();
	if (content2) {
		modifySmartInputBoxContent(content2);
		showSmartInputFloater();
	} else hideSmartInputFloater();
		//content2=getSmartInputBoxContent();
	//window.alert(content);
	//window.alert(content2);
		//modifySmartInputBoxContent(content);
		//showSmartInputFloater();
		//window.alert("einar".replace(/\{ */gi,"&lt;").replace(/\}*/gi,"&gt;"));
		
	} else hideSmartInputFloater();
	
  //if (http.responseText){ 
   //	document.getElementById("hiddenauthor").style.visibility="visible";
	//document.getElementById("hiddenauthor").innerHTML=http.responseText;
	//document.getElementById("hiddenauthor").innerHTML="JUAM"; 
	//}
   } 
   }
 function loadrecord(record) { 
   //document.getElementById("author").value = record;
   //document.getElementById("hiddenauthor").style.visibility="hidden";
    }

