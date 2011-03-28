
function agregarRenglon(){
   
//      $('#agregar_rec').click(function(){
//       if(($('#moneda').val() == "") || ($('#id_moneda').val() == "")){
//           jConfirm(POR_FAVOR_INGRESE_UNA_MONEDA, function(){ })      
//       }else{
          var autor  = $('#autor').val()
          var titulo   = $('#titulo').val()
          var edicion = $('#edicion').val()
          var lugar_publicacion = $('#lugar_publicacion').val();
          var editorial= $('#editorial').val();
          var fecha = $('#fecha').val();
          var coleccion = $('#coleccion').val();
          var ISBN_ISSN = $('#isbn_issn').val();
          var cant_ejemplares = $('#cant_ejemplares').val();
          var id= $('#edicion_id').val();
          
          $('#tabla_recomendacion').append(
              '<tr><td>'+autor+'</td><td>'+titulo+'</td><td>'+edicion+'</td><td>'+lugar_publicacion+'</td>'+
              '<td>'+editorial+'</td><td>'+fecha+'</td><td>'+autor+'</td><td>'+coleccion+'</td><td>'+ISBN_ISSN+'</td>'+
              '<td>'+cant_ejemplares+'</td><td><input type="checkbox" name='+id+' value=""></td></tr>'
           ) 
      }
          
/* } */    
 