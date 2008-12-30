package C4::Modelo::DB::AutoBase1;

use strict;
use C4::Context;
use base 'Rose::DB';

my $context = new C4::Context;

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db
(
  connect_options => { AutoCommit => 1 },
  driver          =>  "mysql",
  database 	  => $context->config("database"),
  host     	  => $context->config("hostname"),
  password        => $context->config("pass"),
  username        => $context->config("user"),
 );

1;
