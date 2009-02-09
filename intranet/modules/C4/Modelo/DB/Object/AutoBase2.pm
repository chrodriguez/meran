package C4::Modelo::DB::Object::AutoBase2;

use base 'Rose::DB::Object';

use C4::Modelo::DB::AutoBase1;
use base qw(Rose::DB::Object::Helpers);

sub init_db { C4::Modelo::DB::AutoBase1->new}

=item
Imprime el nombre de la clase
=cut
sub toString{
    my ($self)=shift;

    return $self->meta->class;
}

=item

    CHAIN OF RESPONSIBILITY

    HandleReques = createFromAlias, implementado como un  TemplateMethod compuesto por 

    createFromAlias (TemplateMethod), nextChain, nextMember (HooksMethods)

=cut
sub createFromAlias{
    my ($self)=shift;
    my $classAlias = shift;
    if ($classAlias eq $self->getAlias){
        return ($self);
    }else
        {
            return($self->nextChain($classAlias));
        }
}

sub nextChain{
    my ($self)=shift;
    my $classAlias = shift;
    if ($self->lastTable){
        return ($self->default);
    }
    else
        {
            return($self->nextMember->createFromAlias($classAlias));
        }
}

sub getCamposArray{
    my ($self)=shift;
    my $arregloJSON;
# open(A, ">>/tmp/debug.txt");
# print A "desde getCamposArray\n";
    my $camposArray = $self->meta->columns;
     foreach my $campo (@$camposArray){
# print A "foreach=> ".$campo."\n";
## FIXME ."" se esta concatenando $campo con "" pq sino se rompe, cosa de locos
        push (@arregloJSON, {'campo' => $campo."" });
    }

# close(A);
    return(\@arregloJSON);
}

sub getCampos{
    my ($self)=shift;
    my $fieldsString = &C4::AR::Utilidades::joinArrayOfString($self->meta->columns);
    return($fieldsString);
}

sub log{
    my ($self)=shift;
    use C4::AR::Debug;
    my ($data, $metodoLlamador)=@_;

    C4::AR::Debug::log($self, $data, $metodoLlamador);
}

sub sortByString{

    my ($self)=shift;
    my ($campo)=@_;
    my $fieldsString = $self->getCampos();
# $self->log($self->meta->columns,'sortByString => columns');

    my $index = rindex $fieldsString,$campo;
    if ($index != -1){
        return ($campo);
    }
    else
        {
            return ($self->defaultSort);
        }
}


=item
$self->meta


       key: column_db_value_hash_keys => value:
       key: nonlazy_column_names_string_sql => value:
       key: db => value:
       key: nonlazy_column_mutator_method_names => value:
       key: table => value: usr_persona
       key: delete_sql => value:
       key: update_sql_with_inlining_start => value:
       key: allow_auto_initialization => value: 0
       key: primary_key_sequence_names => value:
       key: select_nonlazy_columns_sql => value:
       key: column_rw_method_names => value: ARRAY(0xa4abef0)
       key: insert_sql => value:
       key: primary_key => value: id_persona
       key: nonpersistent_column_mutator_method_names => value:
       key: column_undef_overrides_default => value:
       key: insert_columns_placeholders_sql => value:
       key: nonpersistent_column_accessor_method => value:
       key: default_smart_modification => value: 0
       key: num_columns => value:
       key: load_sql => value:
       key: fq_table_sql => value:
       key: column_names_sql => value:
       key: has_lazy_columns => value: 0
       key: column_names_string_sql => value:
       key: load_all_sql => value:
       key: column_mutator_method => value: HASH(0xa491988)
       key: update_all_sql => value:
       key: db_id => value: defaultdefault
       key: unique_keys => value: ARRAY(0xa437c20)
       key: get_column_sql_tmpl => value:
       key: column_name_to_method_name_mapper => value: 0
       key: insert_changes_only_sql_prefix => value:
       key: select_columns_sql => value:
       key: original_class => value: Rose::DB::Object::Metadata
       key: dbi_requires_bind_param => value:
       key: primary_key_column_mutator_names => value:
       key: fq_table => value:
       key: nonpersistent_column_names => value: ARRAY(0xa464bc8)
       key: nonpersistent_columns_ordered => value: ARRAY(0xa464e44)
       key: nonpersistent_column_accessor_method_names => value: ARRAY(0xa464bd4)
       key: nonlazy_column_db_value_hash_keys => value:
       key: column_names => value: ARRAY(0xa49724c)
       key: convention_manager => value: Rose::DB::Object::ConventionManager=HASH(0xa3f9dcc)
       key: column_accessor_method => value: HASH(0xa491940)
       key: auto_prime_caches => value: 0
       key: columns => value: HASH(0xa4617dc)
       key: class => value: C4::Modelo::UsrPersona
       key: nonlazy_column_names => value:
       key: foreign_keys => value: HASH(0xa464bec)
       key: nonpersistent_column_mutator_method => value:
       key: update_sql_prefix => value:
       key: relationships => value: HASH(0xa3f9e08)
       key: nonlazy_column_accessor_method_names => value:
       key: select_columns_string_sql => value:
       key: is_initialized => value: 1
       key: auto_load_related_classes => value: 1
       key: fq_primary_key_sequence_names => value:
       key: columns_ordered => value: ARRAY(0xa4617e8)
       key: select_nonlazy_columns_string_sql => value:
       key: primary_key_column_accessor_names => value:
       key: insert_sql_with_inlining_start => value:
       key: column_accessor_method_names => value: ARRAY(0xa4ac094)
       key: column_mutator_method_names => value: ARRAY(0xa4ac31c)
       key: primary_key_column_db_value_hash_keys => value:
       key: is_auto_initializating => value: 0
       key: column_rw_method => value: HASH(0xa491acc)
       key: lazy_column_names => value:
       key: method_columns => value:

=cut


1;
