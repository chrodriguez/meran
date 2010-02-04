package C4::Modelo::CatPrefMapeoKohaMarc::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatPrefMapeoKohaMarc;

sub object_class { 'C4::Modelo::CatPrefMapeoKohaMarc' }

__PACKAGE__->make_manager_methods('cat_pref_mapeo_koha_marc');

1;

