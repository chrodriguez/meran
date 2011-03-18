[% INCLUDE "FormValidateHelper.inc" %]


<script src="/opac-tmpl/includes/opac-searchFunciones.js" type="text/javascript"></script>
<script src="/opac-tmpl/includes/opac-recomendaciones.js" type="text/javascript"></script>
<script src="/includes/jquery/modal/jquery.simplemodal.js" type="text/javascript"></script>
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

function busquedaCombinable(){
    objAH                   = new AjaxHelper(updateBusquedaCombinable);
    objAH.debug             = true;
    objAH.showOverlay       = true;
    //para busquedas combinables
    objAH.url               = '/cgi-bin/koha/opac-busquedasDB.pl';
    objAH.string            = $('#string').val();
    objAH.only_available    = ( $('#only_available').attr('checked') )?1:0;
    objAH.tipoAccion        = 'BUSQUEDA_COMBINABLE_RECOMENDACION';
    objAH.token            = $('#token').val();
    //se setea la funcion para cambiar de pagina
    objAH.funcion           = 'changePage';
    // FIXME ver parametro ini
    //se envia la consulta
    objAH.sendToServer();
}

function updateBusquedaCombinable(responseText){
   $('#result_busqueda').html(responseText);
//    if (!verificarRespuesta(responseText)) {
//             return(0);
//             var Messages=JSONstring.toObject(responseText);
//             setMessages(Messages);
//    }
}


$(document).ready( function() {
//     CrearAutocompleteCatalogoBiblioteca({IdInput: 'buscar_biblioteca', 
//                                          IdInputHidden: 'hidden_completo'
//                                         });
 
    makeToggle('busqueda_combinable','trigger',null,true);
    makeToggle('carga_manual','trigger',null,true);
    makeToggle('motivo','trigger',null,true);
    makeToggle('comentario','trigger',null,true);
    validateForm();
});

</script>        
     

 <div class="column1-unit">
          <div class="recomendacionform">
<!--           <form id="contactform" name="contactform" method="get" action="/cgi-bin/koha/opac-recomendacionesAdd.pl"> -->
              <input type="hidden" name="action" value="agregar">
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
              
              <fieldset> <legend class="titulo_legend trigger click">[% "Busqueda de Datos del Material" | i18n %]</legend>
                      <div class="busqueda_combinable" id="busqueda_combinable">

                                    <p><label class="left" for="string">[% "B&uacute;squeda combinada" | i18n %]
                                    <!-- onkeypress="limpiarCampos('arriba')" -->
                                    <input id="string" name="string" class="field" type="text" size="25"></p>
                                    <p><label class="left" for="match_mode">Seleccione una forma de busqueda 
                                    [% PERL %]
                                                print C4::AR::Filtros::getComboMatchMode() ;
                                    [% END %]    
                                    </p> 
                                    <input type="button" onClick="busquedaCombinable()" value="[% 'Buscar' | i18n %]" tabindex="6" />
     
                      <!--<div id="hidden_nivel_2">
                          <p><label for="hidden_id_nivel_2" class="left">[% 'HIDDEN_ID_NIVEL_2' | i18n %]:</label></p>
                          <input type="text" name="hidden_completo" id="hidden_completo" class="field" value="" tabindex="7" />
                          <input type="text" name="hidden_id_nivel_2" id="hidden_id_nivel_2" class="field" value="" tabindex="7" />
                          <label for="hidden_id_nivel_2" class="left">[% '(puede no estar, dependiendo de si se elig&iacute;o un item de la bilbioteca o no)' | i18n %]:</label>
                      </div>-->
                      <div id="result_busqueda"></div>
             
              </fieldset>
             
            
              <fieldset><legend class="titulo_legend trigger click">&nbsp;[% 'Carga de Datos Manual' | i18n %]&nbsp;</legend>
                  <div class="carga_manual" id="carga_manual"> 
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
                    <p><label for="cant_ejemplares" class="left">[% 'Cantidad de Ejemplares*' | i18n %]:</label>
                      <input type="text" name="cant_ejemplares" id="cant_ejemplares" class="field" value="" tabindex="10" /></p>
                    <input type="button" onClick="agregarRenglon()" value="[% 'Agregar ejemplar' | i18n %]" tabindex="6" />
                 
                  </div>      
              </fieldset>
             
             
              <fieldset><legend class="titulo_legend trigger click">&nbsp;[% 'Motivo de la propuesta' | i18n %]&nbsp;</legend>
                <div class="motivo" id="motivo">
                     <textarea name="motivo_propuesta" id="motivo_propuesta" cols="45" class="required" rows="10" tabindex="17"></textarea>
                </div>
              </fieldset>
              <fieldset><legend class="titulo_legend trigger click">&nbsp;[% 'Comentarios' | i18n %]&nbsp;</legend>
                <div class="comentario" id="comentario">
                   <textarea name="comentarios" id="comentarios" cols="45" class="required" rows="10" tabindex="17"></textarea>
          <!--      <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>-->
                   <input type="hidden" name="post_message" id="post_message" value="1"/>
                </div>
              </fieldset>
            
              <table id="tabla_recomendacion" class="tabla_datos" cellspacing='0' cellpadding='0'>
                          <th align="center">
                              [% "Autor" | i18n %]
                          </th>
                          <th align="center">
                              [% "T&iacute;tulo" | i18n %]
                          </th>
                          <th align="center">
                              [% "Edici&oacute;n" | i18n %]
                          </th>
                          <th align="center">
                              [% "Lugar de publicaci&oacute;n" | i18n %]
                          </th>
                          <th align="center">
                              [% "Editorial" | i18n %]
                          </th>
                          <th align="center">
                              [% "Fecha" | i18n %]
                          </th>
                          <th align="center">
                              [% "Colecci&oacute;n" | i18n %]
                          </th>
                          <th align="center">
                              [% "ISBN/ISSN" | i18n %]
                          </th>
                          <th align="center">
                              [% "Fecha" | i18n %]
                          </th>
                          <th align="center">
                              [% "Cantidad de ejemplares" | i18n %]
                          </th>
               
                    <tbody>
                    </tbody>
                  </table>
            
                 
           
          </div>
          
</div>
        
