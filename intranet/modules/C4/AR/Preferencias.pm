package C4::AR::Preferencias;

#
#Este modulo sera el encargado del manejo de las preferencias del sistema.
#

use strict;
require Exporter;
use C4::Context;
use C4::Date;
use C4::Modelo::PrefPreferenciaSistema;
use C4::Modelo::PrefPreferenciaSistema::Manager;

use vars qw(@EXPORT_OK @ISA),qw($PREFERENCES);

@ISA=qw(Exporter);

@EXPORT_OK=qw(
    &getPreferencia
    &setVariable
    &getValorPreferencia
    &getPreferenciaLike
    &t_guardarVariable
    &t_modificarVariable
    &getMenuPreferences
    &getPreferenciasByArray
);


sub getPreferenciasByArray {
    my $self = shift;

    my ($variables_array)= @_;

    my @filtros;
    my %preferencias_hash;

    foreach my $variable (@$variables_array){

        push (@filtros, (  variable => {eq => $variable} ) );

    }

    my $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [ or  => \@filtros ]);

#     if ($preferencias_array_ref->[0]){
   if ($preferencias_array_ref){

        foreach my $p (@$preferencias_array_ref){
            $preferencias_hash{$p->getVariable} = $p->getValue;
        }

        return \%preferencias_hash;
#         return ($preferencia_array_ref);
    } else{
        return undef;
    }
}


sub getAllPreferencias {
    my $self = shift;

    my @filtros;
    my %preferencias_hash;


    my $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => \@filtros );

#     if ($preferencias_array_ref->[0]){
   if ($preferencias_array_ref){

        foreach my $p (@$preferencias_array_ref){
            $preferencias_hash{$p->getVariable} = $p->getValue;
        }

        return \%preferencias_hash;
    } else{
        return undef;
    }
}


BEGIN
{
    $PREFERENCES = undef;
#     $PREFERENCES = C4::AR::Preferencias::getPreferenciasByArray(['tema_opac', 'tema_intra', 'defaultUI', 'titulo_nombre_ui', 'timeout']);
# $PREFERENCES = C4::AR::Preferencias::getPreferenciasByArray([]);
    $PREFERENCES = C4::AR::Preferencias::getAllPreferencias();
}

sub getMenuPreferences{
    my $self = shift;

    my $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
                                    query => [ variable=> { like => '%showMenuItem_%' }],
                            );
    my %hash;
    foreach my $pref (@$preferencias_array_ref){
        $hash{$pref->getVariable} = $pref->getValue();
    }

    return (\%hash);
}

sub getPreferenciasByCategoria {
    my $self = shift;

    my ($str)=@_;
    my $preferencias_array_ref;
    my $prefTemp = C4::Modelo::PrefPreferenciaSistema->new();
  
    $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
                                        query => [ categoria => { eq => $str }],
                                ); 

    return (scalar($preferencias_array_ref), $preferencias_array_ref);
}

sub getPreferenciaLike {
    my $self = shift;

    my ($str,$orden)=@_;

    my $preferencias_array_ref;
    my @filtros;
    my $prefTemp = C4::Modelo::PrefPreferenciaSistema->new();
  
    $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( 
                                        query => [ variable=> { like => '%'.$str.'%' }],
                                        sort_by => ( $prefTemp->sortByString($orden) ),
                                ); 

    return (scalar($preferencias_array_ref), $preferencias_array_ref);
}


sub getPreferencia {
    my $self        = shift;
    my ($variable)  = @_;

    my $preferencia_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [ variable => { eq => $variable} ]);

    if ($preferencia_array_ref->[0]){
        return ($preferencia_array_ref->[0]);
    } else{
        return undef;
    }
}


sub getPreferenciasByArray {
    my ($variables_array)= @_;

    my @filtros;
    my %preferencias_hash;

    foreach my $variable (@$variables_array){

        push (@filtros, (  variable => {eq => $variable} ) );

    }

    my $preferencias_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [ or  => \@filtros ]);

#     if ($preferencias_array_ref->[0]){
   if ($preferencias_array_ref){

        foreach my $p (@$preferencias_array_ref){
            $preferencias_hash{$p->getVariable} = $p->getValue;
        }

        return \%preferencias_hash;
#         return ($preferencia_array_ref);
    } else{
        return undef;
    }
}

