[% INCLUDE 'ChangePasswordHelper.inc' %]
<link rel="stylesheet" type="text/css" href="[% temas %]/[% user_theme %]/includes/fileuploader.css">

<script type="text/javascript" src="/includes/jquery/fileuploader.js"></script>

<script type="text/javascript">

    function checkPassword(){

        var changed = $.trim($('#actualpassword').val());
        if (changed != ''){
            [% IF plainPassword == 0 %]
                var nroRandom   = [% nroRandom %];
	            var hash_actual = b64_sha256(b64_sha256(b64_md5($("#actualpassword").val()))+nroRandom);
	            var hash_new1   = encriptar((b64_sha256(b64_md5($("#newpassword1").val()))),b64_sha256(b64_md5($("#actualpassword").val())));
	            var hash_new2   = encriptar((b64_sha256(b64_md5($("#newpassword2").val()))),b64_sha256(b64_md5($("#actualpassword").val())));

	            $("#actual_password").val(hash_actual);
	            $('#new_password1').val(hash_new1);
	            $('#new_password2').val(hash_new2);
	        [% ELSE %]
	            var hash_actual = $("#actualpassword").val();
	            var hash_new1   = encriptar($("#newpassword1").val(),hash_actual);
                var hash_new2   = encriptar($("#newpassword2").val(),hash_actual);

                $("#actual_password").val(hash_actual);
                $('#new_password1').val(hash_new1);
                $('#new_password2').val(hash_new2);
            [% END %]
	        $("#datosAEnviar").submit();
	        return true;
	     }        	
      
    }

    $(document).ready(function() {
        CrearAutocompleteCiudades({IdInput: 'ciudad', IdInputHidden: 'id_ciudad'});
        $("#temas_opac").change(function() {
            $("link").attr("href","[% temas %]/"+$("#temas_opac").val()+"/includes/opac.css");
            return false;
        });

        $('.fancylink').fancybox();
        
        
        [% IF UploadPictureFromOPAC %] 

	        [% IF !foto_name %] 
	            $('#div_uploader').show();
	        [% ELSE %]
	            $('#div_boton_eliminar_foto').show();
	        [% END %]
	
	
	        //Inicializacion del FileUploader
	        [% IF !foto_name %]  
	            $('#label-file-uploader').show();
	            var uploader = new qq.FileUploader({
	                element: document.getElementById('file-uploader'),
	                action: '[% url_prefix %]/uploadPicture.pl',
	                params: {
	                    nro_socio: '[% socio_data.usr_nro_socio %]',
	                },
	                allowedExtensions: ["bmp","jpg","gif","png","jpeg"],
	                debug: true,
	                multiple: false,
	            });
	        [% ELSE %]
	            $('#label-file-uploader').hide();
	        [% END %]
	    [% END %]
        
        
    });
</script>
    <!--    <h1 class="block">[% 'Modificar sus datos personales' | i18n%]</h1>-->
        [% IF mensaje %]
            <h1 class="block error_field">[% 'Error en datos, s&iacute;rvase corregirlos' | i18n%]</h1>
        [% END %]
        <div class="column1-unit" style="width: 500px">
          <div class="contactform" style="width: 100%">
            <form method="post" action="[% url_prefix %]/opac-userupdate.pl" onSubmit="return (checkPassword() && startOverlay())">
              <fieldset>

                <legend>&nbsp;
                            <span id="name_card">
                                [% 'Detalle de ' | i18n %] [% socio_data.usr_apellido %], [% socio_data.usr_nombre %]
                            </span>
                        &nbsp;
                </legend>

                <p><label for="contact_firstname" class="left">[% 'Nombres' |  i18n %]* :</label>
                   <input type="text" name="nombre" id="nombre" class="field [% IF !socio_data.usr_nombre %] error_field [% END %]" value="[% socio_data.usr_nombre %]" tabindex="6" /></p>

                <p><label for="apellido" class="left">[% 'Apellido/s' |  i18n %]* :</label>
                   <input type="text" name="apellido" id="apellido" class="field [% IF !socio_data.usr_apellido %] error_field [% END %]" value="[% socio_data.usr_apellido %]" tabindex="7" /></p>

                <p><label for="ciudad" class="left">[% 'Ciudad' |  i18n %]* :</label>
                   <input type="text" name="ciudad" id="ciudad" class="field [% IF !socio_data.usr_ciudad_nombre %] error_field [% END %]" value="[% socio_data.usr_ciudad_nombre %]" tabindex="8" />
                   <input type="hidden" name="id_ciudad" id="id_ciudad" class="field" value="[% socio_data.ciudad_ref.id %]"/> </p>

                <p><label for="direccion" class="left">[% 'Direcci&oacute;n' |  i18n %]* :</label>
                   <input type="text" name="direccion" id="direccion" class="field [% IF !socio_data.usr_calle %] error_field [% END %]" value="[% socio_data.usr_calle %]" tabindex="9" /></p>

                <p><label for="telefono" class="left">[% 'Tel&eacute;fono' |  i18n %]* :</label>
                   <input type="text" name="telefono" id="telefono" class="field [% IF !socio_data.usr_telefono %] error_field [% END %]" value="[% socio_data.usr_telefono %]" tabindex="10" /></p>

                <p><label for="email" class="left">[% 'E-mail' |  i18n %]* :</label>
                   <input type="text" name="email" id="email" class="field [% IF !socio_data.usr_email %] error_field [% END %]" value="[% socio_data.usr_email %]" tabindex="11" /></p>
                   <input type="hidden" name="token" id="token" value="[% token %]" />
