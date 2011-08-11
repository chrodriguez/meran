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
<form action='[% url_prefix %]/change_passwordDB.pl?token=[% token %]' method="post" name="datosAEnviar">
        <input type="hidden" name="new_password1">
        <input type="hidden" name="new_password2">
        <input type="hidden" name="usuario">
        <input type="hidden" name="changePassword">
        <input type="hidden" name="actual_password">
        <input type="hidden" name="token" value="[% token %]">
</form>

<div class="contactform" style="width: 50%">

<div class='tableMsgUser'>
    <font class='fontMsgUser'>
        <b>
            <div id='mensajes'>
                [% mensaje %]
            </div>
        </b>
    </font>
</div>
<fieldset>
    <legend>
        &nbsp;
        <span id="name_card">
            [% 'Cambio de contrase&ntilde;a obligatorio' | i18n %]
        </span>
        &nbsp;
    </legend>
        <p><label for="pass" class="left">Contrase&ntilde;a Actual:&nbsp;</label>
        <input type="password" name="actualpassword" id="actualpassword"></p>
        <p><label for="pass" class="left">Nueva Contrase&ntilde;a:&nbsp;</label>
        <input type="password" name="newpassword1" id="newpassword1"></p>
        <p><label for="pass" class="left">Repetir Contrase&ntilde;a:&nbsp;</label>
        <input type="password" name="newpassword2"  id="newpassword2"></p>
	    <p><input type="button" value="Aceptar" onClick="guardarCambiarPassword()"></p>
</fieldset>
</div>
