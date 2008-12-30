package C4::Modelo::DB::AutoBase1;

use strict;
use C4::Context;
use base 'Rose::DB';

my $context = new C4::Context;

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db
(
  connect_options => { AutoCommit => 1 },
  driver          => 'mysql',
  dsn             => 'dbi:mysql:dbname='.C4::Context->config("database").';host='.C4::Context->config("hostname"),
  password        => C4::Context->config("pass"),
  username        => C4::Context->config("user"),
);

1;
