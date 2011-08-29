[% IF estante %]
<div id='listaEstantes'>
  <h2>
			    [% auxEstante = estante %]
			    [% listaEstantes = [] %]
			    [% WHILE auxEstante > 0 %]
				[% listaEstantes.unshift(auxEstante) %]
				[% IF auxEstante.getPadre %]
				  [% auxEstante = auxEstante.estante_padre %]
				[% ELSE %]
				  [% auxEstante = 0 %]
				[% END %]
			  [% END %]
	  [% FOREACH auxEstante IN listaEstantes %]
	    [% PERL %]
				      print C4::AR::Filtros::link_to( text =>     "[% auxEstante.getEstante %]",
								      url=> '[% url_prefix %]/opac-estante.pl', 
								      params =>   ["id_estante=[% auxEstante.getId %]"],
								      title =>    "[% 'Mostrar Detalle del Estante' | i18n %]",
								      class => "link_to_detail"
								  ) ;
	  [% END %]
	    <b> / </b>
	  [% END %]
  </h2>
</div>
[% END %]
[% IF SUBESTANTES %]
  [% IF cant_estantes > 0 %]
  <div id='subestantes'>
    <table id="tablaHistorial" class="tablaHistorial tabla_datos" cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
        <tr class="tablaResultadoTitulo" >
            <th>[% "Estantes" | i18n %]</th>
        </tr>
        <!-- ESTE LOOP MUESTRA LOS ESTANTES -->
        [% FOREACH estante IN SUBESTANTES %]
            <tr>
              <td> 
                [% PERL %]
                    print C4::AR::Filtros::link_to( text    =>  "[% estante.getEstante %]",
                                                    url     =>  '[% url_prefix %]/opac-estante.pl',
						    params =>   ["id_estante=[% estante.getId %]"],
						    title =>    "[% 'Mostrar Detalle del Estante' | i18n %]",
						    class => "link_to_detail"
                            ) ;
                [% END %]
              </td>
	    </tr>
        [% END %]
    </table>
  </div>
 [% END %]
[% ELSE %]
    <h1> [% 'No hay estantes virtuales.' | i18n %] </h1>

[% END %]

[% IF estante %]
  [% IF estante.contenido %]
  <div id='contenido'>
           <table id="tablaResult" class="tablaHistorial tabla_datos" border=0 cellspacing="0" cellpadding="4" style="width:98%; text-align:center; border: 1;">
                <thead>
		<tr class="tablaResultadoTitulo" >
		    <th colspan="4">[% "Contenido" | i18n %]</th>
		</tr>
                <tr class="tablaResultadoTitulo">
                    <th Title="[% 'Ordenar por título' | i18n %]" width="33%">[% "T&iacute;tulo" | i18n %]
                    </th>

                    <th Title="[% 'Ordenar por autor' | i18n %]" align="left" width="23%">[% "Autor" | i18n %]
                    </th>
                    <th Title="[% 'Ordenar por lugar' | i18n %]" width="20%">[% "Lugar" | i18n %]
                    </th>
                    <th Title="[% 'Ordenar por edici&oacute;n' | i18n %]" width="20%">[% "Edic&iacute;on" | i18n %]
                    </th>
                </tr>
                </thead>
                <tbody>
                [% FOREACH contenido_estante IN estante.contenido %]
                <tr>
                    <td class="titulo_result">
                        [% PERL %]
                            print C4::AR::Filtros::link_to( text =>     "[% contenido_estante.nivel2.nivel1.getTitulo %]",
                                                            url =>      "[% url_prefix %]/opac-detail.pl", 
                                                            params =>   ["id1=[% contenido_estante.nivel2.id1 %]"],
                                                            title =>    "[% 'Mostrar Detalle del Ejemplar' | i18n %]"
                                                        ) ;
                        [% END %]
                    </td>
                    <td class="autor_result">
                                [% PERL %]
                                    print C4::AR::Filtros::link_to( text =>     "[% contenido_estante.nivel2.nivel1.getAutor %]",
                                                                    url =>      "[% url_prefix %]/opac-busquedasDB.pl", 
                                                                    params =>   ["tipoAccion=BUSQUEDA_AVANZADA","autor=[% contenido_estante.nivel2.nivel1.getAutor %]"],
                                                                    title =>    "[% 'Buscar de este autor' | i18n %]"
                                                                ) ;
                                [% END %]                                
                    </td>
                    <td align=center>
                     [% contenido_estante.nivel2.getCiudadObject.getNombre %]
                    </td>
                    <td align=center>
                      [% IF contenido_estante.nivel2.getEdicion %]
                                [% contenido_estante.nivel2.getEdicion %] &nbsp;
                            [% END %]
                            [% IF contenido_estante.nivel2.getAnio_publicacion %]
                                ([% contenido_estante.nivel2.getAnio_publicacion %])
                            [% END %]
                            [% IF contenido_estante.nivel2.getVolumen %]
                                t [% contenido_estante.nivel2.getVolumen %]  [% contenido_estante.nivel2.getVolumenDesc %]
                       [% END %]
                    </td>
                </tr>
                [% END %]
                </tbody>
            </table>
   </div>
  [% END %]
[% END %]