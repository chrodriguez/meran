[% INCLUDE   'ChangePasswordHelper.inc'  %]

<script type="text/javascript">

function objeto_usuario(){
    this.text;
    this.ID;
}


     //muestra los ejemplares del grupo
function guardarCambiarPassword(){

    var changed = $.trim($('#actualpassword').val());
    if (changed != ''){
        [% IF plainPassword == 0 %]
            var nroRandom   = [% nroRandom %];
            var hash_actual = b64_sha256(b64_sha256(b64_md5($("#actualpassword").val()))+nroRandom);
            var key         = b64_sha256(b64_md5($("#actualpassword").val()));
            var hash_new1   = encriptar(b64_md5($("#newpassword1").val()),key);
            var hash_new2   = encriptar(b64_md5($("#newpassword2").val()),key);

            $("#actual_password").val(hash_actual);
            $('#new_password1').val(hash_new1);
            $('#new_password2').val(hash_new2);
        [% ELSE %]
            var hash_actual = $("#actualpassword").val();
	        var hash_new1   = $("#newpassword1").val();
	        var hash_new2   = $("#newpassword2").val();

            $("#actual_password").val(hash_actual);
            $('#new_password1').val(hash_new1);
            $('#new_password2').val(hash_new2);
        [% END %]
        $("#datosAEnviar").submit();
        return true;
     }          
  
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
<form action='[% url_prefix %]/change_passwordDB.pl?token=[% token %]' method="post" name="datosAEnviar" id="datosAEnviar">
        <input type="hidden" name="new_password1" id="new_password1">
        <input type="hidden" name="new_password2" id="new_password2">
        <input type="hidden" value="[% nro_socio %]" name="usuario" id="usuario">
        <input type="hidden" name="changePassword" id="changePassword">
        <input type="hidden" name="actual_password" id="actual_password">
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
        <input type="password" name="" id="actualpassword"></p>
        <p><label for="pass" class="left">Nueva Contrase&ntilde;a:&nbsp;</label>
        <input type="password" name="" id="newpassword1"></p>
        <p><label for="pass" class="left">Repetir Contrase&ntilde;a:&nbsp;</label>
        <input type="password" name=""  id="newpassword2"></p>
	    <p><input type="button" value="Aceptar" onClick="guardarCambiarPassword()"></p>
</fieldset>
</div>
