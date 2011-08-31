[% INCLUDE 'localized_messages.inc' %]
[% INCLUDE  'WindowHelper.inc'  %]

<script type="text/javascript">
	function mostrarIndice(id2){
	    $("#indice_data" + id2).dialog({ width: 800, position: 'center', modal: true }); 
	}
</script>

[% IF !ajax %]
    <script src="/includes/jquery/jquery.jqpageflow.js" type="text/javascript"></script>
	<script type="text/javascript"> 
	    $(document).ready(function(){
	        $("#main_content").flexiPagination({
	            url: "[% url_prefix %]/opac-detail.pl?id1=[% id1 %]&ajax=1&token=[% token %]",
	            totalResults: [% cant_total %],
	            perPage: [% per_page %],
	            container: "#main_content",
	            append_loader: "#loading_items",
	            pagerVar : "page",
	            loaderImgPath: imagesForJS+"/loader_grupos.gif",
	            debug : 1
	        });	});
	</script>
    
    [% INCLUDE 'opac-detail_partial_N1.inc' %]

[% END %]

[% IF preferencias.resumido %]
    [% INCLUDE 'opac-detail_partial_N2_reducido.inc' %]
[% ELSE %]
    [% INCLUDE 'opac-detail_partial_N2_completo.inc' %]
[% END %]

<div id="resultadoReserva"></div>
