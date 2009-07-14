<script type="text/javascript">
    $(document).ready(function() {
        onEnter("searchField",searchinc);
    });
</script>

<div class="buttonContainerHorizontal">
    <ul class="horizontal-list" >
        <li>
            <select size="1" id="criteria" name="criteria">
                    <option value="combinada" selected >Combinada</option>
                    <option value="titulo">T&iacute;tulo</option>
                    <option value="autor">Autor</option>
                    <option value="tema">Tema</option>
                    <option value="shelves">Estante Virtual</option>
            </select>
        </li>
        <li>
            <input type="text" id="searchField" size="25" name="searchField">
        </li>
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

