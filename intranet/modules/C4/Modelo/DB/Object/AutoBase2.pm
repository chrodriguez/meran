package C4::Modelo::DB::Object::AutoBase2;

use base 'Rose::DB::Object';

use C4::Modelo::DB::AutoBase1;

sub init_db { C4::Modelo::DB::AutoBase1->new }

1;
