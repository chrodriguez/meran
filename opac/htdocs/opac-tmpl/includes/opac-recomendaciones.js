function validateForm(){
            $("#recom_form").validate({
    
                errorElement: "em",
                errorClass: "error_adv",
                rules: {
                    autor:   "required",
                    titulo:     "required",                 
                    lugar_publicacion:    "required",
                    editorial:   "required",
                    fecha:     "required",                 
                    cant_ejemplares:    "required"
               },
            });
}


function limpiarCampos(){
    $('#autor').val("");
    $('#titulo').val("");
    $('#edicion').val("");
    $('#lugar_publicacion').val("");
    $('#editorial').val("");
    $('#fecha').val("");
    $('#coleccion').val("");
    $('#isbn_issn').val("");
    $('#cant_ejemplares').val("");

}


function eliminarFila(filaId){
    $('#tr'+filaId).remove()
}


function agregarRenglon(){
  validateForm(); 
  var id= $('#edicion_id').val();
  if( ($('#input'+id).val() == null) ){
            var autor  = $('#autor').val()
            var titulo   = $('#titulo').val()
            var edicion = $('#edicion').val()
            var lugar_publicacion = $('#lugar_publicacion').val();
            var editorial= $('#editorial').val();
            var fecha = $('#fecha').val();
            var coleccion = $('#coleccion').val();
            var ISBN_ISSN = $('#isbn_issn').val();
            var cant_ejemplares = $('#cant_ejemplares').val();
      
            limpiarCampos();
            
            $('#tabla_recomendacion').append(
                '<tr id="tr'+id+'" name='+id+'><input type="hidden" value="'+id+'" id="input'+id+'"><td>'+autor+'</td><td>'+titulo+'</td><td>'+edicion+'</td><td>'+lugar_publicacion+'</td>'+
                '<td>'+editorial+'</td><td>'+fecha+'</td><td>'+ISBN_ISSN+'</td>'+
                '<td>'+cant_ejemplares+'</td><td><input type="button" onclick="eliminarFila('+id+')" name="'+id+'" value="X"></input></td></tr>'
            )
            $('#recomendacion').show();
          
          }
}
          
 
 