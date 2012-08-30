<script type="text/javascript" src="/intranet-tmpl/includes/reports.js"></script>
<script>

    var ORDEN   = '';
    var ASC     = 1;

    function changePageBusquedas(ini){
        objAH.changePage(ini);
    }

    function ordenar_reporte_circ(orden){

        if (orden == ORDEN) {
          ASC= !ASC;
        }

        ORDEN = orden;
        generarReporteCirculacion();
    }

    function generarReporteCirculacionGeneral(){

        objAH                   = new AjaxHelper(updateGenerarReporteCirculacionGeneral);
        objAH.debug             = true;
        objAH.cache             = true;
        objAH.showOverlay       = true;
        objAH.url               = URL_PREFIX+'/reports/circulacionDB.pl';
        objAH.tipoAccion        = "CIRC_GENERAL";
        objAH.funcion           = "changePageBusquedas";
        objAH.categoriaSocio    = $('#categoria_socio_id').val();
        // objAH.tipoOperacion     = $('#tipoOperacion').val();
        objAH.tipoPrestamo      = $('#tipo_prestamo_id').val();
        objAH.fecha_inicio      = $('#date-from').val();
        objAH.fecha_fin         = $('#date-to').val();
        objAH.statistics        = $('#statistics_check').val();
        objAH.orden             = ORDEN;
        objAH.asc               = ASC;
        objAH.sendToServer();
    }

    function updateGenerarReporteCirculacionGeneral(responseText){
        $('#reportResultCirc').html(responseText);
        $('#reportResultCirc').show();
        if (ORDEN){
              cambiarSentidoOrd();
        } 

    }   

    $(document).ready(function(){
        $('#date-from').datepicker();
        $('#date-to').datepicker();
    });

</script>

<div class="center_fieldset report_form_container">
    <form class="form-horizontal" onsubmit="return false;">

        <!-- <div class="control-group" >
            <label for="tipoOperacion" class="control-label">[% 'Tipo de operaci&oacute;n' | i18n %]</label>  
            <div class="controls">
                <select name="tipoOperacion" id="tipoOperacion">
                    <option value="">SIN SELECCIONAR</option>
                    <option value="prestamo">Pr&eacute;stamo</option>
                    <option value="renovacion">Renovaci&oacute;n</option>
                    <option value="devolucion">Devoluci&oacute;n</option>
                </select>
            </div>
        </div>
 -->
        <div class="control-group" id="divComboTipoPrestamo">
            <label for="tipo_prestamo_id" class="control-label">[% 'Tipo de pr&eacute;stamo' | i18n %]</label>  
            <div class="controls">
                [% comboDeTipoPrestamos %]
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="categoria_socio_id">[% 'Categor&iacute;a del usuario' | i18n %]</label>
            <div class="controls">  
                [% comboDeCategorias %]          
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"> [% "Rango de Fechas" | i18n %] </label>
            <div class="controls">
                <input type="text" id="date-from" name="date-from" data-datepicker="datepicker" placeholder="[% 'Desde' | i18n %]" value="" required>
                <input type="text" id="date-to" name="date-to" data-datepicker="datepicker" placeholder="[% 'Hasta' | i18n %]" value="" required>
            </div>
        </div>

        <!-- se usa? -->
        <div class="control-group">
            <label class="checkbox" for="statistics_check">[% 'Generar estadisticas' | i18n %]

            <input type="checkbox" name="statistics_check" id="statistics_check"/></label>

        </div>        
          
          <div class="form-actions">
            [% PERL %]
                  print C4::AR::Filtros::action_button( 
                                                  button       => "btn btn-primary",
                                                  action       => "generarReporteCirculacionGeneral();", 
                                                  icon         => "",
                                                  title        => "Generar Reporte",
                                              ) ;
            [% END %]
          </div>
      </form>
 </div>
 
<div id="reportResultCirc" style="display:none;"></div>