<script type="text/javascript" src="/intranet-tmpl/includes/reports.js"></script>
<script type="text/javascript" src="/intranet-tmpl/includes/busquedasCatalogo-min.js"></script>
<script>

    function busqueda(){

        objAH_search                   = new AjaxHelper(updateBusqueda);
        objAH_search.debug             = true;
        objAH_search.showOverlay       = true;
        //para busquedas combinables
        objAH_search.url               = URL_PREFIX+'/reports/catalogoDB.pl';
        objAH_search.titulo            = $('#titulo').val();
        objAH_search.autor             = $('#autor').val();
        objAH_search.codBarra          = $('#codBarra').val();
        //  objAH_search.asc                = ASC;
        objAH_search.tipoAccion        = 'REPORTE_GEN_ETIQUETAS';
        //  se setea la funcion para cambiar de pagina
        objAH_search.funcion           = 'changePage_search';
        //  se envia la consulta
        objAH_search.sendToServer();
    }

    function updateBusqueda(responseText){
         $('#report_result_gen_etiquetas').html(responseText);
         $('#report_result_gen_etiquetas').show();

        
        $('[type=checkbox]').change( function (){ 
                                            if ($(this).is(':checked')){
                                                  id_tr = $(this).val();
                                                  id_tr = id_tr + "_tr";
                                                  id1= $(this).attr('id').substring(15);
                                                  $(this).attr('checked', false);
                                                  $('#' + id_tr).hide();
                                                  barcode= $('#barcode'+ $(this).val()).html();
                                                  $('#seleccionados').append(" <span class='label label-info' name='"+ id1  + "' id='label"+barcode+"'>" +barcode+ " <span class='click' id='"+barcode+"'>X</span> </span> ");
                                              
                                                  

                                                  id_tabla= '#tablaResult'+ id1;

                                                  cant_visibles_tabla= $(id_tabla + ' tr:visible').length;
                                                 
                                                  if (cant_visibles_tabla <= 1){
                                                          $('#grupo' + id1).hide();
                                                  } else {
                                                          $('#grupo' + id1).show();
                                                  }
    
                                                  $('.click').click( function (){
                                                              $('#label'+ $(this).attr('id')).remove(); 
                                                              $('#' + id_tr).show(); 
//                                                                 alert('#grupo' + $('#label'+ $(this).attr('id')).attr('name'));
//                                                               $('#grupo' +  $('#label'+ $(this).attr('id')).attr('name')).show();
                                                          
                                                  });
                                              }
                                            }
                                        );
  
      

    }

    function generarReporteGenEtiquetas(){

          var limite_caracteres   = 3; //tiene q ser == a lo configurado en sphinx.conf
          var cumple_limite       = true;
          var cumple_vacio        = true;

          
          //primero verifico las busquedas individuales
//           if (doScroll)
//               shouldScroll = doScroll;

          if (  (jQuery.trim($('#titulo').val()) != '') ||
                (jQuery.trim($('#autor').val()) != '') ||
                (jQuery.trim($('#codBarra').val()) != '')
             ){ 
                busqueda();
              }

//           if (!cumple_limite) {
//               jAlert(INGRESE_AL_MENOS_TRES_CARACTERES_PARA_REALIZAR_LA_BUSQUEDA);
//           } else if (!cumple_vacio) {
//               jAlert(INGRESE_DATOS_PARA_LA_BUSQUEDA)
//           }

      
    }
      
</script>

<div class="center_fieldset report_form_container">
      <form class="form-horizontal" id="form_reporte_gen_etiquetas" onsubmit="false">
                <div class="control-group">
                        <label class="control-label" for="titulo"> 
                            [% "T&iacute;tulo" %]
                        </label>
                        <div class="controls"> 
                            <input type="text"  size="25" id="titulo">
                        </div>
                </div>
                        
                <div class="control-group">
                        <label class="control-label" for="autor">
                            [% "Autor" %]
                        </label>
                        <div class="controls">
                          <input type="text" size="25" id="autor">
                        </div>
                </div>

                <div class="control-group">
                    <label class="control-label" for="codBarra">
                        [% "C&oacute;digo de barras" | i18n %]
                    </label>
                    <div class="controls">
                        <input type="text" size="25" id="codBarra">
                    </div>
                </div>
          
                <div class="form-actions">
                  [% PERL %]
                        print C4::AR::Filtros::action_button( 
                                                        button       => "btn btn-primary",
                                                        action       => "generarReporteGenEtiquetas()", 
                                                        icon         => "",
                                                        title        => "Generar Reporte",
                                                    ) ;
                  [% END %]
                </div>
      </form>
 </div>
 
<div id="report_result_gen_etiquetas" style="display:none;"></div>