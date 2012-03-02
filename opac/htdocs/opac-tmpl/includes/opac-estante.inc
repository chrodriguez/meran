[% IF estante %]
    <div id='listaEstantes'>
       <!-- <h2>-->
      <ul class="breadcrumb">
            <li>

			    [% auxEstante = estante %]
			    [% listaEstantes = [] %]
			    [% WHILE auxEstante > 0 %]
                      [% listaEstantes.unshift(auxEstante) %]
                      [% IF auxEstante.getPadre %]
                          [% auxEstante = auxEstante.estante_padre %]
                      [% ELSE %]
                          [% auxEstante = 0 %]
                      [% END %]
                [% END %]
                [% FOREACH auxEstante IN listaEstantes %]
                    [% PERL %]
				      print C4::AR::Filtros::link_to( text =>     "[% auxEstante.getEstante %]",
								      url=> '[% url_prefix %]/opac-estante.pl', 
								      params =>   ["id_estante=[% auxEstante.getId %]"],
								      title =>    "[% 'Mostrar Detalle del Estante' | i18n %]",
								      class => "link_to_detail"
								  ) ;
                    [% END %]
                     <span class="divider">/</span>  
                [% END %]
               
        </li>
     </div>
[% END %]
[% IF SUBESTANTES %]
      [% IF cant_subestantes > 0 %]
            <div id='subestantes'>
         
              <fieldset>
                  <section class="center-section-form"> 
                    <legend class="titulo_legend"><span class="titulos">[% 'Estantes' | i18n %]</span></legend>
                    <!-- ESTE LOOP MUESTRA LOS ESTANTES -->
                 
                    <dl>
                    [% FOREACH subestante IN SUBESTANTES %]
                       
                          <dd> 
                            [% PERL %]
                                print C4::AR::Filtros::link_to( text    =>  "[% subestante.getEstante %]",
                                                                url     =>  '[% url_prefix %]/opac-estante.pl',
                                                                params =>   ["id_estante=[% subestante.getId %]"],
                                                                title =>    "[% 'Mostrar Detalle del Estante' | i18n %]",
                                                                  class => "link_to_detail"
                                        ) ;
                            [% END %]
                          </dd>
                    
                    [% END %]
                    </dl>
                 
                  </section>
            </div>
      [% END %]
      [% ELSE %]
          <div class="alert alert-info">
                [% 'No se encontraron estantes virtuales.' | i18n %]
          </div>
      [% END %]

      [% IF estante %]
        [% IF estante.contenido %]
          <script type="text/javascript" language="javascript" src="/opac-tmpl/includes/tablesorter.js"></script>
          <script type="text/javascript" language="javascript">
          $(document).ready(function() 
              { 
                  $("#tablaResult").tablesorter(); 
                  // le sacamos la clase 'header' que el plugin le pone a los <th>
                  $('th').removeClass('header');
              }  
          ); 
        </script>


        <div id='contenido'>

               [% PERL %]
                      print C4::AR::Filtros::tableHeader(   
                                        id              => "tablaResult",
                                        class           => "",
                                        selectAll_id    => "",
                                        columns         => ['[% "T&iacute;tulo" | i18n %]',
                                                            '[% "Autor" | i18n %]','[% "Lugar" | i18n %]',
                                                            '[% "Edic&iacute;on" | i18n %]'
                                                            ]
                                                                        
                                              ) ;
               [% END %]

                 <tbody>
                      [% FOREACH contenido_estante IN estante.contenido %]
                          <tr>
                              <td>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% contenido_estante.nivel2.nivel1.getTitulo %]",
                                                                      url =>      "[% url_prefix %]/opac-detail.pl", 
                                                                      params =>   ["id1=[% contenido_estante.nivel2.id1 %]"],
                                                                      title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                                  ) ;
                                  [% END %]
                              </td>
                              <td>
                                  [% PERL %]
                                      print C4::AR::Filtros::link_to( text =>     "[% contenido_estante.nivel2.nivel1.getAutor %]",
                                                                      url =>      "[% url_prefix %]/opac-busquedasDB.pl", 
                                                                      params =>   ["tipoAccion=BUSQUEDA_AVANZADA","autor=[% contenido_estante.nivel2.nivel1.getAutor %]"],
                                                                      title =>    "[% 'Buscar de este autor' | i18n %]"
                                                                  ) ;
                                  [% END %]                                
                              </td>
                              <td>
                                  [% contenido_estante.nivel2.getCiudadObject.getNombre %]
                              </td>
                              <td>
                                  [% IF contenido_estante.nivel2.getEdicion %]
                                            [% contenido_estante.nivel2.getEdicion %] &nbsp;
                                  [% END %]
                                  [% IF contenido_estante.nivel2.getAnio_publicacion %]
                                            ([% contenido_estante.nivel2.getAnio_publicacion %])
                                  [% END %]
                              </td>
                          </tr>
                      [% END %]
                 </tbody>
             </table>
        </div>
        [% END %]
      [% END %]
