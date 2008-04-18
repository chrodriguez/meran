/* start dhtml building blocks */
function freezeEvent(e) {
//window.alert("Entro en fuction freezeEvent ");
if (e.preventDefault) e.preventDefault();
e.returnValue = false;
e.cancelBubble = true;
if (e.stopPropagation) e.stopPropagation();
return false;
}//freezeEvent

function isWithinNode(e,i,c,t,obj) {
//Esta function se ejecuta cuando se mueve el mouse o se presiona alguna tecla
answer = false;
te = e;
while(te && !answer) {
	if	((te.id && (te.id == i)) || (te.className && (te.className == i+"Class"))
			|| (!t && c && te.className && (te.className == c))
			|| (!t && c && te.className && (te.className.indexOf(c) != -1))
			|| (t && te.tagName && (te.tagName.toLowerCase() == t))
			|| (obj && (te == obj))
		) {
		answer = te;
	} else {
		te = te.parentNode;
	}
}
return te;
}//isWithinNode

function getEvent(event) {
//Esta function se ejecuta cuando se mueve el mouse o se presiona alguna tecla
return (event ? event : window.event);
}//getEvent()

function getEventElement(e) {
//Esta function se ejecuta cuando se mueve el mouse o se presiona alguna tecla
return (e.srcElement ? e.srcElement: (e.target ? e.target : e.currentTarget));
}//getEventElement()

function findElementPosX(obj) {
//Esta funcion se ejecuta luego de ingresar un caracter en el INPUT
	curleft = 0;
	if (obj.offsetParent) {
		while (obj.offsetParent) {
			curleft += obj.offsetLeft;
			obj = obj.offsetParent;
		}
	}//if offsetParent exists
	else if (obj.x)
		curleft += obj.x
	return curleft;
}//findElementPosX

function findElementPosY(obj) {
//Esta funcion se ejecuta luego de ingresar un caracter en el INPUT
	curtop = 0;
	if (obj.offsetParent) {
		while (obj.offsetParent) {
			curtop += obj.offsetTop;
			obj = obj.offsetParent;
		}
	}//if offsetParent exists
	else if (obj.y)
		curtop += obj.y
	return curtop;
}//findElementPosY

/* end dhtml building blocks */

function handleKeyPress(event) {
//Esta funcion se ejecuta cuando se presiona una tecla
e = getEvent(event);
eL = getEventElement(e);

upEl = isWithinNode(eL,null,"wickEnabled",null,null);

kc = e["keyCode"];

//si se presiona ENTER o TAB
if (siw && ((kc == 13) || (kc == 9))) {
	siw.selectingSomething = true;
	if (siw.isSafari) siw.inputBox.blur();   //hack to "wake up" safari
	siw.inputBox.focus();
	siw.inputBox.value = siw.inputBox.value.replace(/[ \r\n\t\f\s]+$/gi,' ');
	hideSmartInputFloater();
} else if (upEl && (kc != 38) && (kc != 40) && (kc != 37) && (kc != 39) && (kc != 13) && (kc != 27)) 	{	
		if (!siw || (siw && !siw.selectingSomething)) {
			processSmartInput(upEl);
		}
	} else if (siw && siw.inputBox) {
		siw.inputBox.focus(); //kinda part of the hack.
	}

}//handleKeyPress()


function handleKeyDown(event) {
//Esta funcion se ejecuta cuando se presiona una tecla
//y verfica que teclas se han presionado
e = getEvent(event);
eL = getEventElement(e);

if (siw && (kc = e["keyCode"])) {
	
	//si presiona down arrow
	if (kc == 40) {
		siw.selectingSomething = true;
		freezeEvent(e);
		if (siw.isGecko) siw.inputBox.blur(); /* Gecko hack */
		selectNextSmartInputMatchItem();
		//si presiona up arrow
	} else if (kc == 38) {
		siw.selectingSomething = true;
		freezeEvent(e);
		if (siw.isGecko) siw.inputBox.blur();
		selectPreviousSmartInputMatchItem();
		//si presiona ENTER (13) o TAB (9)
	} else if ((kc == 13) || (kc == 9)) {
		siw.selectingSomething = true;
		activateCurrentSmartInputMatch();
		freezeEvent(e);
		//si presiona ESC
	} else if (kc == 27)  {
		hideSmartInputFloater();	
		freezeEvent(e);
		//si presiona Backspace
	} else if (kc == 8)  {
			//si borro todo, se oculta la lista
			if(siw.inputBox.value.length <= 1){
				siw.inputBox.value = '';
				hideSmartInputFloater();		
				freezeEvent(e);
			}
	} else {
		siw.selectingSomething = false;
	}
}

}//handleKeyDown()

