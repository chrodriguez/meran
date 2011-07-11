<script type="text/javascript">
    $(function(){
        $("#rating[% id2 %]").children().not(":radio").hide();
        $("#rating[% id2 %]").stars({
            callback: function(ui, type, value)
            {
                $.post("[% url_prefix %]/rating.pl", {rate: value, id2: [% id2 %]}, function(data)
                {
                    $("#ajax_response[% id2 %]").html(data);
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

<div class="rating">
    <label>[% "Valoraci&oacute;n" | i18n %]</label>
    <form id="rating[% id2 %]" class="ratings" action="[% url_prefix %]/rating.pl" method="post">
        <input type="radio" name="rate" value="1" id="rate1" />
        <input type="radio" name="rate" value="2" id="rate2" />
        <input type="radio" name="rate" value="3" id="rate3" />
        <input type="radio" name="rate" value="4" id="rate4" />
        <input type="radio" name="rate" value="5" id="rate5" />
        <input type="radio" name="rate" value="6" id="rate6" />
        <input type="radio" name="rate" value="7" id="rate7" />
        <input type="radio" name="rate" value="8" id="rate8" />
        <input type="radio" name="rate" value="9" id="rate9" />
        <input type="radio" name="rate" value="10" id="rate10" />
        <input type="submit" value="Enviar" />
    </form>
    <br style="clear:both" />
    <p id="ajax_response[% id2 %]"></p>
</div>
