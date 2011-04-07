[% INCLUDE "FormValidateHelper.inc" %]
[% INCLUDE  "AutocompleteHelper.inc"  %]


<script src="/opac-tmpl/includes/opac-searchFunciones.js" type="text/javascript"></script>
<script src="/opac-tmpl/includes/tabletojson.js" type="text/javascript"> </script>
<script src="/opac-tmpl/includes/opac-recomendaciones.js" type="text/javascript"></script>
<script src="/includes/jquery/modal/jquery.simplemodal.js" type="text/javascript"></script>
<script type="text/javascript">

function buscarDatosNivel2(){
        objAH                   = new AjaxHelper(updateBuscarDatosNivel2);
        objAH.debug             = true;
        objAH.showOverlay       = true;
        objAH.url               = '/cgi-bin/koha/opac-recomendacionesDB.pl';
        objAH.tipoAccion        = 'BUSQUEDA_RECOMENDACION';
        objAH.idCatalogoSearch  = $('#catalogo_search_hidden').val();
        objAH.sendToServer();
}

function traerImputsVacios(){
        objAH                   = new AjaxHelper(updateTraerImputsVacios);
        objAH.debug             = true;
        objAH.showOverlay       = true;
        objAH.url               = '/cgi-bin/koha/opac-recomendacionesDB.pl';
        objAH.tipoAccion        = 'BUSQUEDA_RECOMENDACION_SIN_RESULTADOS';
        objAH.sendToServer();
}


function updateTraerImputsVacios(responseText){
  $('#datos_edicion_seleccionada').html(responseText); 

}

function guardarRecomendacion(){
    $("#tabla_recomendacion").tabletojson({
            headers: "Autor,Titulo, Edicion, Lugar Publicacion, Editorial, Fecha, ISBN/ISSN, Nivel 2, Cantidad, Motivo, Comentario",
            attribHeaders: "{}",
            returnElement: "#table",
            complete: function(x){
                 objAH                     = new AjaxHelper(updateGuardarRecomendacion);
                 objAH.url                 = '/cgi-bin/koha/opac-recomendacionesAdd.pl';
                 objAH.debug               = true;
                 objAH.showOverlay         = true;
                 objAH.table               = JSONstring.toObject(x);
                 objAH.motivo_propuesta    = $('#motivo_propuesta').val();
                 objAH.comment             = $('#comment').val();
                 objAH.tipoAccion          = 'GUARDAR_RECOMENDACION';
                 objAH.sendToServer();
            }
        })
}

function updateGuardarRecomendacion(responseText){
  
   if (!verificarRespuesta(responseText)) {
            return(0);
            var Messages=JSONstring.toObject(responseText);
            setMessages(Messages);
   }
}


function updateBuscarDatosNivel2(responseText){
   $('#ediciones').html(responseText);

   $('#edicion_id').val('').attr("selected",true);
   $('#edicion_id').change( function(){    
              var edicion=this.options[this.selectedIndex].text
              cargarDatosEdicionSeleccionada(edicion)
   });
   if (!verificarRespuesta(responseText)) {
            return(0);
            var Messages=JSONstring.toObject(responseText);
            setMessages(Messages);
   }
}


function cargarDatosEdicionSeleccionada(edicion){
        objAH                   = new AjaxHelper(updateCargarDatosEdicionSeleccionada);
        objAH.debug             = true;
        objAH.showOverlay       = true;
        objAH.url               = '/cgi-bin/koha/opac-recomendacionesDB.pl';
        objAH.tipoAccion        = 'CARGAR_DATOS_EDICION';
        objAH.edicion_id        = $('#edicion_id').val();
        objAH.edicion           = edicion;
        objAH.idCatalogoSearch  = $('#catalogo_search_hidden').val();
        objAH.sendToServer();
}


function updateCargarDatosEdicionSeleccionada(responseText){
   $('#datos_edicion_seleccionada').html(responseText);    

//    if (!verificarRespuesta(responseText)) {
//             return(0);
//             var Messages=JSONstring.toObject(responseText);
//             setMessages(Messages);
//    }
}

function bloquearCampos(){
     $('#autor').attr('readonly', true); 
     $('#titulo').attr('readonly', true); 
     $('#edicion').attr('readonly', true); 
     $('#lugar_publicacion').attr('readonly', true); 
     $('#editorial').attr('readonly', true); 
     $('#isbn_issn').attr('readonly', true); 
     $('#fecha').attr('readonly', true); 



}

function verificarBusqueda(){
    if ($('#catalogo_search_hidden').val() != (-1)){
            $('#carga_manual').hide();
            buscarDatosNivel2();
            bloquearCampos();
            $('#ediciones').show();
    } else {
         
           traerImputsVacios();
           validateForm(agregarRenglon);
           $('#carga_manual').show();
           $('#ediciones').hide();
           
 
}

}

