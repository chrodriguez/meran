<fieldset> <legend class="titulo_legend trigger click">[% "Datos del material" %]</legend>
         
        <div class="datos_edicion" id="datos_edicion"> 
               
                  <p><label for="autor" class="left">[% 'Autor*' | i18n %]:</label>
                            <input type="text" name="autor" id="autor" class="field" value="[% datos_nivel1.getAutor %]" tabindex="10" /></p>
                  <p><label for="titulo" class="left">[% 'T&iacute;tulo*' | i18n %]:</label>
                            <input type="text" name="titulo" id="titulo" class="field" value="[% datos_nivel1.getTitulo %]" tabindex="10" /></p>
                   <p><label for="edicion" class="left">[% 'Edici&oacute;n*' | i18n %]:</label>
                            <input type="text" name="edicion" id="edicion" class="field" value="[% edicion %]" tabindex="10" /></p>
                  <p><label for="lugar_publicacion_" class="left">[% 'Lugar de Publicaci&oacute;n*' | i18n %]:</label>
                            <input type="text" name="lugar_publicacion" id="lugar_publicacion" class="field" value="[% datos_edicion.getCiudadPublicacion %]" tabindex="10"/></p>     
                  <p><label for="editorial" class="left">[% 'Editorial*' | i18n %]:</label>
                            <input type="text" name="editorial" id="editorial" class="field" value="[% datos_edicion.getEditor %]" tabindex="10" /></p>
                  <p><label for="fecha" class="left">[% 'Fecha*' | i18n %]:</label>
                            <input type="text" name="fecha" id="fecha" class="field" value="[% datos_edicion.getAnio_publicacion %]" tabindex="10" /></p>
                 <!-- <p><label for="coleccion" class="left">[% 'Colecci&oacute;n*' | i18n %]:</label>
                      <input type="text" name="coleccion" id="coleccion" class="field" value="" tabindex="10" READONL/></p>-->
                  <p><label for="isbn_issn" class="left">[% 'ISBN/ISSN' | i18n %]:</label>
                    [% IF datos_edicion.getISBN %]
                            <input type="text" name="isbn_issn" id="isbn_issn" class="field" value="[% datos_edicion.getISBN %]" tabindex="10" /></p>
                    [% ELSE %]
                            <input type="text" name="isbn_issn" id="isbn_issn" class="field" value="[% datos_edicion.getISSN %]" tabindex="10" /></p>
                    [% END %]
                  <p><label for="cant_ejemplares" class="left">[% 'Cantidad de Ejemplares*' | i18n %]:</label>
                            <input type="text" name="cant_ejemplares" id="cant_ejemplares" class="field" value="" tabindex="10" /></p>
                 
                  <p><label for="motivo_propuesta" class="left">[% 'Motivo de la Propuesta' | i18n %]:</label>
                     <textarea name="motivo_propuesta" id="motivo_propuesta" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
                  <p><label for="comment" class="left">[% 'Comentarios' | i18n %]:</label>
                     <textarea name="comment" id="comment" cols="45" class="required" rows="10" tabindex="17"></textarea></p>
          <!--          <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Enviar Mensaje' | i18n %]" tabindex="18" /></p>-->
                        <input type="hidden" name="post_message" id="post_message" value="1"/>
                 
            
                  <p><input type="button" onClick="agregarRenglon()" value="[% 'Agregar ejemplar' | i18n %]" tabindex="6" /> </p>  
 
                  [% PERL %]
                          print C4::AR::Filtros::setHelp(text => "[% 'Los campos marcados con * son obligatorios' | i18n %]",
                                        );
                  [% END %]
        </div>  
</fieldset>