function handleFocus(event) {
	//cambio = false;
	e = getEvent(event);
	eL = getEventElement(e);
	
	if (focEl = isWithinNode(eL,null,"wickEnabled",null,null)) {
	if (!siw || (siw && !siw.selectingSomething)) processSmartInput(focEl);
	}
}//handleFocus()

function handleBlur(event) {
	e = getEvent(event);
	eL = getEventElement(e);
	if (blurEl = isWithinNode(eL,null,"wickEnabled",null,null)) {
		if (siw && !siw.selectingSomething) hideSmartInputFloater();
	}
}//handleBlur()

//Miguel - Tiene un bug, todavia no lo puedo resolver
function handleClick(event) {

	e2 = getEvent(event);
	//obtengo el objeto que disparo el evento
	eL2 = getEventElement(e2);

 	handleKeyPress(event);

	//si hace click fuera de la lista se oculta la lista
	if(!(siw.selectingSomething)){
	//if(!(siw.selectingSomething)&&(siw.inputBox.className == 'wickEnabled')&&(eL2.className == 'floater')){
		hideSmartInputFloater();
		handleKeyPress(event);
	}
	else
	{
        //solo esto estaba en principio
		if (siw && siw.selectingSomething) {
			selectFromMouseClick();
		}
	}
}//handleClick()


function handleMouseOver(event) {
//Esta funcion se ejecuta cuando se pasa sobre el objeto
	e = getEvent(event);
	eL = getEventElement(e);
	if (siw && (mEl = isWithinNode(eL,null,"matchedSmartInputItem",null,null))) {
		siw.selectingSomething = true;
		selectFromMouseOver(mEl);
	} else if (isWithinNode(eL,null,"siwCredit",null,null)) {
		siw.selectingSomething = true;
	}else if (siw) {
		siw.selectingSomething = false;
	}
}//handleMouseOver

function showSmartInputFloater() {
//Esta funcion muestra la ventana flotante
if (!siw.floater.style.display || (siw.floater.style.display=="none")) {
	if (!siw.customFloater) {
		//hack: browser-specific adjustments.
		if (!siw.isGecko && !siw.isWinIE) x += 8;
		if (!siw.isGecko && !siw.isWinIE) y += 10;
	} else {
	//you may
	//do additional things for your custom floater
	//beyond setting display and visibility
	}
	//busco el objeto (Input o TextArea)
	x = findElementPosX(siw.inputBox);	
	y = findElementPosY(siw.inputBox);	
	siw.floater.style.left = x + 'px';
	//por ahora lo dejo asi, abria q calcular dinamicamente, el alto del input, para no poner 20
	siw.floater.style.top = (y + 20) + 'px';
	//Muestro la lista
	siw.floater.style.display="block";
	siw.floater.style.visibility="visible";
}
}//showSmartInputFloater()

function hideSmartInputFloater() {
//Esta funcion se ejecuta cuando se oculta la lista de los autores (luego de seleccionar uno)
if (siw) {
siw.floater.style.display="none";
siw.floater.style.visibility="hidden";
siw = null;
}//siw exists
}//hideSmartInputFloater

function processSmartInput(inputBox) {
if (!siw) siw = new smartInputWindow();
siw.inputBox = inputBox;

classData = inputBox.className.split(" ");
siwDirectives = null;
for (i=0;(!siwDirectives && classData[i]);i++) {
	if (classData[i].indexOf("wickEnabled") != -1)
		siwDirectives = classData[i];
}

if (siwDirectives && (siwDirectives.indexOf(":") != -1)) {
siw.customFloater = true;
newFloaterId = siwDirectives.split(":")[1];
siw.floater = document.getElementById(newFloaterId);
siw.floaterContent = siw.floater.getElementsByTagName("div")[0];
}


setSmartInputData();
if (siw && (siw.matchCollection && (siw.matchCollection.length > 0))) selectSmartInputMatchItem(0);
content = getSmartInputBoxContent();
}//processSmartInput()

function smartInputMatch(cleanValue, value) {
	this.cleanValue = cleanValue;
	this.value = value;
	this.isSelected = false;
}//smartInputMatch

//Miguel 28/03/07 - Cambie toLowerCase a toUpperCase, poq pedian que se muestre el nombre del autor con mayusculas
function simplify(s) {
return s.toUpperCase().replace(/^[ \s\f\t\n\r]+/,'').replace(/[ \s\f\t\n\r]+$/,'');
//.replace(/[�,�,�,�,\u00E9,\u00E8,\u00EA,\u00EB]/gi,"e").replace(/[�,�,\u00E0,\u00E2]/gi,"a").
}//simplify

function getUserInputToMatch(s) {
a = s;
fields = s.split("\n");
if (fields.length > 0) a = fields[fields.length - 1];
return a;
}//getUserInputToMatch

