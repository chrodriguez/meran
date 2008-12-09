package Usr_ref_estados::Manager;

# this class IS a "Rose::DB::Object::Manager"
# and contains all the methodes that 
# Rose::DB::Object::Manager does
use base qw(Rose::DB::Object::Manager);

# replace the inherited Products->object_class
# with our own new Product->object_class
# (yes, it just always returns the value 'Product')
sub object_class { 'Usr_ref_estados' }

# use the make_manager_methods to generate methodes 
# to manage the objects, the methods are called:
#
#    get_usr_persona
#    get_usr_persona_iterator
#    get_usr_persona_count
#    delete_usr_persona
#    update_usr_persona
#
__PACKAGE__->make_manager_methods('usr_ref_estados');

1;
