<script type="text/javascript" src="/includes/jquery/jquery.nanoscroller.js"></script>
    
<script>
$(document).ready(function(){
     
});

function changePageBusquedas(ini){
    objAH.changePage(ini);
}
</script>


[% IF cant %]
	
	<div class="well">
		<small>[% nombre_estante %]</small>
		[% FOREACH res IN data %]
				[% res.estante %]
		[% END %]


	</div>

	

  	
<div class="well">
      <div class="resultados_consulta">[% "La cantidad de registros" | i18n %]: <strong>[% cant %]</strong></div>             
</div>
[% IF !exportar %]
<div class="form-actions" id="actions_ejemplares" style="margin-bottom: 0;">
   <td>
      [% PERL %]
                print C4::AR::Filtros::action_set_button(    
                        button  => 'btn btn-primary',
                        title => " [% 'Exportar a PDF' | i18n %]",
                        action => 'imprimirReporte("form_reporte_colecciones");',
                        icon => "icon-white icon-inbox",
                  ) ;
      [% END %]
   </td>
</div>       
[% END %]
[% ELSE %]
	<div class="alert alert-info">
              [% 'No hay resultados para mostrar' | i18n  %]
    </div>

[% END %]