sub getValorPreferencia {
    my $self        = shift;
    my ($variable)  = @_;

    #verifico si se encuentra en la cache, sino se busca de la base
    if (defined $PREFERENCES->{$variable}){
        C4::AR::Debug::debug("getValorPreferencia => VARIABLE ==".$variable."== CACHED!!!!!!!");
        return $PREFERENCES->{$variable};
    }

    C4::AR::Debug::debug("getValorPreferencia => VARIABLE ==".$variable."== NO CACHED!!!!!!!");
    my $preferencia_array_ref = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema( query => [ variable => { eq => $variable} ]);

    if ($preferencia_array_ref->[0]){
        return ($preferencia_array_ref->[0]->getValue);
    } else{
        return 0;
    }
}


=item
guardarVariable
guarda la variable del sistema ingresada.
=cut
sub t_guardarVariable {
    my ($var,$val,$exp,$tipo,$op)=@_;
    
    my $params;
    $params->{'variable'}       = $var;
    $params->{'value'}          = $val;
    $params->{'explanation'}    = $exp;
    $params->{'options'}        = $op;
    $params->{'type'}           = $tipo;

    my $msg_object= C4::AR::Mensajes::create();
    _verificarDatosVariable($params,$msg_object);

    if(!$msg_object->{'error'}){
        my ($preferencia) = C4::Modelo::PrefPreferenciaSistema->new();
        my $db = $preferencia->db;

        $db->{connect_options}->{AutoCommit} = 0;
        $db->begin_work;
    eval {
        $preferencia->agregar($params);
        $db->commit;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP004', 'params' => []} ) ;
    };
    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'SP001','INTRA');
        eval{$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP001', 'params' => []} ) ;
    }
        $db->{connect_options}->{AutoCommit} = 1;
    }
    return ($msg_object);
}

sub setVariable {

    my ($variable, $valor) = @_;
    
    my  $preferencia = C4::Modelo::PrefPreferenciaSistema::Manager->get_pref_preferencia_sistema(query => [variable => {eq => $variable}] );

    if(scalar(@$preferencia) > 0){
        C4::AR::Debug::debug("Preferencias => setVariable => ".$variable." valor => ".$valor);
        C4::AR::Debug::debug("Preferencias => setVariable => ".$variable." valor CACHE => ".$PREFERENCES->{$variable});
        $preferencia->[0]->setValue($valor);
        $PREFERENCES->{$variable} = $valor;
        $preferencia->[0]->save();
    }
}

sub _verificarDatosVariable {
    my($params,$msg_object)=@_;

    my $var= $params->{'variable'};
    my $val= $params->{'value'};
    my $type= $params->{'type'};
    my $exp= $params->{'explanation'};
    my $op= $params->{'options'};

#Se verifica que el no exista ya la variable que se quiere agregar
    if( getPreferencia($var) ){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP005', 'params' => []} ) ;
    }

}

sub t_modificarVariable {
    my ($var, $valor, $expl, $categoria) = @_;
    
    my $params;
    $params->{'value'}          = $valor;
    $params->{'explanation'}    = $expl;
    $params->{'categoria'}      = $categoria;
    my $msg_object              = C4::AR::Mensajes::create();
    my ($preferencia)           = C4::Modelo::PrefPreferenciaSistema->new( variable => $var );
    $preferencia->load();
    my $db                      = $preferencia->db; 

    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;
    eval {
        $preferencia->modificar($params);
        $PREFERENCES->{$params->{'variable'}} = $params->{'value'};
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP003', 'params' => []} ) ;
        $db->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'SP001','INTRA');
        eval{$db->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'SP001', 'params' => []} ) ;
    }

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);
}


sub getConfigVisualizacionOPAC{
    my $self = shift;

    my %hash_config = {};
    $hash_config{'resumido'}            = C4::AR::Preferencias->getValorPreferencia("detalle_resumido") || 0;
    $hash_config{'nivel1_repetible'}    = C4::AR::Preferencias->getValorPreferencia("nivel1_repetible") || 0;
    $hash_config{'perfil_visual'}       = C4::AR::Preferencias->getValorPreferencia("perfil_visual") || 0;

    return (\%hash_config);
}

END { }       # module clean-up code here (global destructor)

1;
__END__
