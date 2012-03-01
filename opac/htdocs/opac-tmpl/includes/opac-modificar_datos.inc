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
	            var key         = b64_sha256(b64_md5($("#actualpassword").val()));
	            var hash_new1   = encriptar(b64_md5($("#newpassword1").val()),key);
	            var hash_new2   = encriptar(b64_md5($("#newpassword2").val()),key);

	            $("#actual_password").val(hash_actual);
	            $('#new_password1').val(hash_new1);
	            $('#new_password2').val(hash_new2);
	        [% ELSE %]
	            var hash_actual = $("#actualpassword").val();
	            var hash_new1   = $("#newpassword1").val();
	            var hash_new2   = $("#newpassword2").val();

                $("#actual_password").val(hash_actual);
                $('#new_password1').val(hash_new1);
                $('#new_password2').val(hash_new2);
            [% END %]
	        $("#datosAEnviar").submit();
	        return true;
	     }        	
      
    }

    function eliminarAutorizado(){
           $('#nombre_autorizado').val("");
           $('#dni_autorizado').val("");
           $('#telefono_autorizado').val("");
           $('#eliminar_autorizado').val("true");
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
        [% IF mensaje %]
            <div class="alert alert-error">
                <a class="close" data-dismiss="alert">×</a>
                <strong>[% 'Error en datos.' | i18n %]</strong>
                [% 'Corrigalos y vuelva a intentarlo' | i18n %]
            </div>
        [% END %]
<div>
    <form method="post" action="[% url_prefix %]/opac-userupdate.pl" onSubmit="return (checkPassword() && startOverlay())" class="form-horizontal">
    
    <fieldset>
        <legend>
            [% 'Detalle de ' | i18n %] <strong >[% socio_data.usr_apellido %], [% socio_data.usr_nombre %] </strong>
        </legend>
        <section class="center-section-form">
        <div class="control-group">
            <label class="control-label" for="nombre">[% 'Nombres' |  i18n %]* :</label>
            <div class="controls">
                <input type="text" name="nombre" id="nombre" required value="[% socio_data.usr_nombre %]" tabindex="6" />
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="apellido">[% 'Apellido/s' |  i18n %]* :</label>
            <div class="controls">
                <input type="text" name="apellido" id="apellido" required value="[% socio_data.usr_apellido %]" tabindex="7" />
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="ciudad">[% 'Ciudad' |  i18n %]* :</label>
            <div class="controls">
                <input type="text" name="ciudad" id="ciudad" required value="[% socio_data.ciudad %]" tabindex="8" />
                <input type="hidden" name="id_ciudad" id="id_ciudad" value="[% socio_data.ciudad_ref.id %]"/>
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="direccion">[% 'Direcci&oacute;n' |  i18n %]* :</label>
            <div class="controls">
                <input type="text" name="direccion" id="direccion" required value="[% socio_data.usr_calle %]" tabindex="9" />
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="telefono">[% 'Tel&eacute;fono' |  i18n %]* :</label>
            <div class="controls">
                <input type="text" name="telefono" id="telefono" required value="[% socio_data.usr_telefono %]" tabindex="10" />
            </div>
        </div>
        
        <div class="control-group">
            <label class="control-label" for="email">[% 'E-mail' |  i18n %]* :</label>
            <div class="controls">
                <input type="email" name="email" required id="email" value="[% socio_data.usr_email %]" tabindex="11" />
            </div>
        </div>

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
           </section>
        </fieldset>
          
        <fieldset>
            <legend>[% 'Usuario adicional' | i18n %]</legend>
            <section class="center-section-form">
                <div class="control-group">
                    <label class="control-label" for="nombre_autorizado">[% 'Nombre y Apellido' |  i18n %] :</label>
                    <div class="controls">
                        <input type="text" name="nombre_autorizado" id="nombre_autorizado" value="[% socio.getNombre_apellido_autorizado %]" tabindex="12" />
                    </div>
                </div>
                
                <div class="control-group">
                    <label class="control-label" for="dni_autorizado">[% 'DNI' |  i18n %] :</label>
                    <div class="controls">
                        <input type="text" name="dni_autorizado" id="dni_autorizado" value="[% socio.getDni_autorizado %]" tabindex="13" />
                    </div>
                </div>
                
                <div class="control-group">
                    <label class="control-label" for="telefono_autorizado">[% 'Tel&eacute;fono' |  i18n %] :</label>
                    <div class="controls">
                        <input type="text" name="telefono_autorizado" id="telefono_autorizado" value="[% socio.getTelefono_autorizado %]" tabindex="14" /> 
                    </div>
                </div>
        
                 <p><a onclick="eliminarAutorizado();" style="margin:11px;">Eliminar Autorizado</a></p>
                 <input type="hidden" name="eliminar_autorizado" id="eliminar_autorizado" value=""/> 
            </section>       
        </fieldset>
        <fieldset>
            <legend>[% 'Cambio de contrase&ntilde;a' | i18n %] ([% 'Dejar en blanco para descartar' | i18n %])</legend>
            <section class="center-section-form">
            <div class="control-group">
                <label class="control-label" for="actualpassword">[% 'Contrase&ntilde;a Actual' |  i18n %] :</label>
                <div class="controls">
                    <input type="password" name="" id="actualpassword" autocomplete="off" tabindex="15"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="newpassword1">[% 'Nueva Contrase&ntilde;a ' |  i18n %] :</label>
                <div class="controls">
                    <input type="password" name="" id="newpassword1" autocomplete="off" tabindex="16"/>
                </div>
            </div>

            <div class="control-group">
                <label class="control-label" for="newpassword2">[% 'Repetir Contrase&ntilde;a ' |  i18n %] :</label>
                <div class="controls">
                    <input type="password" name="" id="newpassword2" autocomplete="off" tabindex="17"/>
                </div>
            </div>
            </section>
        </fieldset>
        <fieldset>
            <legend>[% 'Personalizacion de visualizaicion' | i18n %]</legend>
            <section class="center-section-form">
            <div class="control-group">
                <label class="control-label" for="temas_opac">[% 'Tema' |  i18n %] :</label>
                <div class="controls">
                    [% combo_temas %]
                </div>
            </div>
            </section>
        </fieldset>
        <fieldset>
            <legend>[% 'Recordatorio de vencimiento de pr&eacute;stamos' | i18n %]</legend>
            <section class="center-section-form">
                <div class="control-group">
                    <label class="control-label" for="remindFlag">[% 'Recibir notificaci&oacute;nes' |  i18n %] :</label>
                    <div class="controls">
                        <input type="checkbox" name="remindFlag" id="remindFlag" [% IF socio_data.remindFlag %] checked="checked" [% END %]/> 
                    </div>
                </div>
            </section>
        </fieldset>
        <div class="form-actions">  
            <button class="btn btn-primary" type="submit">[% 'Modificar datos' |  i18n %]</button>
        </div>
    </form>
  </div>
