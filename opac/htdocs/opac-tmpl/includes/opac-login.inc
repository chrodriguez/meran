<script language="javascript" type="text/javascript">
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
       
       <div class="searchform" >
         
          <form action="[% url_prefix %]/opac-busquedasDB.pl" method="get">
              <input type="text" name="string" class="field"  value="[% search_string %]" tabindex="-1" style="width:300px; margin-left:277px;" />
              <input type="submit" name="button" class="button" value="[% 'Buscar' | i18n %]" style="width: 125px;" />
              <input type="hidden" name="tipoAccion" value="BUSQUEDA_COMBINABLE" />
              <input type="hidden" name="token" value="[% token %]" />
          </form>
        </div>
      
[% END %]
