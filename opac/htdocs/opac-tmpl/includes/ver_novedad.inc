[% USE HTML %]
<h1><a href="#">[% novedad.getTitulo %]</a></h1>
<h3>[% novedad.getFechaLegible %]</a></h3>
<p>
    [% novedad.getContenido %]
</p>
<p class="details"> 
[% IF novedad.getCategoria %]
	[% 'Categor&iacute;a' | i18n %]: 
	<a href="#">[% novedad.getCategoria %]</a>
[% END %] 
</p>
