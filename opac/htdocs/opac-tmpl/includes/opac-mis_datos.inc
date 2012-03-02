<fieldset>
    <legend>
        [% 'Detalle de ' | i18n %] <strong >[% socio_data.usr_apellido %], [% socio_data.usr_nombre %] </strong>
    </legend>

    <dl>
        <dt class="inline left rightMargin">[% 'Nombre/s' |  i18n %] :</dt><dd>[% socio_data.usr_nombre %]</dd>
        <dt class="inline left rightMargin">[% 'Apellido/s' |  i18n %] :</dt><dd>[% socio_data.usr_apellido %]</dd>
        <dt class="inline left rightMargin">[% 'Ciudad' |  i18n %] :</dt><dd>[% socio_data.usr_ciudad_nombre %]</dd>
        <dt class="inline left rightMargin">[% 'Direcci&oacute;n' |  i18n %] :</dt><dd>[% socio_data.usr_calle %]</dd>
        <dt class="inline left rightMargin">[% 'Tel&eacute;fono' |  i18n %] :</dt><dd>[% socio_data.usr_telefono %]</dd>
        <dt class="inline left rightMargin">[% 'E-mail' |  i18n %] :</dt><dd>[% socio_data.usr_email %]</dd>
    </dl>
    
    <div>
        [% IF UploadPictureFromOPAC %] 
            PEPE
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
