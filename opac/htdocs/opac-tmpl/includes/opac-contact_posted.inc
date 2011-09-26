[% IF mensaje_error %]
        <h1 class="block">[% 'Por favor complete todos los campos requeridos' | i18n %]
        </h1>
[% ELSE %]
        <h1 class="block">[% 'Su mensaje ha sido enviado, el equipo de ' | i18n %][% ui.getNombre %] [% 'le responder&aacute; lo antes posible' | i18n %]. [% 'Muchas gracias' | i18n %]
        </h1>
[% END %]
