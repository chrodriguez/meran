[% INCLUDE 'opac-detail_partial_N1.inc' %]

[% IF reducido %]
    [% INCLUDE 'opac-detail_partial_N2_reducido.inc' %]
[% ELSE %]
    [% INCLUDE 'opac-detail_partial_N2_completo.inc' %]
[% END %]
<div id="resultadoReserva"></div>
