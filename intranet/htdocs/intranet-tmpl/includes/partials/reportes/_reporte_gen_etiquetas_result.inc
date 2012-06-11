<script type="text/javascript" src="/intranet-tmpl/includes/adquisiciones/tabletojson.js"> </script>
<script type="text/javascript" src="/includes/jquery/jquery.nanoscroller.js"></script>
    
<script>
function seleccionarTr(){
      $('[type=checkbox]').change( function (){ 

            if ($(this).is(':checked')){
                  id_tr = $(this).val();
                  id_tr = id_tr + "_tr";
                  id1= $(this).attr('id').substring(15);
                  $(this).attr('checked', false);
                  $('#' + id_tr).hide();
                  barcode= $('#barcode'+ $(this).val()).html();
                  $('#seleccionados').append(" <span class='label label-info' name='"+ id1  + "' id='label"+barcode+"'><input type='hidden' value='"+id_tr+"'>" +barcode+ " <span class='click' id='"+barcode+"'>X</span> </span> ");
              
                  

                  id_tabla= '#tablaResult'+ id1;

                  cant_visibles_tabla= $(id_tabla + ' tr:visible').length;
                 
                  if (cant_visibles_tabla <= 1){
                          $('#grupo' + id1).hide();
                  } else {
                          $('#grupo' + id1).show();
                  }

                  $('.click').click( function (){  
                   
                              labelClosed=$('#label'+ $(this).attr('id')).attr('name');
                              $('#grupo' + labelClosed).show();          
                              $('#' + $(this).parent().children(":input").val()).show();                    
                              $('#label'+ $(this).attr('id')).remove(); 
                                     
                  });
              }
            }
        );
    }


    function checkedAllTrs(id,nombreCheckbox){
              $("#"+id).toggle(
              function(){
                $("input[name="+nombreCheckbox+"]").each(
                    function(){
                      this.checked=true;
                      $(this).parent().parent().addClass("marked");$(this).parent().parent().children().each(
                        function(){
                            $(this).addClass("marked");
                        });
                    })
             
              },
              
              function(){ 
                    $("input[name="+nombreCheckbox+"]").each(function(){
                      this.checked=false;$(this).parent().parent().removeClass("marked");
                        $(this).parent().parent().children().each(function(){
                            $(this).removeClass("marked");
                        });
                    })
              });

    }
     $(document).ready(function() {
        seleccionarTr();
     });
</script>

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
                            seleccionarTr(); 
                            checkedAll("selectAll"+ "[% nivel1.id1 %]", "checkEjemplares"+"[% nivel1.id1 %]");
                           
                </script>
               
          [% END %]
    
</div>

 
