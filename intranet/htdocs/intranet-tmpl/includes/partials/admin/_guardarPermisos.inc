<div class="buttonContainerHorizontal">
    <ul class="horizontal-list" >
        [% IF nuevoPermiso != 1%]
                        [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "thoughtbot",
                                                                        onClick => "actualizarPermisos();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                            );
                        [% END %]
        [% ELSE %]
                [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "thoughtbot",
                                                                        onClick => "nuevoPermiso();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                            ) ;
                [% END %]
        [% END %]
  </ul>
</div>
