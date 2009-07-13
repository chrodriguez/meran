<div class="filtros_reportes">
    <ul class="filtros_reportes_der">
        <li>
            <select size="1" id="criteria" name="criteria">
                    <option value="combinada" selected >Combinada</option>
                    <option value="titulo">T&iacute;tulo</option>
                    <option value="autor">Autor</option>
                    <option value="tema">Tema</option>
                    <option value="shelves">Estante Virtual</option>
            </select>
        </li>
        &nbsp;
        <li>
            <input type="text" id="searchinc" size="25" name="searchinc">
        </li>
        &nbsp;
        <li>
            [% PERL %]
                            print C4::AR::Filtros::to_Button(
                                                                text    =>  "[% 'Buscar' | i18n %]",
                                                                boton   =>  "boton_buscar",
                                                                onClick =>  "searchinc()",
                                                            );
            [% END %]
        </li>
    </ul>
</div>


