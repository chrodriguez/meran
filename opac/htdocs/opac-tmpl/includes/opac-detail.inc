[% FOREACH nivel2 %]
    <div id="[% DivDetalle %]">

        <table id="tablaDetalleNivel" class="tablaDetalleNivel3" cellspacing=0 border="0" cellpadding=0 width="100%" class="tope">
            <thead>
            <tr class="bordetabla" align="center">
                <td>&nbsp;</td>
                <td>[% "C&oacute;digo" | i18n %]</td>
                <td>[% "Signatura Topogr&aacute;fica" | i18n %]</td> 
                <td>[% "Biblioteca que lo posee" | i18n %]</td>
                <td>[% "Biblioteca de origen" | i18n %]</td>
                <td>[% "Estado" | i18n %]</td>
                <td>[% "Disponibilidad" | i18n %]</td>
                <td>[% "MARC" | i18n %]</td>
                <td>&nbsp;</td>
            </tr>
            </thead>
            <tbody>
            [% FOREACH nivel3 %]
                <tr align="center">

                    <td>&nbsp;</td>

                    <td>[% nivel3_obj.getBarcode %]</td>
                    <td>[% nivel3_obj.getSignatura_topografica %]</td>
                    <td>[% nivel3_obj.getId_ui_poseedora %]</td>   
                    <td>[% nivel3_obj.getId_ui_origen %]</td>  
                    <td>[% nivel3_obj.getEstado %]</td>
                    <td>[% nivel3_obj.ref_disponibilidad.getNombre %]</td>
                    <td>
                        <a class="click" onClick="MARCDetail('[% id3 %]', '[% DivDetalle %]', '[% DivMARC %]');">
                        <img src="[% themelang %]/images/MARC.png" border="0" alt="[% 'Detalle MARC' | i18n %]" title="[% 'Detalle MARC' | i18n %]">
                        </a>
                    </td>

                    <td>&nbsp;</td>

                </tr>
            [% END %]
            </tbody>
        </table>

        <!-- FIXME falta revisar!!!!!!!!!!! -->
        <table  width="100%">
            <tr>
                <td class="impar" >
                    <a href="/cgi-bin/koha/opac-shelves.pl?viewShelfItems=[% biblioitemnumber %]&biblio=[% biblionumber %]">
                        <img src="[% themelang %]/images/vertodos.png" border="0" alt="[% 'Estantes Virtuales' | i18n %]">
                    </a>
                    <a  href="/cgi-bin/koha/opac-analysis.pl?bibnum=[% biblionumber %]&bibnumitems=[% biblioitemnumber %]">
                        <img src="[% themelang %]/images/analiticas.png" border="0" alt="[% 'Anal&iacute;ticas' | i18n %] ">
                    </a>

                    <a  href="/cgi-bin/koha/opac-indiceLibro.pl?biblionumber=[% biblionumber %]&biblioitemnumber=[% biblioitemnumber %]">
                        <img src="[% themelang %]/images/indice.png" border="0" alt="[% 'Indice' | i18n %]">
                    </a>
                    <br>
                    [% "Disponibilidad Actual Para Pr&eacute;stamo:" | i18n %] <b>[% cantParaPrestamo %]</b><br>    
                    [% "Disponibilidad Actual Para Sala de Lectura:" | i18n %] <b>[% cantParaSala %]</b><br>
                    [% "Cantidad Actual de Reservas:" | i18n %] <b>[% cantReservas %]</b><br>

                    [% IF socio_data %]
                        [% PERL %]
                            print C4::AR::Filtros::to_Icon(   text    => "[% 'Reservar' | i18n %]",
                                                                boton   => "icon_reservar",
                                                                width   => "100",
                                                                onClick => "reservar([% id1 %],[% id2 %])",
                                                                title   => "[% 'Reservar' | i18n %]"
                                                        );
                        [% END %]
                    [% END %]
                </td>
            </tr>
        </table>
    </div>
[% END %]
