[% INCLUDE   'opac-top.inc'  %]

[% INCLUDE   'ChangePasswordHelper.inc'  %]

<script type="text/javascript">

function objeto_usuario(){
    this.text;
    this.ID;
}


     //muestra los ejemplares del grupo
function guardarCambiarPassword(){

    var key= b64_sha256(b64_md5($('#actualpassword').val()));

    document.datosAEnviar.actual_password.value = encriptar($('#actualpassword').val(), key);
    document.datosAEnviar.new_password1.value = encriptar($('#newpassword1').val(), key);
    document.datosAEnviar.new_password2.value = encriptar($('#newpassword2').val(), key);
    document.datosAEnviar.usuario.value = usuario.ID;
    document.datosAEnviar.changePassword.value = 1;
    document.datosAEnviar.submit();
}

function updateGuardarCambiarPassword(responseText){
    var Messages= JSONstring.toObject(responseText);
    setMessages(Messages);
}

$(document).ready(function() {
    
    usuario= new objeto_usuario();
    usuario.text= "[% completo %]";
    usuario.ID= "[% nro_socio %]";

});

</script>

<form action='[% url_prefix %]/change_passwordDB.pl' method="post" name="datosAEnviar">
        <input type="hidden" name="new_password1">
        <input type="hidden" name="new_password2">
        <input type="hidden" name="usuario">
        <input type="hidden" name="changePassword">
        <input type="hidden" name="actual_password">
        <input type="hidden" name="token" value="[% token %]">
</form>

<div class="titulos">[% 'Cambio de contrase&ntilde;a obligatorio' | i18n %]

<div class='tableMsgUser'>
    <font class='fontMsgUser'>
        <b>
            <div id='mensajes'>
                [% mensaje %]
            </div>
        </b>
    </font>
</div>

<table border="0" cellpadding="0" cellspacing="0" width="60%">
    <tr><td align="center" valign="middle">

    <table border="0"  cellpadding="0" cellspacing="0">
    <tr>
        <td> <b>Contrase&ntilde;a Actual:</b></td>
            <td><input type="password" name="actualpassword" id="actualpassword"></td>
    </tr>


	<tr>
		<td> <b>Nueva Contrase&ntilde;a:</b></td>
	     	<td><input type="password" name="newpassword1" id="newpassword1"></td>
    </tr>
	
	<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
	<tr>
        <td><b>Repetir Contrase&ntilde;a:&nbsp;</b></td>
        <td><input type="password" name="newpassword2"  id="newpassword2"></td>
    </tr>
	<tr><td>&nbsp;</td><td>&nbsp;</td></tr>
	<tr><td colspan="2" align="center"><input type="button" value="Entrar" onClick="guardarCambiarPassword()"></td></tr>
    </table>
    </td></tr>
</table>


[% INCLUDE 'opac-bottom.inc' %]

