<script>
	function mostrarResultados(){
		$('#report_result').show();
		scrollTo("report_result");
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
	});
		
</script>

<div class="span12 center_fieldset report_form_container">
      <form class="form-stacked" onsubmit="mostrarResultados(); return false;">
          <div class="clearfix">
            <label for="xlInput">Partel del nombre/apellido</label>
            <div class="input">
              <input class="xlarge" id="xlInput" name="xlInput" size="30" type="text">
              <span class="help-block">Perez juan, etc.</span>
            </div>
          </div><!-- /clearfix -->
          <div class="clearfix">
            <label for="normalSelect">Categoría del usuario</label>
            <div class="input">
              <select name="normalSelect" id="normalSelect">
                <option>Docente</option>
                <option>No docente</option>
                <option>Alumno</option>
                <option>Bibliotecario</option>
                <option>Cocinero</option>
              </select>
            </div>
          </div><!-- /clearfix -->

          <div class="clearfix">
            <label for="appendedInput">Mayor de qué edad?</label>
            <div class="input">
              <div class="input-append">
                <input class="mini" id="appendedInput" name="appendedInput" size="16" type="number" min="0">
                <label class="add-on active"><input type="checkbox" name="" id="" value="" checked="checked"></label>
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
            <label for="normalSelect">Ordenar por</label>
            <div class="input">
              <select name="normalSelect" id="normalSelect">
                <option>Apellido</option>
                <option>Fecha de alta</option>
                <option>Legajo</option>
                <option>DNI</option>
              </select>
            </div>
          </div><!-- /clearfix -->

		  <div class="clearfix">
        <div class="iphone-toggle-buttons">
			<label for="checkbox-0">
				<input type="checkbox" name="checkbox-0" id="checkbox-0" />
				<span class="help-block"></span><span>&nbsp;Generar estadisticas</span>
			</label>
        </div>

		  </div>

          <div class="actions">
            <input type="submit" class="btn primary" value="Consultar">
          </div>
      </form>
 </div>
 
<div id="report_result" style="display:none;">
	<div class="pagination" style="width: 620px; margin: 0 auto; margin-bottom: 14px; float:none;">
	        <ul >
	          <li class="prev"><a href="#">← Previous</a></li>
	          <li><a href="#">11</a></li>
	          <li><a href="#">12</a></li>
	          <li><a href="#">13</a></li>
	          <li><a href="#">14</a></li>
	          <li class="active"><a href="#">15</a></li>
	          <li><a href="#">16</a></li>
	          <li><a href="#">17</a></li>
	          <li><a href="#">18</a></li>
	          <li><a href="#">19</a></li>
	          <li><a href="#">20</a></li>
	          <li class="next"><a href="#">Next →</a></li>
	        </ul>
	</div>
	<table class="bordered-table zebra-striped">
        <thead>
          <tr>
            <th>#</th>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Language</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1</td>
            <td>Some</td>
            <td>One</td>
            <td>English</td>
          </tr>
          <tr>
            <td>2</td>
            <td>Joe</td>
            <td>Sixpack</td>
            <td>English</td>
          </tr>
          <tr>
            <td>3</td>
            <td>Stu</td>
            <td>Dent</td>
            <td>Code</td>
          </tr>
        </tbody>
	</table>
          <div class="clearfix floatRight">
            <div class="input">
              <select class="medium" name="mediumSelect" id="mediumSelect">
                <option>Seleccionar</option>
                <option>PDF</option>
                <option>XLS</option>
              </select>
            </div>
          </div><!-- /clearfix -->	
</div>