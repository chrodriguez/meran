[% USE HTML %]
<h1><a href="#">[% novedad.getTitulo %]</a></h1>
<h3>[% novedad.getFechaLegible %], [% 'por ' | i18n %] <a href="#">[% novedad.getUsuario %]</a></h3>
<p>
    [% HTML.escape(novedad.getContenido) %]
</p>
<p class="details">| 
[% 'Acutalizado por' | i18n %] <a href="#"> [% novedad.getUsuario %] </a> | [% 'Categor&iacute;a' | i18n %]: 
<a href="#">[% novedad.getCategoria %]</a> |
</p>