function getUserInputBase() {
s = siw.inputBox.value;
a = s;
if ((lastComma = s.lastIndexOf("\n")) != -1) {
	a= a.substring(0,lastComma+1);
}
else	a = "";

return a;
}//getUserInputBase()

function runMatchingLogic(userInput, standalone) {
	userInput = simplify(userInput);
	uifc = userInput.charAt(0).toLowerCase();
	if (uifc == '"') uifc = (n = userInput.charAt(1)) ? n.toLowerCase() : "z";
	if (standalone) userInput = uifc;
	if (siw) siw.matchCollection = new Array();
	pointerToCollectionToUse = http.responseText.split('#');
	
	tempCollection = new Array();
	re1 = new RegExp("^([ \"\}\{\-]*)("+userInput+")","gi");
	re2 = new RegExp("([ \"\}\{\-]+)("+userInput+")","gi");
		
	for (i=0,j=0;(i<pointerToCollectionToUse.length);i++) {
		entry = pointerToCollectionToUse[i];
		mEntry = simplify(entry);
		userInput = userInput.replace(/\>/gi,'\\}').replace(/\< ?/gi,'\\{');
		re = new RegExp("(" + userInput + ")","i");
		if (siw){
		 	if(j < siw.MAX_MATCHES) {
				if(mEntry.indexOf(userInput) == 0){
					siw.matchCollection[j] = new smartInputMatch(entry, mEntry.replace(/\>/gi,'}').replace(/\< ?/gi,'{').replace(re,"<b>$1</b>"));
				} else {
					siw.matchCollection[j] = new smartInputMatch(entry, mEntry.replace(/\>/gi,'}').replace(/\</gi,'{').replace(re1,"$1<b>$2</b>").replace(re2,"$1<b>$2</b>"));
					}
				tempCollection[j] = entry;
				j++;		
			}
		}	
	}//loop thru collection
}//runMatchingLogic

