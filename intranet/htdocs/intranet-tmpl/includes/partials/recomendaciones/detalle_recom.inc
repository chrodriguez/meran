
      <legend class="titulo_legend trigger click">[% "Detalle" %]</legend>
      
      <ul>
             <li>[% "Fecha Publicacion: " | i18n %][% recomendacion.getFechaPublicacion %]</li>
             <li>[% "Lugar Publicacion: "| i18n %][%  recomendacion.getLugarPublicacion %]</li>         
             <li>      [% "Coleccion: " | i18n %][% recomendacion.getColeccion %]</li> 
             <li>     [% "ISBN/ISSN: " | i18n %]  [% recomendacion.getIsbnIssn %]</li> 
              <li>[% "Cantidad Ejemplares: " | i18n %][% recomendacion.getCantidadEjemplares %]</li> 
                  
                  <li>     [% "Motivo Propuesta: " | i18n %][% recomendacion.getMotivoPropuesta %]</li> 
                  
                       <li>[% "Comentario: " | i18n %][% recomendacion.getComentario %]</li> 
                  
                       <li>[% "Reserva Material: " | i18n %] [% recomendacion.getReservaMaterial %]</li> 
       </ul>          
