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
            objAH                   = new AjaxHelper(updateConfirmarAgregarAutorizado);
            objAH.url               = '[% url_prefix %]/usuarios/reales/usuariosRealesDB.pl';
            objAH.debug             = true;
            objAH.showOverlay       = true;
            objAH.nro_socio         = NRO_SOCIO_AUTH; 
            objAH.auth_nombre       = $('#nombreAutorizado').val();
            objAH.auth_dni          = $('#dniAutorizado').val();
            objAH.auth_telefono     = $('#telefonoAutorizado').val();
            objAH.tipoAccion        = 'AGREGAR_AUTORIZADO';
            objAH.sendToServer();
        }
    }

    function updateConfirmarAgregarAutorizado(responseText){
        var Messages = JSONstring.toObject(responseText);
        setMessages(Messages);
        detalleUsuario();
        $.modal.close();    
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
        <legend class="titulo_legend">[% ' Agregar Usuario Adicional' | i18n %]</legend>
            <form class="form-horizontal" onsumit="false;">
                   <div class="control-group">
                           <label class="control-label" for="nombreAutorizado">[% "Apellido y Nombres" | i18n %]</label>
                           <div class="controls">
                                    <input type="text" class="input focused" id="nombreAutorizado" name="nombreAutorizado" tabindex="1">
                            </div>
                   </div>

                   <div class="control-group">
                           <label class="control-label" for="dniAutorizado">[% "DNI" | i18n %]</label>
                           <div class="controls">
                                    <input type="text" class="input focused" id="dniAutorizado" name="dniAutorizado" tabindex="2">
                            </div>
                   </div>

                   <div class="control-group">
                           <label class="control-label" for="telefonoAutorizado">[% "Tel&eacute;fono (contacto seguro)" | i18n %]</label>
                           <div class="controls">
                                    <input type="text" class="input focused" id="telefonoAutorizado" name="telefonoAutorizado" tabindex="3">
                            </div>
                   </div>
                   <div class="form-actions">
                              [% PERL %]
                                  print C4::AR::Filtros::to_Button(      text    => "[% 'Aceptar' | i18n %]",
                                                                        boton   => "boton_buscar",
                                                                        onClick => "confirmarAgregarAutorizado();",
                                                                        title   => "[% 'Agregar Autorizado' | i18n %]",
                                                                        inline=> "1",
                                          ) ;
                              [% END %]
                    </div>
       
        </form>
      </section>
    </fieldset>
</div> <!--end div id="contentWindow"-->

<!-- *******************************Fin**Window Help********************************************* -->


