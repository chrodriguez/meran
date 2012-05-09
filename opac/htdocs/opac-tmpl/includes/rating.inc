<script type="text/javascript">
$(document).ready(function() {
	$('#rating_form_[% id2 %] .rateit').bind('rated reset', function (e) {
	    var ri = $(this);
		
		var value = ri.rateit('value');
		var itemid = ri.data('itemid');

    	ri.rateit('readonly', true);
		
	    $.ajax({
	        url: '[% url_prefix %]/rating.pl',
	        data: {rate: value, id2: itemid}, 
	        type: 'POST',
	        success: function (data) {
                $("#ajax_response[% id2 %]").html(data);
                $("#ajax_response[% id2 %]").show();
	
	        },
	        error: function (jxhr, msg, err) {
	            $('#response').append('<li style="color:red">' + msg + '</li>');
	        }
	    });
	});
});
</script>

<div id="rating_form_[% id2 %]" class="well">
    <h4>[% "Valoraci&oacute;n" | i18n %]</h4>
	<div 	class="rateit bigstars"  data-rateit-max="5" 
			data-rateit-step="0.5" data-rateit-value="[% rating %]" data-rateit-starwidth="32" 
			data-rateit-starheight="32" data-itemid="[% id2 %]" 

			[% IF !socio_data.usr_nro_socio %]
			   data-rateit-readonly="true"
			[% END %]
	></div>

    <br style="clear:both" />
    <span class="label label-success" id="ajax_response[% id2 %]" style="display:none;"></span>
</div>
