[% INCLUDE "FormValidateHelper.inc" %]

[% INCLUDE 'AutocompleteHelper.inc'  %]


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
                    profesor_departamento: POR_FAVOR_INGRESE_DEPARTAMENTO  
               }
            });
}

$(document).ready( function() {
    CrearAutocompleteCatalogoBiblioteca({IdInput: 'buscar_biblioteca', 
                                         IdInputHidden: 'hidden_id_nivel_2',
                                         IdInputAutor: 'autor'
                                        });
    validateForm();
});



</script>        

        <div class="column1-unit">
          <div class="contactform">
            <form id="contactform" name="contactform" method="get" action="/cgi-bin/koha/opac-recomendaciones.pl">
              <fieldset><legend>&nbsp;[% 'Informaci&oacute;n de contacto' | i18n %]&nbsp;</legend>
                <p><label for="nombre" class="left">[% 'Nombre y Apellido *' | i18n %]:</label>
                   <input type="text" name="nombre" id="nombre" class="field required" value="[% socio.persona.getNombre %] [% socio.persona.getApellido %]" tabindex="1" /></p>
                <p><label for="email" class="left">[% 'E-mail *' | i18n %]:</label>
                   <input type="text" name="email" id="email" class="field required" value="[% socio.persona.getEmail %]" tabindex="2" /></p>
                <p><label for="profesor-departamento" class="left">[% 'Profesor Indicar Departamento *' | i18n %]:</label>
                   <input type="text" name="dpto_id" id="dpto_id" class="field required" value="" tabindex="3" /></p>
                <p><label for="direccion" class="left">[% 'Servicio Indicar Departamento *' | i18n %]:</label>
                   <input type="text" name="servicio-departamento" id="servicio-departamento" class="field required" value="" tabindex="4" /></p>
                <p><label for="reservar" class="left">[% 'Reservar' | i18n %]:</label>
                   <input type="checkbox" name="reservar" id="reservar" class="field" value="" tabindex="5" /></p>
              </fieldset>
              <fieldset><legend>&nbsp;[% 'Datos del Material' | i18n %]&nbsp;</legend>
                <p><label for="buscar_biblioteca" class="left">[% 'Buscar en la Biblioteca' | i18n %]:</label>
                   <input type="text" name="buscar_biblioteca" id="buscar_biblioteca" class="field" value="" tabindex="6" /></p>
                <p><label for="hidden_id_nivel_2" class="left">[% 'HIDDEN_ID_NIVEL_2' | i18n %]:</label>
                   <input type="text" name="hidden_id_nivel_2" id="hidden_id_nivel_2" class="field" value="" tabindex="7" />
                   <label for="hidden_id_nivel_2" class="left">[% '(puede no estar, dependiendo de si se elig&iacute;o un item de la bilbioteca o no)' | i18n %]:</label></p>
                <p><label for="autor" class="left">[% 'Autor*' | i18n %]:</label>
                   <input type="text" name="autor" id="autor" class="field" value="" tabindex="10" /></p>
                <p><label for="titulo" class="left">[% 'T&iacute;tulo*' | i18n %]:</label>
                   <input type="text" name="titulo" id="titulo" class="field" value="" tabindex="10" /></p>
                <p><label for="edicion" class="left">[% 'Edici&oacute;n*' | i18n %]:</label>
                   <input type="text" name="edicion" id="edicion" class="field" value="" tabindex="10" /></p>
                <p><label for="lugar_publicacion" class="left">[% 'Lugar de Publicaci&oacute;n*' | i18n %]:</label>
                   <input type="text" name="lugar_publicacion" id="lugar_publicacion" class="field" value="" tabindex="10" /></p>
                <p><label for="editorial" class="left">[% 'Editorial*' | i18n %]:</label>
                   <input type="text" name="editorial" id="editorial" class="field" value="" tabindex="10" /></p>
                <p><label for="fecha" class="left">[% 'Fecha*' | i18n %]:</label>
                   <input type="text" name="fecha" id="fecha" class="field" value="" tabindex="10" /></p>
                <p><label for="coleccion" class="left">[% 'Colecci&oacute;n*' | i18n %]:</label>
                   <input type="text" name="coleccion" id="coleccion" class="field" value="" tabindex="10" /></p>
                <p><label for="isbn_issn" class="left">[% 'ISBN/ISSN*' | i18n %]:</label>
                   <input type="text" name="isbn_issn" id="isbn_issn" class="field" value="" tabindex="10" /></p>
                <p><label for="cantidad_ejemplares" class="left">[% 'Cantidad de Ejemplares*' | i18n %]:</label>
                   <input type="text" name="cantidad_ejemplares" id="cantidad_ejemplares" class="field" value="" tabindex="10" /></p>
              </fieldset>
              <fieldset><legend>&nbsp;[% 'Motivo de la propuesta' | i18n %]&nbsp;</legend>
                <p>
                   <textarea name="mensaje" id="mensaje" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
              </fieldset>
              <fieldset><legend>&nbsp;[% 'Comentarios' | i18n %]&nbsp;</legend>
                <p>
                   <textarea name="mensaje" id="mensaje" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
                <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>
                   <input type="hidden" name="post_message" id="post_message" value="1"/>
              </fieldset>
            </form>
          </div>
        </div>
