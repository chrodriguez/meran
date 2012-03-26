
[% INCLUDE 'intranet-top.inc' %]
[% INCLUDE  'AutocompleteHelper.inc'  %]

<script type="text/javascript" src="/intranet-tmpl/includes/reports.js"></script>
<script>

    function lala(){
        alert("sdfsdf");

    }

    $(document).ready( function(){ 
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

        CrearAutocompleteUsuarios({ 
                                                    IdInput: 'usuario', 
                                                    IdInputHidden: 'nro_socio_hidden', 
                                                    callBackFunction: '',
                                });
    });
        
</script>

<div class="center_fieldset report_form_container">
      <form class="form-horizontal" onsubmit="generarEtiquetas('report_result_cards'); return false;">
     <!--     <div class="control-group">
            <label class="control-label"  for="name">Parte del nombre/apellido del usuario</label>
            <div class="controls">
              <input class="xlarge" id="name" name="name" size="30" type="text">
              <p class="help-block">Perez juan, etc.</p>
            </div>
          </div><!-- /control-group -->

          <div id="divInfoUsuario" class="control-group" >
              <label for="usuario" class="control-label">[% 'Usuario' | i18n %]
                  [% PERL %]
                      print C4::AR::Filtros::setHelpIcon( text => "[% 'Campo autocompletable, b&uacute;squeda por nombre, apellido, nro. de documento, legajo, nro. socio' | i18n %]",);
                  [% END %]
              </label>
              <div class="controls">
                  <input type='text' id='usuario' name='usuario' value='' size=32 tabindex='3' style="float: left">
                  <div id="estadoUsuario"></div>
                  <input type='hidden' id='nro_socio_hidden' value='' tabindex='-1'>
              </div>
          </div>
  
          <div class="control-group">
            <label class="control-label"  for="user_category">Categor&iacute;­a del usuario</label>
            <div class="controls">
              <select name="user_category" id="user_category">
                <option>Docente</option>
                <option>No docente</option>
                <option>Alumno</option>
                <option>Bibliotecario</option>
                <option>Cocinero</option>
              </select>
            </div>
          </div><!-- /control-group -->

          <div class="control-group">
              <label class="control-label"  for="interfaz">Interfaz</label>
              <div class="controls">
                <select name="interfaz" id="interfaz">
                  <option>OPAC</option>
                  <option>Intra</option>
                </select>
              </div>
            </div><!-- /control-group -->


          <div class="control-group">
            <label class="control-label"  for="name">Valor</label>
            <div class="controls">
              <input class="xlarge" id="name" name="name" size="30" type="text">
              <p class="help-block">Econom&iacute;a</p>
            </div>
          </div><!-- /control-group -->
          <div class="control-group">
            <label class="control-label"  for="name">Estantes virtuales/subestante</label>
            <div class="controls">
              <input class="xlarge" id="name" name="name" size="30" type="text">
              <p class="help-block">Econom&iacute;a</p>
            </div>
          </div><!-- /control-group -->
           <div class="control-group">
                    <label class="control-label" for="desde"> [% "Rango de Fechas" | i18n %] </label>
                    <div class="controls">
                          <input type="date" id="date-from" name="date-from" data-datepicker="datepicker" placeholder="Desde" value="" required>
                          <input type="date" id="date-to" name="date-to" data-datepicker="datepicker" placeholder="Hasta" value="" required>

                    </div>
            </div>
            </div>
          </div><!-- /control-group -->
          <div class="control-group">
                <label class="checkbox"  for="statistics_check">Generar estadisticas</label>
                <div class="controls">
                    <input type="checkbox" name="statistics_check" id="statistics_check" />
                </div>
          </div>

          <div class="form-actions">
            <input type="submit" class="btn btn-primary" value="Consultar">
          </div>
      </form>
 </div>
 
<div id="report_result_cards" style="display:none;"></div>