/**************************************************************
Menú en arbol. Script creado por Tunait! (31/7/2004)
Si quieres usar este script en tu sitio eres libre de hacerlo con la condición de que permanezcan intactas estas líneas, osea, los créditos, pero esta es una bersión beta en fase de pruebas.
No autorizo a publicar y/o distribuír el código en sitios de script sin previa autorización
Si quieres publicarlo, por favor, contacta conmigo.
http://javascript.tunait.com/
tunait@yahoo.com 
****************************************************************/
var anMenu = 205
var totalMen = 10
var anImas = 12
var alImas = 12
var direc = '/intranet-tmpl/blue/es2/images'
var mas = '/mast.gif'
var menos = '/menost.gif'
var puntos = '/puntost.gif'
var puntosv = '/puntosvt.gif'
var carpeab = '/book-open.png'
var carpece = '/book-closed.png'
var puntosu = '/puntosut.gif'
var doc = '/txt.png'
var docsel = '/docselt.gif'
var carpeabsel = '/carpabiertasel.gif'
var carpecesel = '/carpcerradasel.gif'
var icHome = '/home.png'
var puntosh = '/puntosh.gif'
function tunMen(tex,enl,dest,subOp,an){
this.tex = tex;
this.enl = enl;
this.dest = dest;
this.subOp = subOp;
this.an = an;
this.secAc = false
}
Op_0 = new tunMen('Inicio','/cgi-bin/koha/intranet-mainpage.pl','koha_main',0)
Op_1 = new tunMen('Catálogo',null,null,6,150)
	Op_1_0 = new tunMen('Búsqueda Rápida','/cgi-bin/koha/loadmodules.pl?module=search&marc=0&type=intranet','koha_main',0)
	Op_1_1 = new tunMen('Búsqueda MARC','/cgi-bin/koha/loadmodules.pl?module=search&marc=1&type=intranet','koha_main',0)
	Op_1_2 = new tunMen('Estantes Virtuales','/cgi-bin/koha/shelves.pl?startfrom=0','koha_main',0)
	Op_1_3 = new tunMen('Agregar Libro','/cgi-bin/koha/loadmodules.pl?module=addbiblio&type=intranet','koha_main',0)
	Op_1_4 = new tunMen('Mantenimiento','/cgi-bin/koha/maint/catmaintain.pl','koha_main',0)
	Op_1_5 = new tunMen('Importación','/cgi-bin/koha/importacion.pl','koha_main',0)

Op_2 = new tunMen('Usuarios',null,null,4,100)
	Op_2_0 = new tunMen('Usuarios Reales','/cgi-bin/koha/members-home.pl','koha_main',0)
	Op_2_1 = new tunMen('Usuarios Potenciales','/cgi-bin/koha/members-home2.pl','koha_main',0)
	Op_2_2 = new tunMen('Agregar Usuario','/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=adult','koha_main',0)
	Op_2_3 = new tunMen('Agregar Organización','/cgi-bin/koha/simpleredirect.pl?type=Agregar&chooseform=organisation','koha_main',0)
	
Op_3 = new tunMen('Circulación',null,null,3,150)
	Op_3_0 = new tunMen('Préstamos','/cgi-bin/koha/circ/circulation.pl','koha_main',0)
        Op_3_1 = new tunMen('Devoluciones','/cgi-bin/koha/circ/returns.pl','koha_main',0)
	Op_3_2 = new tunMen('Transferencias','/cgi-bin/koha/circ/branchtransfers.pl','koha_main',0)
	
Op_4 = new tunMen('Adquisición',null,null,2,205)
  	Op_4_0 = new tunMen('Adquisición de ejemplares','/cgi-bin/koha/loadmodules.pl?module=acquisitions','koha_main',0)
        Op_4_1 = new tunMen('Crear descripción bibliográfica','/cgi-bin/koha/acqui.simple/addbiblio-nomarc.pl','koha_main',0)
	  

