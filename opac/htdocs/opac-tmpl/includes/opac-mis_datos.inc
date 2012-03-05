<script type="text/javascript" language="javascript">
 
    $(document).ready(function(){

        $('.fancylink').fancybox();

        [% IF !foto_name %] 
            $('#div_uploader').show();
        [% ELSE %]
            $('#div_boton_eliminar_foto').show();
        [% END %]

        $('.fancylink').fancybox();

        //Inicializacion del FileUploader
        [% IF !foto_name %]  
            $('#label-file-uploader').show();
	        var uploader = new qq.FileUploader({
	            element: document.getElementById('file-uploader'),
	            action: '[% url_prefix %]/usuarios/reales/uploadPicture.pl',
	            params: {
	            	nro_socio: '[% nro_socio %]',
	            },
	            allowedExtensions: ["bmp","jpg","gif","png","jpeg"],
	            onComplete: function(id, fileName){detalleUsuario();},
	            debug: true,
	            multiple: false,
	        });
        [% ELSE %]
            $('#label-file-uploader').hide();
        [% END %]
        
    });
</script>
<section class="center-section-form">
<fieldset>
    <legend>
        [% 'Detalle de ' | i18n %] <strong >[% socio_data.usr_apellido %], [% socio_data.usr_nombre %] </strong>
    </legend>
    
    <dl class="listaUsuarioLeft">
        <dt class="inline left rightMargin">[% 'Nombre/s' |  i18n %] :</dt>
            <dd>[% socio_data.usr_nombre %]</dd>
        <dt class="inline left rightMargin">[% 'Apellido/s' |  i18n %] :</dt>
            <dd>[% socio_data.usr_apellido %]</dd>
        <dt class="inline left rightMargin">[% "DNI" | i18n %] :</dt>
            <dd>[% socio.persona.getNro_documento %]</dd>
        <dt class="inline left rightMargin">[% "N&uacute;mero de Socio" | i18n %] :</dt>
            <dd>[%  socio.nro_socio %]</dd>
        <dt class="inline left rightMargin">[% "Legajo" | i18n %] :</dt>
            <dd>[%  socio.persona.getLegajo %]</dd>
        <dt class="inline left rightMargin">[% "Fecha de nacimiento" | i18n %] :</dt>
            <dd>[% socio.persona.getNacimiento %]</dd>
        <dt class="inline left rightMargin">[% 'Ciudad' |  i18n %] :</dt>
            <dd>[% socio_data.usr_ciudad_nombre %]</dd>
        <dt class="inline left rightMargin">[% 'Direcci&oacute;n' |  i18n %] :</dt>
            <dd>[% socio_data.usr_calle %]</dd>
        <dt class="inline left rightMargin">[% 'Tel&eacute;fono' |  i18n %] :</dt>
            <dd>[% socio_data.usr_telefono %]</dd>
        <dt class="inline left rightMargin">[% 'E-mail' |  i18n %] :</dt>
            <dd>[% socio_data.usr_email %]</dd>
    </dl>
    
    <div id="fotoUsuario">
        [% IF foto_name %]  
            <a class="fancylink" rel="group" href="/pictures/[% foto_name %]">
                <img border="0" src="/pictures/[% foto_name %]"
                      style="width: 60%; max-width: 120px;" 
                      alt="[% socio.persona.getApellido %], [% socio.persona.getNombre %] ([% socio.getNro_socio %])"
                      title="[% socio.persona.getApellido %], [% socio.persona.getNombre %] ([% socio.getNro_socio %])"
                >
            </a>
        [% END %]
    </div>

    <div class="form-actions">
        [% PERL %]
              print C4::AR::Filtros::action_link_button( 
                                              button    => "btn btn-primary",
                                              url       => "[% url_prefix %]/modificarDatos.pl", 
                                              title     => "[% 'Modificar Datos' |  i18n %]",
                                          ) ;

        [% END %]
    </div>

</fieldset>
</section>
