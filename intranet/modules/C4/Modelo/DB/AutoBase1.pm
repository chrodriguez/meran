package C4::Modelo::DB::AutoBase1;

use strict;

use base 'Rose::DB';
    use C4::Context;
__PACKAGE__->use_private_registry;

    my $context = new C4::Context;
    
    my $driverDB;
    my $database;
    my $hostname;
    my $user;
    my $pass;
  
 if (defined($context)){
    $driverDB = 'mysql';
    $database = $context->config('database');
    $hostname = $context->config('hostname');
    $user = $context->config('user');
    $pass = $context->config('pass');
}
        
__PACKAGE__->register_db
(
    
  connect_options => {RaiseError => 1},
  driver          => $driverDB,
  dsn             => "dbi:mysql:dbname=".$database.";host=".$hostname,
  username        => $user,
  password        => $pass,
);

1;