Op_5 = new tunMen('Reportes',null,null,10,200)
        Op_5_0 = new tunMen('Todos','/cgi-bin/koha/reports-home.pl','koha_main',0)
	Op_5_1 = new tunMen('Reporte diario (hoy)','/cgi-bin/koha/stats.pl?time=today','koha_main',0)
	Op_5_2 = new tunMen('Reporte diario (ayer)','/cgi-bin/koha/stats.pl?time=yesterday','koha_main',0)
	Op_5_3 = new tunMen('Inventario','/cgi-bin/koha/reports/inventory.pl','koha_main',0)
	Op_5_4 = new tunMen('Usuarios','/cgi-bin/koha/reports/users.pl','koha_main',0)
	Op_5_5 = new tunMen('Préstamos sin devolver','/cgi-bin/koha/reports/prestamos.pl','koha_main',0)
	Op_5_6 = new tunMen('Reservas','/cgi-bin/koha/reports/reservas.pl','koha_main',0)
	Op_5_7 = new tunMen('Registro de actividades','/cgi-bin/koha/reports/registro.pl','koha_main',0)
	Op_5_8 = new tunMen('Actividades anuales','/cgi-bin/koha/reports/estadistica_Anual.pl','koha_main',0)
	Op_5_9 = new tunMen('Disponibilidad de Ejemplares','/cgi-bin/koha/reports/availability.pl','koha_main',0)
Op_6 = new tunMen('Parámetros',null,null,19,150)
	Op_6_0 = new tunMen('Todos','/cgi-bin/koha/admin-home.pl','koha_main',0)
        Op_6_1 = new tunMen('Unidades de información','/cgi-bin/koha/admin/branches.pl','koha_main',0)
	Op_6_2 = new tunMen('Fondos','/cgi-bin/koha/admin/aqbookfund.pl','koha_main',0)
	Op_6_3 = new tunMen('Monedas','/cgi-bin/koha/admin/currency.pl','koha_main',0)
	Op_6_4 = new tunMen('Tipos de documentos','/cgi-bin/koha/admin/itemtypes.pl','koha_main',0)
	Op_6_5 = new tunMen('Categoría de usuarios','/cgi-bin/koha/admin/categorie.pl','koha_main',0)
	Op_6_6 = new tunMen('Multas','/cgi-bin/koha/admin/charges.pl','koha_main',0)
	Op_6_7 = new tunMen('Valores autorizados','/cgi-bin/koha/admin/authorised_values.pl','koha_main',0)
	Op_6_8 = new tunMen('Thesaurus','/cgi-bin/koha/admin/thesaurus.pl','koha_main',0)
	Op_6_9 = new tunMen('Estructura de MARC','/cgi-bin/koha/admin/marctagstructure.pl','koha_main',0)
	Op_6_10 = new tunMen('Links Koha - MARC DB','/cgi-bin/koha/admin/koha2marclinks.pl','koha_main',0)
	Op_6_11 = new tunMen('Chequeo MARC','/cgi-bin/koha/admin/checkmarc.pl','koha_main',0)
        Op_6_12 = new tunMen('Impresoras','/cgi-bin/koha/admin/printers.pl','koha_main',0)
	Op_6_13 = new tunMen('Stop words','/cgi-bin/koha/admin/stopwords.pl','koha_main',0)
	Op_6_14 = new tunMen('Servidores Z39.50','/cgi-bin/koha/admin/z3950servers.pl','koha_main',0)
	Op_6_15 = new tunMen('Preferencias del sistema','/cgi-bin/koha/admin/systempreferences.pl','koha_main',0)
	Op_6_16 = new tunMen('Feriados','/cgi-bin/koha/admin/feriados.pl','koha_main',0)
        Op_6_17 = new tunMen('Sanciones','/cgi-bin/koha/admin/sanctions.pl','koha_main',0)
	Op_6_18 = new tunMen('Lugar','/cgi-bin/koha/place.pl','koha_main',0)
				

Op_7 = new tunMen('Herramientas',null,null,2,150)
     	Op_7_0 = new tunMen('Exportación','/cgi-bin/koha/export/marc.pl','koha_main',0)
     	Op_7_1 = new tunMen('Importación','/cgi-bin/koha/import/breeding.pl','koha_main',0)
Op_8 = new tunMen('Acerca de','/cgi-bin/koha/about.pl','koha_main',0)
Op_9 = new tunMen('Ayuda','','koha_main',0)


