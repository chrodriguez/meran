<script type="text/javascript" src="/intranet-tmpl/includes/reports.js"></script>
<script>
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
	});
		
</script>

<div class="span12 center_fieldset report_form_container">
      <form class="form-stacked" onsubmit="generarEtiquetas('report_result_cards'); return false;">
          <div class="clearfix">
            <label for="name">Partel del nombre/apellido</label>
            <div class="input">
              <input class="xlarge" id="name" name="name" size="30" type="text">
              <span class="help-block">Perez juan, etc.</span>
            </div>
          </div><!-- /clearfix -->
          <div class="clearfix">
            <label for="user_category">Categoría del usuario</label>
            <div class="input">
              <select name="user_category" id="user_category">
                <option>Docente</option>
                <option>No docente</option>
                <option>Alumno</option>
                <option>Bibliotecario</option>
                <option>Cocinero</option>
              </select>
            </div>
          </div><!-- /clearfix -->

          <div class="clearfix">
            <label for="base_age">Mayor de qué edad?</label>
            <div class="input">
              <div class="input-append">
                <input class="mini" id="base_age" name="base_age" size="16" type="number" min="0">
                <label class="add-on active"><input type="checkbox" name="base_age_check" id="base_age_check" value="" checked="checked"></label>
              </div>
            </div>
          </div><!-- /clearfix -->

          <div class="clearfix">
            <label>Fecha de alta</label>
            <div class="input">
              <div class="inline-inputs">
                <input class="small" type="text" value="May 1, 2011">
                <input class="mini" type="text" value="12:00am">
                to
                <input class="small" type="text" value="May 8, 2011">
                <input class="mini" type="text" value="11:59pm">
                <span class="help-block">All times are shown as Pacific Standard Time (GMT -08:00).</span>
              </div>
            </div>
          </div><!-- /clearfix -->

          <div class="clearfix">
            <label for="sorty_by">Ordenar por</label>
            <div class="input">
              <select name="sorty_by" id="sorty_by">
                <option>Apellido</option>
                <option>Fecha de alta</option>
                <option>Legajo</option>
                <option>DNI</option>
              </select>
            </div>
          </div><!-- /clearfix -->

		  <div class="clearfix">
        <div class="iphone-toggle-buttons">
			<label for=""statistics_check"">
				<input type="checkbox" name="statistics_check" id=""statistics_check"" />
				<span class="help-block"></span><span>&nbsp;Generar estadisticas</span>
			</label>
        </div>

		  </div>

          <div class="actions">
            <input type="submit" class="btn primary" value="Consultar">
          </div>
      </form>
 </div>
 
<div id="report_result_cards" style="display:none;"></div>