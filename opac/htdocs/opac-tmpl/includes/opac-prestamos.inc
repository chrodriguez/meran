[% USE HTML %]



<div class="main-subcontent" style="width:100%; float:left">
    <div class="subcontent-unit-border" style="width:100%;">
        <div class="round-border-topleft" style="width:90%;"></div>
        <h1>[% "Usted tiene los siguientes prestamos" | i18n %]</h1>
        <div class="detalle">
            <ul class="listado_sin_margen">
                [% FOREACH prestamo IN prestamos %]
                     <div class="[% IF prestamo.estaVencido %]prestamo_vencido[% ELSE %]background-color:#dae0ec;[% END %]">  
                      [% IF prestamo.nivel3.nivel2.id1 %]
                    <li>
                       
                          [% PERL %]
                                  print C4::AR::Filtros::link_to( text =>     "[% prestamo.nivel3.nivel2.nivel1.getTitulo %]",
                                                                  url =>      "[% url_prefix %]/opac-prestamos_vigentes.pl", 
                                                                  params => [ "id1=[% prestamo.nivel3.nivel2.id1 %]", ],
                                                              ) ;
                          [% END %]
                      [% ELSE %]
                          &nbsp;
                      [% END %] 
                      [% IF prestamo.estaVencido %]
                            <span style="color:red; font-weight: bold;">(Prestamo Vencido)</span>
                      [% END %] 

                    </li>
                    <li class="autor_result click" onClick="filtrarPorAutor([% prestamos.nivel3.nivel2.nivel1.cat_autor.id %])" title="[% 'Filtrar por Autor' | i18n %]">

                          [% IF prestamo.nivel3.nivel1.getAutor %]
                              [% prestamo.nivel3.nivel1.getAutor %]
                          [% ELSE %]
                              &nbsp;
                          [% END %]
                      </div>
                    </li>
                    <hr  class="clear-contentunit">
                [% END %]
            </ul>
        </div>
    </div>
</div>