var tunIex=navigator.appName=="Microsoft Internet Explorer"?true:false;
if(tunIex && navigator.userAgent.indexOf('Opera')>=0){tunIex = false}
var manita = tunIex ? 'hand' : 'pointer'
var subOps = new Array()
function construye(){
cajaMenu = document.createElement('div')
cajaMenu.style.width = anMenu + "px"
document.getElementById('me').appendChild(cajaMenu)
for(m=0; m < totalMen; m++){
	opchon = eval('Op_'+m)
	ultimo = false
	try{
		eval('Op_' + (m+1))
	}
	catch(error){
		ultimo = true
	}
	boton = document.createElement('div')	
	boton.style.position = 'relative'
	boton.className = 'botones'
	boton.style.paddingLeft= 0
	carp = document.createElement('img')
	carp.style.marginRight = 5 + 'px'	
	carp.style.verticalAlign = 'middle'
	carp2 = document.createElement('img')
	carp2.style.verticalAlign = 'middle'


	enla = document.createElement('a')
	if(opchon.subOp > 0){
		carp2.style.cursor = manita
		carp2.src = direc + mas
		boton.secAc = opchon.secAc
		}
	else{
		carp2.style.cursor = 'default'
		enla.className = 'enls'
		if(ultimo){carp2.src = direc + puntosu}
		else{carp2.src = direc + puntos}
		}
		if(m == 0){
		carp.src = direc + icHome
		carp2.src = direc + puntosh
		}
	else{
		carp.src = direc + carpece
		}
	boton.appendChild(carp2)
	boton.appendChild(carp)
	enla.className = 'enls'
	enla.style.cursor = manita
	boton.appendChild(enla)
	enla.appendChild(document.createTextNode(opchon.tex))
	if(tunIex){
		enla.onmouseover = function(){this.className = 'botonesHover'}
		enla.onmouseout = function(){this.className = 'enls'}
		}
	if(opchon.enl != null && opchon.subOp == 0){
			enla.href = opchon.enl
			}
		if(opchon.dest != null && opchon.subOp == 0){
			enla.target = opchon.dest;
			}
	boton.id = 'op_' + m
	
	cajaMenu.appendChild(boton)
	if(opchon.subOp > 0 ){
		carp2.onclick= function(){
		abre(this.parentNode,this,this.nextSibling)
		}
		subOps[subOps.length] = boton.id.replace(/o/,"O")
		enla.onclick = function(){
			abre(this.parentNode,this.parentNode.firstChild,this.previousSibling)
			}
		}
	}
if(subOps.length >0){subMes()}
}
function subMes(){
lar = subOps.length
for(t=0;t<subOps.length;t++){
	opc =eval(subOps[t])
	for(v=0;v<opc.subOp;v++){
		if(eval(subOps[t] + "_" + v + ".subOp") >0){
			subOps[subOps.length] = subOps[t] + "_" + v
			}
		}
	}
construyeSub()
}
var fondo = true
function construyeSub(){
for(y=0; y<subOps.length;y++){
opchon = eval(subOps[y])
capa = document.createElement('div')
capa.className = 'subMe'
capa.style.position = 'relative'
capa.style.display = 'none'
if(!fondo){capa.style.backgroundImage = 'none'}
document.getElementById(subOps[y].toLowerCase()).appendChild(capa)
	for(s=0;s < opchon.subOp; s++){
		sopchon = eval(subOps[y] + "_" + s)
		ultimo = false
		try{
			eval(subOps[y] + "_" + (s+1))
			}
		catch(error){
			ultimo = true
			}
			if(ultimo && sopchon.subOp > 0){
			fondo = false
			}
		opc = document.createElement('div')
		opc.className = 'botones'
		opc.id = subOps[y].toLowerCase() + "_" + s
		if(tunIex){
		//	opc.onmouseover = function(){this.className = 'botonesHover'}
		//	opc.onmouseout = function(){this.className = 'botones'}
			}
		enla = document.createElement('a')
		enla.className = 'enls'
		enla.style.cursor = manita
		if(sopchon.enl != null && sopchon.subOp == 0){
			enla.href = sopchon.enl
			if(sopchon.dest != null && sopchon.subOp == 0){
				enla.target = sopchon.dest
				}
			}
		
		enla.appendChild(document.createTextNode(sopchon.tex))
		capa.appendChild(opc)
		carp = document.createElement('img')
		carp.src = direc + carpece
		carp.style.verticalAlign = 'middle'
		carp.style.marginRight = 5 + 'px'
		carp2 = document.createElement('img')
		carp2.style.verticalAlign = 'middle'
		if(sopchon.subOp > 0){
			opc.secAc = sopchon.secAc
			carp2.style.cursor = manita
			carp2.src = direc + mas
				enla.onclick = function(){
				abre(this.parentNode,this.parentNode.firstChild,this.previousSibling)
				}
			carp2.onclick= function(){
			abre(this.parentNode,this,this.nextSibling)
			}
			if(tunIex){
			enla.onmouseover = function(){this.className = 'botonesHover'}
			enla.onmouseout = function(){this.className = 'enls'}
			}
			}
		else{
			carp2.style.cursor = 'default'
			carp.src = direc + doc
			if(ultimo){carp2.src = direc + puntosu; 
			//alert(sopchon.subOp)
			if(sopchon.subOp > 0){alert('hola');capa.style.backgroundImage = 'none'}
			direc + puntosv
			}
			else{carp2.src = direc + puntos}
				}
		opc.appendChild(carp2)
		opc.appendChild(carp)
		opc.appendChild(enla)
		
		}
	}
Seccion()
}
function abre(cual,im,car){
//alert(cual.secAc)
abierta = cual.lastChild.style.display != 'none'? true:false;
if(abierta){
	cual.lastChild.style.display = 'none'
	im.src = direc + mas
	if(cual.secAc){
		car.src = direc + carpecesel
		
		}
	else{car.src = direc + carpece}
	}
else{
	cual.lastChild.style.display = 'block'
	im.src = direc + menos
	if(cual.secAc){car.src = direc + carpeabsel}
	else{car.src = direc + carpeab}
	}
}
var seccion = null
function Seccion(){
if (seccion != null){
	if(seccion.length == 4){
		document.getElementById(seccion.toLowerCase()).firstChild.nextSibling.src = direc + carpeabsel
		//alert(document.getElementById(seccion.toLowerCase()).lastChild.tagName)
		document.getElementById(seccion.toLowerCase()).lastChild.className = 'secac2'
		document.getElementById(seccion.toLowerCase()).lastChild.onmouseover = function(){
			this.className = 'enls'
			}
		document.getElementById(seccion.toLowerCase()).lastChild.onmouseout = function(){
			this.className = 'secac2'
			}
		}
	else{
		document.getElementById(seccion.toLowerCase()).firstChild.nextSibling.src = direc + docsel
		document.getElementById(seccion.toLowerCase()).firstChild.nextSibling.nextSibling.className = 'secac'
		document.getElementById(seccion.toLowerCase()).parentNode.parentNode.lastChild.previousSibling.className = 'secac2' 
		//
			document.getElementById(seccion.toLowerCase()).parentNode.parentNode.lastChild.previousSibling.onmouseout = function(){
			this.className = 'secac2'
			}
			if(!tunIex){
			document.getElementById(seccion.toLowerCase()).parentNode.parentNode.lastChild.previousSibling.onmouseover = function(){
			this.className = 'enls'
			}
		}
		document.getElementById(seccion.toLowerCase()).parentNode.parentNode.secAc = true
		//alert(document.getElementById(seccion.toLowerCase()).parentNode.parentNode.innerHTML)
		seccion = seccion.substring(0,seccion.length - 2)
		seccionb = document.getElementById(seccion.toLowerCase())
		abre(seccionb,seccionb.firstChild,seccionb.firstChild.nextSibling)
		if(seccion.length > 4){
		lar = seccion.length
			for(x = lar; x > 4; x-=2){
				seccion = seccion.substring(0,seccion.length - 2)
				seccionb = document.getElementById(seccion.toLowerCase())
				abre(seccionb,seccionb.firstChild,seccionb.firstChild.nextSibling)
				}
			}
		}
	}
}
onload = construye
