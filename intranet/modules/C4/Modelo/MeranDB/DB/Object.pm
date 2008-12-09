package C4::Modelo::MeranDB::DB::Object;

# we can use all the methodes in My::DB
use C4::Modelo::MeranDB::DB;

# this class IS a "Rose::DB::Object"
# and contains all the methodes that 
# Rose::DB::Object does
use base qw(Rose::DB::Object);


# replace the inherited My::DB::Object->init_db 
# with our own My::DB::Object->init_db
sub init_db { C4::Modelo::MeranDB::DB->new }

1;
