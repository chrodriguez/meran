[% INCLUDE "FormValidateHelper.inc" %]

<script type="text/javascript">

function validateForm(){
            $("#contactform").validate({
    
                errorElement: "em",
                errorClass: "error_adv",
                rules: {
                    apellido:   "required",
                    nombre:     "required",                 
                    mensaje:    "required",
                    email: {
                            required: true,
                            email: true
                    },
               },
               messages: {
                    apellido: POR_FAVOR_INGRESE_SU_APELLIDO,
                    nombre: POR_FAVOR_INGRESE_SU_NOMBRE,
                    mensaje: POR_FAVOR_INGRESE_SU_MENSAJE,
                    email: POR_FAVOR_INGRESE_UNA_DIR_DE_EMAIL_VALIDA,
               }
            });
}

$(document).ready( function() {
    validateForm();
});

</script>        
        <div class="column1-unit">
          <div class="contactform">
            <form id="contactform" name="contactform" method="get" action="[% url_prefix %]/opac-contact.pl">
              <fieldset><legend>&nbsp;[% 'Informaci&oacute;n de contacto' | i18n %]&nbsp;</legend>
                <p><label for="trato" class="left">[% 'Trato' | i18n %]:</label>
                   <select name="trato" id="trato" class="combo" tabindex="5">
                     <option value="choose"> [% 'Elija una opci&oacute;n' | i18n %]... </option>
                     <option value="Sr"> [% 'Sr.' | i18n %] </option>
                     <option value="Sra"> [% 'Sra.' | i18n %] </option>
                     <option value="Dr"> [% 'Dr.' | i18n %] </option></select></p>
                <p><label for="nombre" class="left">[% 'Nombre/s *' | i18n %]:</label>
                   <input type="text" name="nombre" id="nombre" class="field required" value="[% socio.persona.getNombre %]" tabindex="6" /></p>
                <p><label for="apellido" class="left">[% 'Apellido/s *' | i18n %]:</label>
                   <input type="text" name="apellido" id="apellido" class="field required" value="[% socio.persona.getApellido %]" tabindex="7" /></p>
                <p><label for="direccion" class="left">[% 'Direcci&oacute;n' | i18n %]:</label>
                   <input type="text" name="direccion" id="direccion" class="field" value="[% socio.persona.getCalle %]" tabindex="8" /></p>
                <p><label for="codigo_postal" class="left">[% 'C&oacute;digo Postal' | i18n %]:</label>
                   <input type="text" name="codigo_postal" id="codigo_postal" class="field" value="" tabindex="9" /></p>
                <p><label for="ciudad" class="left">[% 'Ciudad' | i18n %]:</label>
                   <input type="text" name="ciudad" id="ciudad" class="field" value="[% socio.persona.ciudad_ref.NOMBRE %]" tabindex="10" /></p>
                <p><label for="pais" class="left">[% 'Pa&iacute;s' | i18n %]:</label>
                   <input type="text" name="pais" id="pais" class="field" value="" tabindex="10" /></p>
                <p><label for="telefono" class="left">[% 'Tel&eacute;fono' | i18n %]:</label>
                   <input type="text" name="telefono" id="telefono" class="field" value="[% socio.persona.getTelefono %]" tabindex="12" /></p>
                <p><label for="email" class="left">[% 'E-mail *' | i18n %]:</label>
                   <input type="text" name="email" id="email" class="field required" value="[% socio.persona.getEmail %]" tabindex="13" /></p>
              </fieldset>
              <fieldset><legend>&nbsp;[% 'Inquietud de contacto' | i18n %]&nbsp;</legend>
                <p><label for="asunto" class="left">[% 'Asunto' | i18n %]:</label>
                   <input type="text" name="asunto" id="asunto" class="field" value="" tabindex="15" /></p>
                <p><label for="mensaje" class="left">[% 'Mensaje *' | i18n %]:</label>
                   <textarea name="mensaje" id="mensaje" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
                <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>
                   <input type="hidden" name="post_message" id="post_message" value="1"/>
              </fieldset>
            </form>
          </div>
        </div>
