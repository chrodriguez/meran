package C4::AR::TipoDocumento;

use strict;
use C4::Modelo::CatRefTipoNivel3;
use C4::Modelo::CatRefTipoNivel3::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 
    getTipoDocumento
    getTipoDocumentoByTipo
);

=item
    Devuelve los tipos de documentos y la cantidad
    Sino, 0,0
=cut
sub getTipoDocumento{

    my $tiposDocumentoRef       = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3();

    my $tiposDocumentoRefCount  = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3_count();

    if(scalar(@$tiposDocumentoRef) > 0){
        return ($tiposDocumentoRef, $tiposDocumentoRefCount);
    }else{
        return (0,0);
    }
}

=item
    Devuelve el tipo de documento, buscandolo por el tipo recibido por parametro
    Sino, 0,0
=cut
sub getTipoDocumentoByTipo{

    my ($tipoDoc) = @_;

    my @filtros;
    
    push (@filtros, (id_tipo_doc => {eq => $tipoDoc}) );

    my $tiposDocumentoRef       = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(query => \@filtros,);

    if(scalar(@$tiposDocumentoRef) > 0){
        return ($tiposDocumentoRef->[0]);
    }else{
        return (0);
    }
}

1;