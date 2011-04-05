// function validateForm(){
//             $("#recom_form").validate({
//     
//                 errorElement: "em",
//                 errorClass: "error_adv",
//                 rules: {
//                     autor:   "required",
//                     titulo:     "required",                 
//                     lugar_publicacion:    "required",
//                     editorial:   "required",
//                     fecha:     "required",                 
//                     cant_ejemplares:    "required"
//                },
//             });
// }


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
    $('#motivo_propuesta').val("");
    $('#comment').val("");  
    $('#edicion_id').val(null);
   
}


function eliminarFila(filaId){
    $('#tr'+filaId).remove()
}


function agregarRenglon(){
//   validateForm(); 
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
            var id_nivel_2 = "-";
            var comentario= $('#comment').val();
            var motivo= $('#motivo_propuesta').val();
            limpiarCampos();
       
            $('#tabla_recomendacion').append(
                '<tr id="tr'+id+'" name='+id+'>' +
                    '<input type="hidden" value="'+id+'" id="input'+id+'">' +
                    '<td>'+autor+'</td>' +
                    '<td id="titulo'+id+'" name=titulo'+id+'>'+titulo+'</td>' +
                    '<td id="edicion'+id+'" name=edicion'+id+'>'+edicion+'</td>'+
                    '<td id="lugar_publicacion'+id+'" name=lugar_publicacion'+id+'>'+lugar_publicacion+'</td>' +
                    '<td id="editorial'+id+'" name=editorial'+id+'>'+editorial+'</td>' +
                    '<td id="fecha'+id+'" name=fecha'+id+'>'+fecha+'</td>' +
                    '<td id="isbn_issn'+id+'" name=isbn_issn'+id+'>'+ISBN_ISSN+'</td>'+
                    '<td id="nivel_2'+id+'" name=nivel_2'+id+'>'+id_nivel_2+'</td>'+
                    '<td id="cant_ejemplares'+id+'" name=cant_ejemplares'+id+'>'+cant_ejemplares+'</td>' +  
                    '<td id="motivo'+id+'" name=motivo'+id+'>'+motivo+'</td>' + 
                    '<td id="comentario'+id+'" name=comentario'+id+'>'+comentario+'</td>' + 
//                     '<td><input type="button" onclick="eliminarFila('+id+')" name="'+id+'" value="X"></input></td>' +
                 '</tr>'
            )
  $('#recomendacion').show();
          
  }
}
          
 
 