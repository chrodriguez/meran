<!-- *********************************Window Help********************************************* -->
<script>
    /*
    @params
    se le debe asigna el nro de socio a nro_socio_auth
    */
    var objAH;//Objeto AjaxHelper.

    function verificarDatos(){
        if($('#nombreAutorizado').val() == ''){
            $('#nombreAutorizado').focus();
            jAlert(FALTA_INGRESAR_EL_NOMBRE_DEL_AUTORIZADO);
            return 0;
        }
        if($('#dniAutorizado').val() == ''){
            $('#dniAutorizado').focus();
            jAlert(FALTA_INGRESAR_EL_DNI_DEL_AUTORIZADO);
            return 0;
        }
        if($('#telefonoAutorizado').val() == ''){
            $('#telefonoAutorizado').focus();
            jAlert(FALTA_INGRESAR_EL_TELEFONO_DEL_AUTORIZADO);
            return 0;
        }
        return 1;
    }

    function confirmarAgregarAutorizado(){

        if (verificarDatos()){
            objAH=new AjaxHelper(updateConfirmarAgregarAutorizado);
            objAH.url='/cgi-bin/koha/usuarios/reales/usuariosRealesDB.pl';
            objAH.debug= true;
            objAH.nro_socio= NRO_SOCIO_AUTH; 
            objAH.auth_nombre = $('#nombreAutorizado').val();
            objAH.auth_dni = $('#dniAutorizado').val();
            objAH.auth_telefono = $('#telefonoAutorizado').val();
            objAH.tipoAccion= 'AGREGAR_AUTORIZADO';
            objAH.sendToServer();
        }
    }

    function updateConfirmarAgregarAutorizado(responseText){
        var Messages=JSONstring.toObject(responseText);
        setMessages(Messages);
        vAgregarAutorizado.close();
        detalleUsuario();
    }

    /*
    * object_usuario
    * Representa al objeto que contendra la informacion del usuario seleccionado del autocomplete.
    */
    function object_usuario(){
        this.text;
        this.ID;
    }

</script>

<div id="contentWindow" class="formElemets">
    <fieldset>
        <legend class="titulo_legend">[% 'Agregar Autorizado' | i18n %]</legend>
        <br>
        <ul>
            <li class="sub_item">
                <label for="nombreAutorizado" style="float: left;" >[% "Ingrese Apellido y Nombres" | i18n %]</label>
                <input 	type="text" id="nombreAutorizado" name="nombreAutorizado" style="width:40%;" tabindex="1">
            </li>
            <li class="sub_item">
                <label for="dniAutorizado" style="float: left;" >[% "Ingrese el DNI" | i18n %]</label>
                <input  type="text" id="dniAutorizado" name="dniAutorizado" style="width:40%;" tabindex="2">
            </li>
            <li class="sub_item">
                <label for="telefonoAutorizado" style="float: left;" >[% "Ingrese un tel&eacute;fono (contacto seguro)" | i18n %]</label>
                <input  type="text" id="telefonoAutorizado" name="telefonoAutorizado" style="width:40%;" tabindex="3">
            </li>
            <li class="sub_item">
                [% PERL %]
                        print C4::AR::Filtros::to_Button(      text    => "[% 'Aceptar' | i18n %]",
                                                                boton   => "boton_buscar",
                                                                onClick => "confirmarAgregarAutorizado();",
                                                                title   => "[% 'Agregar Autorizado' | i18n %]",
                                ) ;
                [% END %]
            </li>
      </ul>
    </fieldset>
</div> <!--end div id="contentWindow"-->

<!-- *******************************Fin**Window Help********************************************* -->

