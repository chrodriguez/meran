[% IF nuevoPermiso %]
	<div class="alert alert-error">
		<strong>[% "Advertencia" | i18n %]</strong>
		[% "ATENCION: DANDO DE ALTA UN NUEVO PERMISO YA QUE EL USUARIO NO CUENTA CON PRIVILEGIOS PARA TAL COMBINACION " | i18n %] 
	</div>
[% END %]