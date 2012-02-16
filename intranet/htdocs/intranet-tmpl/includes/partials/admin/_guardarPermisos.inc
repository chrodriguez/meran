<div class="form-actions">
        [% IF nuevoPermiso != 1%]
                        [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "",
                                                                        onClick => "actualizarPermisos();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                            );
                        [% END %]
        [% ELSE %]
                [% PERL %]
                                    print C4::AR::Filtros::to_Button(   text    => "[% 'Guardar Permisos' | i18n %]",
                                                                        boton   => "",
                                                                        onClick => "nuevoPermiso();",
                                                                        title   => "[% 'Guardar Permisos' | i18n %]",
                                            ) ;
                [% END %]
        [% END %]
</div>
