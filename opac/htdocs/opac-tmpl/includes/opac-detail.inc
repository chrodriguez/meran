<!-- <link rel="stylesheet" href="http://twitter.github.com/bootstrap/assets/css/docs.css" /> -->
<style>
	.main_content{
		width: 84% !important;
	}
</style>

<script type="text/javascript">
	function mostrarIndice(id2){
	    $("#indice_data" + id2).dialog({ width: 800, position: 'center', modal: true }); 
	}
	
	function ProcessGBSBookInfo(booksInfo) {
		for (id in booksInfo) {
		 var element = document.getElementById(id);
		 var bookInfo = booksInfo[id];
		 if (bookInfo) {
		  element.href = bookInfo.preview_url;
		  element.style.display = '';
		 }
	   }
	 }

    $(document).ready(function() {
    	$('.fancylink').fancybox();
    	$('.nano').nanoScroller();
    });
</script>

[% IF estadoDeColeccion %]
    <div class="detalle_completo_niveles">
        <div class="main-subcontent" style="width:100%; float:left">
            <div class="subcontent-unit-border" style="width:100%;">
                <div class="round-border-topleft""></div>
                    <div class="main-subcontent" style="width:100%; float:left;">
						 <legend class="trigger trigger_estado_coleccion_[% id1 %] click" ><h1>[% "Estado de Colecci&oacute;n" | i18n %]</h1></legend>
						         <div id="estado_coleccion[% id1 %]" class="detalle_total estado_coleccion[% id1 %]">
									<ul class="listado_sin_margen estado_coleccion">
										[% FOREACH anio IN estadoDeColeccion.keys.sort %]
										[% IF estadoDeColeccion.$anio.keys %]
										<li>
											[% IF anio != '#' %]<b>[% anio %]</b>[% END %]
											[% FOREACH volumen IN estadoDeColeccion.$anio.keys.sort %]
												[% IF volumen != '#' %][% volumen  %][% END %]
												(
												[% FOREACH fasciculo IN estadoDeColeccion.$anio.$volumen.keys.sort %]

													 [% PERL %]
														print C4::AR::Filtros::link_to( text =>     "[% fasciculo %]",
																						url=>"[% url_prefix %]/opac-detail.pl", 
																						params =>   ["id1=[% id1 %]","id2=[% estadoDeColeccion.$anio.$volumen.$fasciculo %]"],
																						title =>    "[% 'Mostrar Detalle del Registro' | i18n %]",
																						class => 	"link_to_detail"
																					) ;
													 [% END %]
									
												[% END %]
												)
											[% END %]
										   </li>
										[% END %]
										[% END %]
									</ul>
									[% IF issn %]
										<div class="right">
											<div class="google-books">
												<a id="ISSN:[% issn %]"  style="display:none" target="_blank">
													<img src="/includes/css/gbs_preview_button1.gif" border="0" style="margin: 0"/>
												</a>
											</div>
											<script src="http://books.google.com/books?jscmd=viewapi&bibkeys=ISSN:[% issn %]&callback=ProcessGBSBookInfo"></script>
										</div>
									[% END %]
							   </div>
							   
					</div>
			</div>
		</div>
	</div>
	<script type="text/javascript">makeToggle('estado_coleccion[% id1 %]','trigger_estado_coleccion_[% id1 %]',null,false);</script>
[% END %]

[% IF preferencias.resumido %]
    [% INCLUDE 'opac-detail_partial_N2_reducido.inc' %]
[% ELSE %]
    [% INCLUDE 'opac-detail_partial_N2_completo.inc' %]
[% END %]

<div id="resultadoReserva"></div>
