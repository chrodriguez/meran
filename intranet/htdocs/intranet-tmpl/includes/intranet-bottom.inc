                            <div id="resultBusqueda"></div>
                            <div id="result"></div>
                        </div><!-- marco_datos -->
                  </div>

            <div id="loading_items" class="loading_items"></div>
        
        </div> <!-- container_test -->

        [% IF !registrado_meran %]
            <a target="_blank" href="http://meran.unlp.edu.ar/registrarse/" onclick="refreshMeranPage();" class="btn btn-large btn-success right" style="margin-right: 10px;">
                    [% 'Registrar' | i18n %]
            </a>  

            [% PERL %]
                C4::AR::Preferencias::setVariable('registradoMeran', 1);
            [% END %]
            
        [% END %]

    </body>
</html>