<!-- *********************************Window Help********************************************* -->
<script>

function confirmarAgregarAutorizado(nro_socio){

    objAH=new AjaxHelper(updateConfirmarAgregarAutorizado);
    objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
    objAH.debug= true;
    objAH.nro_socio= nro_socio_auth; 
    objAH.nombre_apellido = $('#nombreAutorizado').val();
    objAH.dni_autorizado = $('#dniAutorizado').val();
    objAH.telefono = $('#telefonoAutorizado').val();
    objAH.tipoAccion= 'AGREGAR_AUTORIZADO';
    objAH.sendToServer();

}

function updateConfirmarAgregarAutorizado(responseText){
    var Messages=JSONstring.toObject(responseText);
    setMessages(Messages);
    vAgregarAutorizado.close();
    detalleUsuario();
}

var objAH;//Objeto AjaxHelper.

/*
 * object_usuario
 * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
 */
function object_usuario(){
	this.text;
	this.ID;
}




$(document).ready(function() {
	
});

</script>

<div id="contentWindow" class="formElemets">
	<ul>
	<li>
		<label for="nombreAutorizado" style="float: left;" >
		    <b>Ingrese Apellido y Nombres</b>
		</label>

       
		<input 	type="text" id="nombreAutorizado"
				name="nombreAutorizado" style="width:40%;" tabindex="1">

        <label for="dniAutorizado" style="float: left;" >
            <b>Ingrese el DNI</b>
        </label>

        <input  type="text" id="dniAutorizado" 
                name="dniAutorizado" style="width:40%;" tabindex="2">

        <label for="telefonoAutorizado" style="float: left;" >
            <b>Ingrese un tel&eacute;fono (contacto seguro)</b>
        </label>

        <br>

        <input  type="text" id="telefonoAutorizado" 
                name="telefonoAutorizado" style="width:40%;" tabindex="3">

	</li>

	<li>
		<input type="button" value="Aceptar" onClick="confirmarAgregarAutorizado()">
	</li>
	</ul>
</div> <!--end div id="contentWindow"-->

<!-- *******************************Fin**Window Help********************************************* -->


