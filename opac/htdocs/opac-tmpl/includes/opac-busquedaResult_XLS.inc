
  <h3>Resultado de la búsqueda:</h3>
   <table id="tablaResult" class="tabla_datos" cellspacing='0' cellpadding='0' style="text-align:center; width:100%; border:1;">
              
              <thead>
              </thead>
              <tbody>
                      <!-- Resultados de la busqueda -->
                    [% FOREACH NIVEL IN SEARCH_RESULTS  %]
                    <tr>
                        <td> [% NIVEL.titulo %] - [% NIVEL.nomCompleto %] (Solicitar por:  [% FOREACH signatura IN NIVEL.signaturas  %]
                                                                                                [% signatura %]
                                                                            [% END %]) </td>
                        <hr>
                        
                    </tr>
                   
                    [% END %]
              </tbody>
        </table>

       
