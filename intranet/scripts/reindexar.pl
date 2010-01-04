#!/usr/bin/perl    
use Sphinx::Manager;

my $mgr = Sphinx::Manager->new({ config_file => '/usr/local/etc/sphinx.conf' });
    
  $mgr->run_indexer('--rotate');