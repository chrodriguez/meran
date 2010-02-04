[% IF nuevoPermiso %]
    <fieldset>
        <legend class="titulo_legend">[% "Advertencia" | i18n %]</legend>
        <h5 style="font-size: 20px; color:red;"> 
            [% "ATENCION: DANDO DE ALTA UN NUEVO PERMISO YA QUE EL USUARIO NO CUENTA CON PRIVILEGIOS PARA TAL COMBINACION " | i18n %] 
        </h5>
    </fieldset>
[% END %]