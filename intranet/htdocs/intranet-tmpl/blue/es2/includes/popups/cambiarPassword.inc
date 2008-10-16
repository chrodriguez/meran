<!-- *********************************Window Help********************************************* -->

<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.bgiframe.min.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/jquery.dimensions.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.mouse.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.js"></script>
<script src="/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.ext.js"></script>

<script>

// ## FIXME NO FUNCIONA, DEBERIA CARGAR DE MANERA CONDICIONAL
// if (typeof($.Autocompleter) != "function"){
		
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/jquery.bgiframe.min.js");
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/jquery.dimensions.js");
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.mouse.js");
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.js");
// 	$.getScript("/intranet-tmpl/blue/es2/includes/jquery/ui.draggable.ext.js");

// }

function closeWindow(){
	$('.windowBlur').hide();
	$('#window').hide();
}

function openWindow(){
	clearInput();
	$('.windowBlur').show();
	$('#window').draggable({opacity: 0.7777});
	$('#window').show();
	$('#window').centerObject();	
	$('#newpassword').focus();
}

function clearInput(){
	$('#newpassword').val('');
	$('#newpassword1').val('');
}


var objAH;//Objeto AjaxHelper.

//muestra los ejemplares del grupo
function cambiarPassword(claveUsuario, confirmeClave){

	objAH=new AjaxHelper(updateCambiarPassword);
	//objAH.debug= true;
	objAH.url= '/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
	objAH.newpassword= claveUsuario;
	objAH.newpassword1= confirmeClave;
	objAH.usuario= usuario.ID;
	objAH.tipoAccion= 'CAMBIAR_PASSWORD';
	//se envia la consulta
	objAH.sendToServer();
}

function updateCambiarPassword(responseText){
	clearInput();
	var Message= JSONstring.toObject(responseText);
	setMessage(Message);
}

function verificarClaveUsuario(){
	var claveUsuario= $('#newpassword').val();
	var confirmeClave= $('#newpassword1').val();
	

	if (claveUsuario == ''){
		alert("Ingrese una contraseña.");
		clearInput();
		$('#newpassword').focus();

	}else{
		if (claveUsuario != confirmeClave){
			alert("Las claves son distintas.\nIngreselas nuevamente.");
			clearInput();
			$('#newpassword').focus();
	
		}else{
			cambiarPassword(claveUsuario, confirmeClave);
			closeWindow();
		}
	}
}

$(document).ready(function() {
	
});

</script>

<!-- ************************************Window Cambiar Password***************************************** -->
<div id=window class="window" style="display:none; height:200px; width:500px;">
	<div class="windowBlur" style="display:none; height:204px; width:500px;"></div> <!-- end div blur -->
		<div id="headerWindow" class="headerWindow">
			<span class="click" onClick="closeWindow();">Cerrar</span>
		</div>

		<div id="title" class="title">Cambio de Contrase&ntilde;a</div>
		<div id="contentWindow" class="formElemets">
		<center>
		  <ul>
			<li>
				<b>Nueva Contrase&ntilde;a:</b>
			</li>
			<li>
				<input id=newpassword class="inputFontNormal" size=20 type=password>
	  		</li>
			<li>
				<b>Repetir Contrase&ntilde;a: </b>
			<li>
			</li>
				<input id=newpassword1  class="inputFontNormal" size=20 type=password>
			</li>	
			<li>
				<input type=button onClick="verificarClaveUsuario();" 
				value="Confirme contrase&ntilde;a" class="button">
			</li>
		  </ul>
		</center>
		</div> <!--end div id="contentWindow"-->
</div> <!-- end div window -->

<!-- *******************************Fin**Window Cambiar Password***************************************** -->


