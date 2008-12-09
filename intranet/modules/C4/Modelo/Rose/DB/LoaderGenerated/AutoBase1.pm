package Rose::DB::LoaderGenerated::AutoBase1;

use strict;

use base 'Rose::DB';

__PACKAGE__->use_private_registry;

__PACKAGE__->register_db
(
  connect_options => { AutoCommit => 1, ChopBlanks => 1 },
  driver          => 'mysql',
  dsn             => 'dbi:mysql:dbname=V3_newAspect_EINAR;host=localhost',
  password        => 'remoteHOST',
  username        => 'remote',
);

1;
