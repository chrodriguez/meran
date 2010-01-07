<script type="text/javascript">
    $(function(){
        $(".ratings").children().not(":radio").hide();
        $(".ratings").stars({
            callback: function(ui, type, value)
            {
                $.post("/cgi-bin/koha/rating.pl", {rate: value, id2: [% id2 %]}, function(data)
                {
                    $("#ajax_response").html(data);
                });
            },
            cancelShow: false,
        });
        $(".ratings").stars("select",[% rating %]);
    });
</script>

<div class="rating">
    <label>[% "Valoraci&oacute;n" | i18n %]</label>
    <form id="ratings" class="ratings" action="/cgi-bin/koha/rating.pl" method="post">
        <input type="radio" name="rate" value="1" id="rate2" />
        <input type="radio" name="rate" value="2" id="rate4" />
        <input type="radio" name="rate" value="3" id="rate1" />
        <input type="radio" name="rate" value="4" id="rate3" />
        <input type="radio" name="rate" value="5" id="rate5" />
        <input type="submit" value="Enviar" />
    </form>

    <br style="clear:both" />
    <p id="ajax_response"></p>
</div>
