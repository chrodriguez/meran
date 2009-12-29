[% INCLUDE 'opac-detail_partial_N1.inc' %]
<script src="/includes/jquery/fancybox/jquery.easing.1.3.js"></script>
<script src="/includes/jquery/fancybox/jquery.fancybox-1.2.1.pack.js"></script>
<link rel="stylesheet" type="text/css" media="screen,projection,print" href="/includes/css/fancybox.css" />

[% IF preferencias.resumido %]
    [% INCLUDE 'opac-detail_partial_N2_reducido.inc' %]
[% ELSE %]
    [% INCLUDE 'opac-detail_partial_N2_completo.inc' %]
[% END %]
<div id="resultadoReserva"></div>
