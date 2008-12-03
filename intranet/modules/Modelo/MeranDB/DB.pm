package MeranDB::DB;

# this class IS a "Rose::DB"
use base qw(Rose::DB);

# fyi: a "registry" is the information that is
#      used to log in to the database

# methode to insure we do not inherit the
# registry directly from Rose::DB
__PACKAGE__->use_private_registry;

# filling in the registry:
__PACKAGE__->register_db(
      driver   => 'mysql',
      database => 'V3',
      host     => 'localhost',
      username => 'dev',
      password => 'dev',
);

1;
