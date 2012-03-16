<script type="text/javascript">
    $(function(){
        $("#rating[% id2 %]").children().not(":radio").hide();
        $("#rating[% id2 %]").stars({
            callback: function(ui, type, value)
            {
                $.post("[% url_prefix %]/rating.pl", {rate: value, id2: [% id2 %]}, function(data)
                {
                    $("#ajax_response[% id2 %]").html(data);
                    $("#ajax_response[% id2 %]").show();
                });
            },
            cancelShow: false,
            split: 2,
            [% IF !socio_data.usr_nro_socio %]
               disabled: true,
            [% END %]
        });
        $("#rating[% id2 %]").stars("select",[% rating %]);
    });
</script>

<div class="rating well">
    <h4>[% "Valoraci&oacute;n" | i18n %]</h4>


	<div class="rateit bigstars" data-rateit-starwidth="32" data-rateit-starheight="32"></div>

    <br style="clear:both" />
    <span class="label label-success" id="ajax_response[% id2 %]" style="display:none;"></span>
</div>
