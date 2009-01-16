package C4::Modelo::DB::Object::AutoBase2;

use base 'Rose::DB::Object';

use C4::Modelo::DB::AutoBase1;

sub init_db { C4::Modelo::DB::AutoBase1->new}

sub toString{
    my ($self)=shift;

    return $self->meta->class;
}

sub log{
    my ($self)=shift;
    use C4::AR::Debug;
    my ($data, $metodoLlamador)=@_;  

    C4::AR::Debug::log($self, $data, $metodoLlamador);
}


1;
