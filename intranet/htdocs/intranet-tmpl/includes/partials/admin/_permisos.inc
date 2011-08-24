[% INCLUDE  'AutocompleteHelper.inc'  %]

<script type="text/javascript">
    $(document).ready(function() {
        $('#usuario').focus();
        CrearAutocompleteUsuarios({ IdInput: 'usuario', 
                                    IdInputHidden: 'nro_socio_hidden', 
                            });

    });
</script>

<div class="permisos">
    <br><br>
    <fieldset>
        <legend class="titulo_legend">[% "Selecci&oacute;n de Permisos" | i18n %]</legend>
        <div class="permisos_selector">
            <ul>
                <li class="sub_item">
                    <label for="usuario"> Usuario: </label>
                    <input type="text" name="usuario" id="usuario" />
                    <input type="hidden" name="nro_socio_hidden" id="nro_socio_hidden" />
                </li>

                <li class="sub_item">
                    <label for="id_ui"> Unid. Info.: </label>
                    [% combo_UI %]
                </li>

                <li class="sub_item">
                    <label for="perfiles"> Perfil: </label>
                    [% combo_perfiles %]
                </li>

                <li class="sub_item">
                    <label for="perfiles"> Tipo de Permiso: </label>
                    [% combo_tipo_permisos %]
                </li>


                [% PERL %]
                    print C4::AR::Filtros::to_Button(   text    => "[% 'Obtener Permisos' | i18n %]",
                                                        boton   => "boton_agregar",
                                                        onClick => "obtenerPermisos();",
                                                        title   => "[% 'Obtener Permisos' | i18n %]",
                                                        alternClass => "botonCentrado",
                            ) ;
                [% END %]
            </ul>
        </div>
        <br>
        <br>
        <br>
    </fieldset>
    <div class="permisos_assign_chk" id="permisos_assign_chk"> </div>
</div>