function setSmartInputData() {
if (siw) {
	orgUserInput = siw.inputBox.value;
	orgUserInput = getUserInputToMatch(orgUserInput);
	userInput = orgUserInput.toLowerCase().replace(/[\r\n\t\f\s]+/gi,' ').replace(/^ +/gi,'').replace(/ +$/gi,'').replace(/ +/gi,' ').replace(/\\/gi,'').replace(/\[/gi,'').replace(/\(/gi,'').replace(/\./gi,'\.').replace(/\?/gi,'');
	if (userInput && (userInput != "") && (userInput != '"')) 
	{
		getagent(userInput,siw.inputBox.id);
	}//if userinput not blank and is meaningful
	else {siw.matchCollection = null;}
}//siw exists ... uhmkaaayyyyy
}//setSmartInputData

function getSmartInputBoxContent() {
a = null;
//if (siw && siw.matchCollection && (siw.matchCollection.length > 0)) {
if (siw && siw.matchCollection) {
//window.alert('se ejecuta getSmartInputBoxContent');
a = '';
for (i = 0;i < siw.matchCollection.length; i++) {
selectedString = siw.matchCollection[i].isSelected ? ' selectedSmartInputItem' : '';
a += '<p class="matchedSmartInputItem' + selectedString + '">' + siw.matchCollection[i].value.replace(/\{ */gi,"&lt;").replace(/\} */gi,"&gt;") + '</p>';
}//
}//siw exists

return a;
}//getSmartInputBoxContent

function modifySmartInputBoxContent(content) {
//todo: remove credits 'cuz no one gives a shit ;] - done
if (siw){
//alert(content);
siw.floaterContent.innerHTML = '<div id="smartInputResults">' + content + '</div>';
//alert(siw.floaterContent.innerHTML);
//alert(siw.floaterContent.innerHTML);
siw.matchListDisplay = document.getElementById("smartInputResults");}
}//modifySmartInputBoxContent()

function selectFromMouseOver(o) {
//Esta funcion se ejecuta cuando se posiciona sobre una de las opciones del la lista de autores
currentIndex = getCurrentlySelectedSmartInputItem();
if (currentIndex != null) deSelectSmartInputMatchItem(currentIndex);
newIndex = getIndexFromElement(o);
selectSmartInputMatchItem(newIndex);
modifySmartInputBoxContent(getSmartInputBoxContent());
}//selectFromMouseOver

function selectFromMouseClick() {
activateCurrentSmartInputMatch();
siw.inputBox.focus();
hideSmartInputFloater();
}//selectFromMouseClick

function getIndexFromElement(o) {
index = 0;
while(o = o.previousSibling) {
index++;
}//
return index;
}//getIndexFromElement

function getCurrentlySelectedSmartInputItem() {
answer = null;
for (i = 0; ((i < siw.matchCollection.length) && !answer) ; i++) {
	if (siw.matchCollection[i].isSelected)
		answer = i;
}//
return answer;
}//getCurrentlySelectedSmartInputItem

function selectSmartInputMatchItem(index) {
	siw.matchCollection[index].isSelected = true;
}//selectSmartInputMatchItem()

function deSelectSmartInputMatchItem(index) {
	siw.matchCollection[index].isSelected = false;
}//deSelectSmartInputMatchItem()

function selectNextSmartInputMatchItem() {
currentIndex = getCurrentlySelectedSmartInputItem();
if (currentIndex != null) {
	deSelectSmartInputMatchItem(currentIndex);
	if ((currentIndex + 1) < siw.matchCollection.length)
 		selectSmartInputMatchItem(currentIndex + 1);
	else
		selectSmartInputMatchItem(0);
} else 
{
	selectSmartInputMatchItem(0);
}
modifySmartInputBoxContent(getSmartInputBoxContent());
}//selectNextSmartInputMatchItem

function selectPreviousSmartInputMatchItem() {
currentIndex = getCurrentlySelectedSmartInputItem();
if (currentIndex != null) {
	deSelectSmartInputMatchItem(currentIndex);
	if ((currentIndex - 1) >= 0)
 		selectSmartInputMatchItem(currentIndex - 1);
	else
		selectSmartInputMatchItem(siw.matchCollection.length - 1);
} else {
	selectSmartInputMatchItem(siw.matchCollection.length - 1);
}
modifySmartInputBoxContent(getSmartInputBoxContent());
}//selectPreviousSmartInputMatchItem

function activateCurrentSmartInputMatch() {
	baseValue = getUserInputBase();
	if ((selIndex = getCurrentlySelectedSmartInputItem()) != null) {
		addedValue = siw.matchCollection[selIndex].cleanValue;
		theString = (baseValue ? baseValue : "") + addedValue + "\n";
 		//se muestra en el input el string seleccionado de la lista
		siw.inputBox.value = theString;
		runMatchingLogic(addedValue, true);
	}
}//activateCurrentSmartInputMatch

function smartInputWindow () {
	this.customFloater = false;
	this.floater = document.getElementById("smartInputFloater");
	this.floaterContent = document.getElementById("smartInputFloaterContent");
	this.selectedSmartInputItem = null;
	this.MAX_MATCHES = 15;
	this.isGecko = (navigator.userAgent.indexOf("Gecko/200") != -1);
	this.isSafari = (navigator.userAgent.indexOf("Safari") != -1);
	this.isWinIE = ((navigator.userAgent.indexOf("Win") != -1 ) && (navigator.userAgent.indexOf("MSIE") != -1 ));
	this.showCredit = false;
}//smartInputWindow Object

function registerSmartInputListeners() {
inputs = document.getElementsByTagName("input");
texts = document.getElementsByTagName("textarea");
allinputs = new Array();
z = 0;
y = 0;
while(inputs[z]) {
allinputs[z] = inputs[z];
z++;
}//
while(texts[y]) {
allinputs[z] = texts[y];
z++;
y++;
}//

for (i=0; i < allinputs.length;i++) {
	if ((c = allinputs[i].className) && (c == "wickEnabled")) {
		allinputs[i].setAttribute("autocomplete","OFF");
		allinputs[i].onfocus = handleFocus;
		allinputs[i].onblur = handleBlur;
		allinputs[i].onkeydown = handleKeyDown;
		allinputs[i].onkeyup = handleKeyPress;
		//manejador agregado como prueba para manejar evento click
	//	allinputs[i].onclick = handleClick;
	}
}//loop thru inputs
}//registerSmartInputListeners

siw = null;

if (document.addEventListener) {
	document.addEventListener("keydown", handleKeyDown, false);
	document.addEventListener("keyup", handleKeyPress, false);
	document.addEventListener("mouseup", handleClick, false);
	//este manejador se agrego, si no hace falta hay que sacarlo
	//document.addEventListener("onclick", handleClick, false);
	document.addEventListener("mouseover", handleMouseOver, false);
} else {
	document.onkeydown = handleKeyDown;
	document.onkeyup = handleKeyPress;
	document.onmouseup = handleClick;
	document.onmouseover = handleMouseOver;
}

registerSmartInputListeners();
document.write (
'<table id="smartInputFloater" class="floater" cellpadding="0" cellspacing="0"><tr><td id="smartInputFloaterContent" nowrap="nowrap">'
+'<\/td><\/tr><\/table>'
);

//note: instruct users to the fact that no commas should be present in entries.
//it would make things insanely messy.
//this is why i'm filtering commas here:
//for (x=0;x<collection.length;x++) {
//collection[x] = collection[x].replace(/\,/gi,'');
//}//

collectionIndex = new Array();

ds = "";
function debug(s) {
ds += ( s + "\n");
}