$(document).ready( function() {
    CrearAutocompleteCatalogo({ 
          IdInput: 'catalogo_search', 
          IdInputHidden: 'catalogo_search_hidden', 
          callBackFunction: verificarBusqueda,
    })
//     $('#carga_manual').click(function(){        
//               $('#datos_edicion').hide()
//     });
    $('#catalogo_search').blur(function(){        
              limpiarCampos()
    });
    $('#recomendacion').hide();
//     $('#carga_manual').hide();
    makeToggle('carga_manual','trigger',null,true);
 
// //     validateForm();   
});



</script>        
     

<div class="column1-unit">
  <!--    [% message %]-->
        
      <div class="recomendacionform">
              

              <input type="hidden" name="action" value="agregar">
           
              <fieldset> <legend class="titulo_legend trigger click">[% "Busqueda de Datos del Material" | i18n %]</legend>
                          <!-- <li class="item">-->
                                <p><label for="catalogo_search" class="left">[% 'Keyword:' | i18n %]</label>
                                <input type='text' id='catalogo_search' name='catalogo_search' value='' size=40 tabindex='3' style="float: left"></p>
                                <input type='hidden' id='catalogo_search_hidden' name='catalogo_search_hidden' value=''>
                         <!--   </li>  -->
                                
              </fieldset>
              <div id="ediciones"></div>
                  
              
              
              <div class="carga_manual" id="carga_manual"> 
                     [% PERL %]
                          print C4::AR::Filtros::setHelp(text => "[% 'No se han encontrado resultados para la busqueda realizada. Si lo desea, puede llenar los campos manualmente' | i18n %]",
                                        );   C4::AR::Debug::debug("Save Detalle");
                      [% END %]
                    <!--fieldset> <legend class="titulo_legend trigger click">[% "Carga manual de material" %]</legend>
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
                          <p><label for="motivo_propuesta" class="left">[% 'Motivo de la Propuesta' | i18n %]:</label>
                              <textarea name="motivo_propuesta" id="motivo_propuesta" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
                          <p><label for="comment" class="left">[% 'Comentarios' | i18n %]:</label>
                              <textarea name="comment" id="comment" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
                           <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>
                       <input type="hidden" name="post_message" id="post_message" value="1"/>
                 
                          <input type="button" onClick="agregarRenglon()" value="[% 'Agregar ejemplar' | i18n %]" tabindex="6" />     
                    </fieldset>-->
           </div>     
      
           <div id="datos_edicion_seleccionada"></div>
   
            <!--  [% PERL %]
                          print C4::AR::Filtros::setHelp(text => "[% 'Haga Click en el titulo para agregar un motivo o comentario' | i18n %]",
                                        );
              [% END %]-->
         <!--     <fieldset><legend class="titulo_legend trigger click">&nbsp;[% 'Motivo de la propuesta' | i18n %]&nbsp;</legend>
                <div class="motivo" id="motivo">
                     <textarea name="motivo_propuesta" id="motivo_propuesta" cols="45" class="required" rows="10" tabindex="17"></textarea>
                </div>
              </fieldset>
              <fieldset><legend class="titulo_legend trigger click">&nbsp;[% 'Comentarios' | i18n %]&nbsp;</legend>
                <div class="comentario" id="comentario">
                   <textarea name="comment" id="comment" cols="45" class="required" rows="10" tabindex="17"></textarea>-->
          <!--      <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>-->
          <!--         <input type="hidden" name="post_message" id="post_message" value="1"/>
                </div>
              </fieldset>-->
        
              <fieldset  id="recomendacion"><legend class="titulo_legend trigger click">&nbsp;[% 'Recomendacion' | i18n %]&nbsp;</legend>
                  <table id="tabla_recomendacion" name= "tabla_recomendacion" class="tabla_datos" cellspacing='0' cellpadding='0'>
                          <thead>    
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
                             <!-- <th align="center">
                                  [% "Colecci&oacute;n" | i18n %]
                              </th>-->
                              <th align="center">
                                  [% "ISBN/ISSN" | i18n %]
                              </th>
                              <th align="center">
                                  [% "Nivel 2" | i18n %]
                              </th>
                              <th align="center">
                                  [% "Cantidad de ejemplares" | i18n %]
                              </th>
                              <th align="center">
                                  [% "Motivo de la Propuesta" | i18n %]
                              </th>
                               <th align="center">
                                  [% "Comentarios" | i18n %]
                              </th>
                             
                        </thead>
                        <tbody>
                        </tbody>
                      </table>
                      <input type="button" onclick="guardarRecomendacion()" value="Enviar Recomendacion">
                </fieldset>
                  
      </div>         
</div>
        
