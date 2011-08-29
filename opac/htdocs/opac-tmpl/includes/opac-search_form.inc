<script type="text/javascript">
    $(document).ready(function() {
    	// Add the value of "Search..." to the input field and a class of .empty
                    $("#search_bar").val("Buscar...").addClass("empty");

                    // When you click on #search
                    $("#search_bar").focus(function(){

                        // If the value is equal to "Search..."
                        if($(this).val() == "Buscar...") {
                            // remove all the text and the class of .empty
                            $(this).val("").removeClass("empty");;
                        }

                    });

                    // When the focus on #search is lost
                    $("#search_bar").blur(function(){

                        // If the input field is empty
                        if($(this).val() == "") {
                            // Add the text "Search..." and a class of .empty
                            $(this).val("Buscar...").addClass("empty");
                        }
                    });
      });
</script>
        <div class="searchform">
          <form action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
            <fieldset>
              <input type="text" name="string" id="search_bar"  class="field"  value="[% search_string %]" tabindex="-1" style="width: 200px;" />
              <input type="submit" name="button" class="button" value="[% 'Buscar' | i18n %]" style="width: 125px;" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
            </fieldset>
          </form>
        </div>
