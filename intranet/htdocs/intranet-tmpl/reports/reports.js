function openLink(url){

     window.location.href=url;


}


function hideTableColumn(column_number,hide_param){
// FUNCIONA SOLAMENTE SI HAY UNA SOLA TABLA EN EL DOCUMENTO
//             $('td:nth-child(2)').hide();
    // if your table has header(th), use this
    $('td:nth-child('+column_number+'),th:nth-child('+column_number+')').hide();
    $('#'+hide_param).val(1);
    
}

function submitForm(form_id){

    $('#'+form_id).submit();
}