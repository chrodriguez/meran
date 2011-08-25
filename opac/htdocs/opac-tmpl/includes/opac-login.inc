<script type="text/javascript">
    var URL_PREFIX  = '[% url_prefix %]';
</script>
<script src="/includes/util.js" type="text/javascript"></script>
<script src="/includes/md5.js" type="text/javascript"></script>
<script src="/includes/sha1.js" type="text/javascript"></script>
[% USE HTML %]
    <script type="text/javascript">
        function enviar(){
		      [% IF plainPassword == 0 %]
			      var nroRandom   = [% nroRandom %];
			      var hash        = b64_sha256(b64_sha256(b64_md5($("#password_plain").val()))+nroRandom);
		          $("#password").val(hash);
			  [% ELSE %]
			      $("#password").val($("#password_plain").val());
			  [% END %]
		      return true;
      }
      var RecaptchaOptions = {};
      
      $(document).ready(function() {
                  //onEnter con foco en input, ejecuta la busqueda
                    onEnter("password",enviar);
                    $("#userid").focus();

                    // Add the value of "Search..." to the input field and a class of .empty
                    $("#search").val("Buscar...").addClass("empty");

                    // When you click on #search
                    $("#search").focus(function(){

                        // If the value is equal to "Search..."
                        if($(this).val() == "Buscar...") {
                            // remove all the text and the class of .empty
                            $(this).val("").removeClass("empty");;
                        }

                    });

                    // When the focus on #search is lost
                    $("#search").blur(function(){

                        // If the input field is empty
                        if($(this).val() == "") {
                            // Add the text "Search..." and a class of .empty
                            $(this).val("Buscar...").addClass("empty");
                        }

                    });


      });






</script>
<!-- Login -->
[% IF !socio_data %]
        [% IF !show_navlink %]
                <br />
        [% END %]
        [% IF mensaje %]      
            <h1>[% mensaje %]</h1>
        [% END %]
       <!--  <a class="sitelogo" style="margin-left:430px; margin-top:100px" title="Meran"></a>-->
       

 <!--<div id="divsearchform" >
          <form id="searchform_main" action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
              <input type="text" name="string" class="field"  value="[% search_string %]" tabindex="-1" style="width:428px; margin-left:277px; height:22px;" />
              <input type="submit" id="searchform_main_button" name="button" class="button" value="[% 'Buscar' | i18n %]" style="width: 125px;" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
          </form>
 </div> -->

        <div id="divsearchform" >
            <form id="searchform_main" action="[% url_prefix %]/opac-busquedasDB.pl" method="get" >
                <fieldset>
                   <input type="text" id="search" name="string" value="[% search_string %]" tabindex="-1"/>
                   <input type="submit" id="search-submit" value=""/>
                   <input type="hidden" name="tipoAccion"  value="BUSQUEDA_COMBINABLE" />
                   <input type="hidden" name="token" value="[% token %]" />
                </fieldset>
            </form>
        </div>
  
[% END %]
