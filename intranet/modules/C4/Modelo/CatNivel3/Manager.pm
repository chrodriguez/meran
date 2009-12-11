package C4::Modelo::CatNivel3::Manager;

use strict;

use base qw(Rose::DB::Object::Manager);

use C4::Modelo::CatNivel3;
use C4::Modelo::DB::Object::AutoBase2;
sub object_class { 'C4::Modelo::CatNivel3' }

__PACKAGE__->make_manager_methods('cat_nivel3');

# sub get_min_of_field{
# # REQUIERE PASAR ID_UI_ORIGEN COMO TERCER PARAMETRO
# #    my($class) = shift;
#    my($field, $id_ui_origen) = @_;
#    my $meta = C4::Modelo::CatNivel3->meta;
#    my $sql = 'SELECT MIN('.$field.') AS min FROM ' . $meta->table.' WHERE '.$field.' IS NOT NULL AND ('.$field.' <> "") AND (id_ui_origen = ?);';
#    my $min;
#    
# #    eval{
# 
#          my $dbh = C4::Modelo::CatNivel3->new();
#             $dbh = $dbh->db;
# # print "\n\n\nllego\n\n\n";
#          C4::AR::Debug::_printHASH($dbh);
#          $dbh->{'RaiseError'} = 1;
#          my $sth = $dbh->prepare($sql);
# ;
# 
#          $sth->execute($id_ui_origen);
# 
#          $min = ($sth->fetchrow_hashref)->{'min'};
#          $dbh->disconnect;
#          return($min);
# #    };
# }

1;

