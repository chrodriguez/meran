[% INCLUDE 'intranet-top.inc' %]
[% INCLUDE 'AutocompleteHelper.inc' %]

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

    
    function generarReporteCirculacion(){

        objAH                   = new AjaxHelper(updateGenerarReporteCirculacion);
        objAH.debug             = true;
        objAH.cache             = true;
        objAH.showOverlay       = true;
        objAH.url               = URL_PREFIX+'/reports/circulacionDB.pl';
        objAH.tipoAccion        = "BUSQUEDAS";
        objAH.funcion           = "changePageBusquedas";
        objAH.categoriaSocio    = $('#categoria_socio_id').val();
        objAH.tipoReserva       = $('#tipoReserva').val();
        objAH.tipoDoc           = $('#tipo_documento_id').val();
        objAH.titulo            = $('#titulo').val();
        objAH.edicion           = $('#edicion').val();
        objAH.estadoReserva     = $('#estadoReserva').val();
        objAH.fecha_inicio      = $('#date-from').val();
        objAH.fecha_fin         = $('#date-to').val();
        objAH.statistics        = $('#statistics_check').val();
        objAH.orden             = ORDEN;
        objAH.asc               = ASC;
        objAH.sendToServer();
    }

    function updateGenerarReporteCirculacion(responseText){
        $('#reportResultCirc').html(responseText);
        $('#reportResultCirc').show();
        if (ORDEN){
              cambiarSentidoOrd();
        } 

    }   
   

    $(document).ready( function(){ 
         if (!Modernizr.inputtypes.date) {
              $("date-from").datepicker();
              $("date-to").datepicker();
        }
        $(".cb-enable").click(function(){
            var parent = $(this).parents('.switch');
            $('.cb-disable',parent).removeClass('selected');
            $(this).addClass('selected');
            $('.checkbox',parent).attr('checked', true);
        });
        $(".cb-disable").click(function(){
            var parent = $(this).parents('.switch');
            $('.cb-enable',parent).removeClass('selected');
            $(this).addClass('selected');
            $('.checkbox',parent).attr('checked', false);
        });
    });
        
</script>

<div class="center_fieldset report_form_container">
    <form class="form-horizontal" onsubmit="return false;">

        <div class="control-group" >
            <label for="tipoReserva" class="control-label">[% 'Tipo de reserva' | i18n %]</label>  
            <div class="controls">
                <select name="tipoReserva" id="tipoReserva">
                    <option>Ejemplar</option>
                    <option>Grupo</option>
                    <option>TODAS</option>
                </select>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="categoria_socio_id">Categor&iacute;Â­a del usuario</label>
            <div class="controls">  
                [% comboDeCategorias %]          
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="tipo_documento_id">Tipo de documento</label>
            <div class="controls">  
                [% comboDeTipoDoc %]          
            </div>
        </div>


        <div class="control-group">
            <label class="control-label" for="titulo">T&iacute;Â­tulo</label>
            <div class="controls">  
                <input type="text" id="titulo" name="titulo" >       
            </div>
        </div>

        <div class="control-group">
            <label class="control-label" for="edicion">Edici&oacute;Â­n</label>
            <div class="controls">  
                <input type="text" id="edicion" name="edicion" >       
            </div>
        </div>

        <div class="control-group" >
            <label for="estadoReserva" class="control-label">[% 'Estado de reserva' | i18n %]</label>  
            <div class="controls">
                <select name="estadoReserva" id="estadoReserva">
                    <option>Asignada</option>
                    <option>Anulada</option>
                    <option>Vencida</option>
                </select>
            </div>
        </div>

        <div class="control-group">
            <label class="control-label"> [% "Rango de Fechas" | i18n %] </label>
            <div class="controls">
                <input type="date" id="date-from" name="date-from" data-datepicker="datepicker" placeholder="Desde" value="" required>
                <input type="date" id="date-to" name="date-to" data-datepicker="datepicker" placeholder="Hasta" value="" required>
            </div>
        </div>

        <!-- se usa? -->
        <div class="control-group">
            <label class="checkbox" for="statistics_check">Generar estadisticas

            <input type="checkbox" name="statistics_check" id="statistics_check"/></label>

        </div>        
          
          <div class="form-actions">
            [% PERL %]
                  print C4::AR::Filtros::action_button( 
                                                  button       => "btn btn-primary",
                                                  action       => "generarReporteCirculacion();", 
                                                  icon         => "",
                                                  title        => "Consultar",
                                              ) ;
            [% END %]
          </div>
      </form>
 </div>
 
<div id="reportResultCirc" style="display:none;"></div>