<!--                 Cambio de foto -->
                   [% IF UploadPictureFromOPAC %] 
	                      [% IF mensaje_error_foto %] 
	                        <li>
	                                <font color="red">[% mensaje_error_foto %]</font>
	                        </li>
	                      [% END %]
	
	                       <div id="div_boton_eliminar_foto" style="display: none">
	                          <li>
	                                [% PERL %]
	                                            print C4::AR::Filtros::to_Button(   text    => "[% 'Eliminar Foto' | i18n %]",
	                                                                                boton   => "boton_borrar",
	                                                                                onClick => "eliminarFoto('[% foto_name %] ');",
	                                                                             );
	                                [% END %]
	                          </li>
	                        </div>
	                        <li style="margin: 0 auto; width: 60%; list-style: none">
	                            <label for="file-uploader" id="label-file-uploader">
	                                <h4>[% 'Seleccione una im&aacute;gen apropiada' | i18n %]</h4>
	                            </label>
	                            <div id="file-uploader">
	                                <noscript>          
	                                    <p>[% 'Please enable JavaScript to use file uploader.' | i18n %]</p>
	                                    <!-- or put a simple form for upload here -->
	                                </noscript>                          
	                            </div>
	                        </li>
	                    </ul>
                    [% END %]
                   <!-- CAMPOS PARA CAMBIO DE PASSWORD -->
                   <input type="hidden" name="new_password1" id="new_password1" />
                   <input type="hidden" name="new_password2" id="new_password2" />
                   <input type="hidden" name="changePassword" id="changePassword" />
                   <input type="hidden" name="actual_password" id="actual_password" />
              </fieldset>
              <fieldset>
                  <legend>&nbsp;[% 'Cambio de contrase&ntilde;a' | i18n %] ([% 'Dejar en blanco para descartar' | i18n %])&nbsp;</legend>
                  <p>
                      <label for="actualpassword" class="left">[% 'Contrase&ntilde;a Actual' | i18n %]:</label>
                      <input type="password" name="" id="actualpassword" class="field" autocomplete="off" />
                  </p>
                  <p>
                      <label for="newpassword1" class="left">[% 'Nueva Contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="" id="newpassword1" class="field" autocomplete="off" />
                  </p>
                  <p>
                      <label for="newpassword2" class="left">[% 'Repetir contrase&ntilde;a' | i18n %]:</label>
                      <input type="password" name="" id="newpassword2" class="field" autocomplete="off" />
                  </p>
              </fieldset>
              <fieldset>
                  <legend>&nbsp;[% 'Personalizacion de visualizaicion' | i18n %]&nbsp;</legend>
                  <p>
                      <label for="temas_opac" class="left">[% 'Tema' | i18n %]:</label>
                      [% combo_temas %]
                  </p>
              </fieldset>
              <p><input type="submit" name="submit" id="submit" class="button" value="[% 'Modificar datos' |  i18n %]" tabindex="12" /></p>
            </form>
          </div>
        </div>
