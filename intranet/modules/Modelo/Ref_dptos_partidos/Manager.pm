package Ref_dptos_partidos::Manager;

# this class IS a "Rose::DB::Object::Manager"
# and contains all the methodes that 
# Rose::DB::Object::Manager does
use base qw(Rose::DB::Object::Manager);

# replace the inherited Products->object_class
# with our own new Product->object_class
# (yes, it just always returns the value 'Product')
sub object_class { 'Ref_dptos_partidos' }

# use the make_manager_methods to generate methodes 
# to manage the objects, the methods are called:
#
#    get_ref_dptos_partidos
#    get_ref_dptos_partidos_iterator
#    get_ref_dptos_partidos_count
#    delete_ref_dptos_partidos_persona
#    update_ref_dptos_partidos_persona
#
__PACKAGE__->make_manager_methods('ref_dptos_partidos');

1;
