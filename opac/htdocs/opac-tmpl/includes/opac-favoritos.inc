<script type="text/javascript">

    function obtenerFavoritos(){
        objAH=new AjaxHelper(updateObtenerFavoritos);
        objAH.debug= true;
        objAH.url='/cgi-bin/koha/opac-favoritosDB.pl';
        objAH.debug= true;
        objAH.action='get_favoritos';
        objAH.sendToServer();
    }

    function updateObtenerFavoritos(responseText){
            if (!verificarRespuesta(responseText))
                return(0);
            $('#mis_favoritos').html(responseText);
            zebra('datos_tabla');
    }
    
    function eliminarFavorito(id_favorito){
        jConfirm(FAVORITE_CONFIRM_DELETE, CATALOGO_TITLE, function(confirmStatus){
            if (confirmStatus){
                objAH=new AjaxHelper(updateEliminarFavorito);
                objAH.debug= true;
                objAH.url='/cgi-bin/koha/opac-favoritosDB.pl';
                objAH.debug= true;
                objAH.action='delete_favorite';
                objAH.id1=id_favorito;
                objAH.sendToServer();
            }
        });
    }

    function updateEliminarFavorito(responseText){
            if (!verificarRespuesta(responseText))
                return(0);
            $('#mis_favoritos').html(responseText);
            zebra('datos_tabla');
    }
</script>

<script type="text/javascript">
      $(document).ready(function() {
        obtenerFavoritos();
      });
</script>
<div id="mis_favoritos"></div>