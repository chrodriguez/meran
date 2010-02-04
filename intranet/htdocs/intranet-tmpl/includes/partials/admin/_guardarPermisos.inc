<div class="buttonContainerHorizontal">
    <ul class="horizontal-list" >
        [% IF nuevoPermiso != 1%]
                        [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "boton_buscar",
                                                                        onClick => "actualizarPermisos();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                                                        width   => "150px",
                                            );
                        [% END %]
        [% ELSE %]
                [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "boton_buscar",
                                                                        onClick => "nuevoPermiso();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                                                        width   => "150px",
                                            ) ;
                [% END %]
        [% END %]
  </ul>
</div>
