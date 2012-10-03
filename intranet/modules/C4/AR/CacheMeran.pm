package C4::AR::CacheMeran;
use C4::AR::ObjetoCacheMeran;

use vars qw($CACHE @EXPORT);

@EXPORT=qw(nueva obtener setear limpiar borrar);

sub nueva{
    $CACHE=undef;
    $CACHE= C4::AR::ObjetoCacheMeran->new;
    
}

sub obtener{
    my ($key,$parent)= @_;
    $parent= ($parent || ( caller(1) )[3]);  
    return ($CACHE->get($parent,$key)||undef);
}


sub setear{
    my ($key,$valor,$parent)= @_;
    $parent= ($parent || ( caller(1) )[3]);  
    # C4::AR::Debug::error("CacheMeran => setear => parent ".$parent." key ".$key." valor ".$valor);
    $CACHE->set($parent,$key,$valor); 
}

sub limpiar{
    $parent = ( caller(1) )[3]; 
    $CACHE->clean($parent);
}

sub borrar{
    C4::AR::CacheMeran::nueva();
}
BEGIN{
      C4::AR::CacheMeran::nueva();
};



END { }       # module clean-up code here (global destructor)

1;
