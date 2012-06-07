<script type="text/javascript" src="/intranet-tmpl/includes/adquisiciones/tabletojson.js"> </script>
<script type="text/javascript" src="/includes/jquery/jquery.nanoscroller.js"></script>
    


 <div class="alert alert-info" id="seleccionados">
</div>



[% IF cantidad %]
      <div class="well">
                    <!--<div class="resultados_consulta">[% "Ha buscado por" | i18n %]: <strong>[% HTML.escape(socio_busqueda) %]</strong></div> -->
              <div class="resultados_consulta">[% "La cantidad de resultados es" | i18n %]: <strong>[% cantidad %]</strong></div>
                      
      </div>
[% END %]

<div>        
          [% FOREACH SEARCH_RESULTS %]
          <div id="grupo[% nivel1.id1 %]">  
                    <div class="page-header">
                          <h3>[% nivel1.titulo %] <small> ([% nivel1.nomCompleto %]) </small> </h3>
                    </div>                             
                    [% PERL %]
                          print C4::AR::Filtros::tableHeader(   
                                            id              => "tablaResult[% nivel1.id1 %]",
                                            class           => "",
                                            selectAll_id    => "selectAll[% nivel1.id1 %]",
                                            columns         => ['[% "Codigo de Barra" | i18n %]','[% 'Signatura' | i18n %]',
                                                                '[% "Estado" | i18n %]'               
                                                                ],
                                            order           => {  'Codigo de Barra' =>'barcode', 
                                                                  'Signatura' => 'signatura',
                                                                  'Estado' => '', 
                                                                },
                                            order_name_function => "reporte_gen_etiquetas",
                                            ) ;
                      [% END %]
                      <tbody>
                                 [% FOREACH n3 IN nivel3 %]
                                      <tr id="[% n3.id %]_tr">
                                              <td><label class="checkbox">
                                                      <input type="checkbox" value="[% n3.id %]" id="checkEjemplares[% nivel1.id1 %]" name="checkEjemplares[% nivel1.id1 %]">
                                                  </label>
                                              </td> 
                                              <td id="signatura[% n3.id %]">[% n3.signatura %]</td> 
                                              <td id="barcode[% n3.id %]">[% n3.getBarcode %]</td> 
                                              <td id="estado[% n3.id %]">[% n3.getEstadoObject.getNombre %]</td> 
                                      </tr>
                                      
                               [% END %]

                        </tbody>
                    </table>
                  </div>  
                <script type="text/javascript">
                      checkedAll("selectAll"+ "[% nivel1.id1 %]", "checkEjemplares"+"[% nivel1.id1 %]");
                </script>
               
          [% END %]
    
</div>

 
