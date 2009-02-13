package C4::AR::Usuarios;

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Validator;
use C4::AR::Issues;
use C4::Modelo::UsrPersona;
use C4::Modelo::UsrPersona::Manager;
use C4::Modelo::UsrEstado;
use C4::Modelo::UsrEstado::Manager;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw( 

    &ListadoDePersonas
    &esRegular
    &estaSancionado
    &llegoMaxReservas
    &getBorrower
    &getBorrowerInfo
    &buscarBorrower
    &obtenerCategorias
    &mailIssuesForBorrower
    &personData
    &BornameSearchForCard
    &NewBorrowerNumber
    &findguarantees
    &updateOpacBorrower
    &obtenerCategoriaBorrower
    &t_cambiarPassword
    &t_cambiarPermisos
    &t_addBorrower
    &t_updateBorrower
    &t_eliminarUsuario
    &t_addPerson
    &t_delPersons
    &existeUsuario
    &getSocioInfo
);


sub t_delPersons {  
    my($persons_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();

    # enable transactions, if possible
    $dbh->{AutoCommit} = 0;  
    $dbh->{RaiseError} = 1;

    eval {
        _delPersons($persons_array_ref, $msg_object);   
        $dbh->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
        eval {$dbh->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => []} ) ;
    }
    $dbh->{AutoCommit} = 1;

    return ($msg_object);
}

sub _verificarInfoDelPerson {
    my ($person, $msg_object)=@_;
    my $dbh = C4::Context->dbh;

    my $sth=$dbh->prepare(" SELECT * 
                FROM persons 
                WHERE personnumber=?");
    $sth->execute($person);
    my $personData=$sth->fetchrow_hashref;

    if (!$personData) { 
    # El borrower no se encuentra habilitado
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U350', 'params' => [$personData->{'cardnumber'}]} ) ;
    }
    
}

sub _delPersons {
    my ($persons_array_ref, $msg_object)=@_;
    
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                FROM persons 
                WHERE personnumber=?");

    foreach my $person (@$persons_array_ref){
        $sth->execute($person);
        my $personData=$sth->fetchrow_hashref;

        _verificarInfoDelPerson($person,$msg_object);

        if (!$msg_object->{'error'}) { 
        # Si no tiene borrowernumber no esta habilitado
            _eliminarUsuario($personData->{'borrowernumber'});
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$personData->{'cardnumber'}]}) ;
        }
    }
}

sub t_addPersons {
    
    my($persons_array_ref)=@_;
    my $dbh = C4::Context->dbh;

    my $msg_object;

    # enable transactions, if possible
    $dbh->{AutoCommit} = 0;  
    $dbh->{RaiseError} = 1;

    eval {
        ($msg_object)= addPersons($persons_array_ref);  
        $dbh->commit;
    };

    if ($@){
        #Se loguea error de Base de Datos
        &C4::AR::Mensajes::printErrorDB($@, 'B425','INTRA');
        eval {$dbh->rollback};
        #Se setea error para el usuario
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U348', 'params' => []});
    }

    $dbh->{AutoCommit} = 1;

    
    return ($msg_object);
}

sub addPersons {
    my ($persons)=@_;
    
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                FROM persons 
                WHERE personnumber=?");

    my $msg_object= C4::AR::Mensajes::create();
    
    foreach my $person (@$persons){
        $sth->execute($person);
        my $borrowerData=$sth->fetchrow_hashref;

        _verificarInfoAddPerson($borrowerData,$msg_object);

        if(!$msg_object->{'error'}){
            my $borrowernumber= addBorrower($borrowerData);
            #Se agregar en borrower
            #Se actualiza la persona con el borrowernumber
            my $sth3=$dbh->prepare("UPDATE persons 
                        SET borrowernumber=? 
                        WHERE personnumber=?");
            $sth3->execute($borrowernumber, $person);
            $sth3->finish;
        
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U347', 'params' => [$borrowerData->{'cardnumber'}]} ) ;
        }

    }# end foreach my $person (@$persons)

    return ($msg_object);
}



sub t_addBorrower {
    
    my($params)=@_;
    my $dbh = C4::Context->dbh;

#   my %msg;    
    my $msg_object= C4::AR::Mensajes::create();
    _verificarDatosBorrower($params,$msg_object);

    if(!$msg_object->{'error'}){
    #No hay error
        # enable transactions, if possible
        $dbh->{AutoCommit} = 0;  
        $dbh->{RaiseError} = 1;
    
        eval {
            my $borrowernumber= addBorrower($params);   
            $dbh->commit;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U329', 'params' => []});
                    
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
            eval {$dbh->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
        }
        $dbh->{AutoCommit} = 1;

    }

    return ($msg_object);
}

sub agregarPersona{
    my ($params)=@_;
    
    my $msg_object= C4::AR::Mensajes::create();
    my ($person) = C4::Modelo::UsrPersona->new();
    my $db = $person->db;
  
    $params->{'iniciales'} = "DGR";
    #genero un estado de ALTA para la persona para una fuente de informacion
    $db->{connect_options}->{AutoCommit} = 0;
    $db->begin_work;

    eval{
        $person->agregar($params);
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U329', 'params' => []});
        $db->commit;
    };

    if ($@){
         &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
         $db->rollback;
    }

    $db->{connect_options}->{AutoCommit} = 1;

    return ($msg_object);

}
   
sub habilitarPersona{

    my ($id_socios_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();
    
    eval {
        foreach my $socio (@$id_socios_array_ref){
            my ($partner) = C4::Modelo::UsrSocio->new(id_socio => $socio);
            $partner->load();
            $partner->activar;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U347', 'params' => [$partner->getNro_socio]});
        }
     };
    
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
     }

    return ($msg_object);

}

sub deshabilitarPersona{

    my ($id_socios_array_ref)=@_;
    my $dbh = C4::Context->dbh;
    my $msg_object= C4::AR::Mensajes::create();
    
    eval {
        foreach my $socio (@$id_socios_array_ref){
            my ($partner) = C4::Modelo::UsrSocio->new(id_socio => $socio);
            $partner->load();
            $partner->desactivar;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U363', 'params' => [$partner->getNro_socio]});
        }
     };
    
     if ($@){
         #Se loguea error de Base de Datos
         &C4::AR::Mensajes::printErrorDB($@, 'B423',"INTRA");
         #Se setea error para el usuario
         $msg_object->{'error'}= 1;
         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U330', 'params' => []} ) ;
     }

    return ($msg_object);

}

sub addBorrower {

    my ($params)=@_;
    my $dateformat = C4::Date::get_date_format();
    my $dbh = C4::Context->dbh;

    
    my $query=" INSERT INTO borrowers 
            (title , expiry , cardnumber , sex , ethnotes , streetaddress , faxnumber,
            firstname , altnotes , dateofbirth , contactname , emailaddress , textmessaging,
            dateenrolled , streetcity , altrelationship , othernames , phoneday,
            categorycode , city , area , phone , borrowernotes , altphone , surname,
            initials , ethnicity , physstreet , branchcode , zipcode , homezipcode,
            documenttype , documentnumber , lastchangepassword , changepassword , studentnumber)  
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NULL,?,?)";
    
    my $sth=$dbh->prepare($query);
    
    $params->{'dateofbirth'}=format_date_in_iso($params->{'dateofbirth'},$dateformat);
    $params->{'changepassword'}= $params->{'changepassword'}||1; #si no viene nada por defecto debe cambiar la password

    $sth->execute(  $params->{'title'},$params->{'expiry'},$params->{'cardnumber'},
            $params->{'sex'},$params->{'ethnotes'},$params->{'streetaddress'},$params->{'faxnumber'},
            $params->{'firstname'},$params->{'altnotes'},$params->{'dateofbirth'},$params->{'contactname'},$params->{'emailaddress'},
            $params->{'textmessaging'},$params->{'joining'},$params->{'streetcity'},$params->{'altrelationship'},
            $params->{'othernames'},$params->{'phoneday'},$params->{'categorycode'},$params->{'city'},$params->{'area'},
            $params->{'phone'},$params->{'borrowernotes'},$params->{'altphone'},$params->{'surname'},$params->{'initials'},
            $params->{'ethnicity'},$params->{'physstreet'},$params->{'branchcode'},$params->{'zipcode'},$params->{'homezipcode'},
            $params->{'documenttype'},$params->{'documentnumber'},
            $params->{'changepassword'},$params->{'studentnumber'}
        );

    $sth->finish;

    #obtengo el borrowernumber recien generado
    my $sth3=$dbh->prepare(" SELECT LAST_INSERT_ID() ");
    $sth3->execute();
    my $borrowernumber= $sth3->fetchrow;

    # Curso de usuarios#
    if (C4::Context->preference("usercourse"))  {
        my $sql2="";
        if ($params->{'usercourse'} eq 1){
            $sql2= "UPDATE borrowers
                SET usercourse=NOW() 
                WHERE borrowernumber=? 
                    AND 
                      usercourse IS NULL ; ";
        }
        else{
            $sql2= "UPDATE borrowers 
                SET usercourse=NULL 
                WHERE borrowernumber=? ;";
        }

        my $sth3=$dbh->prepare($sql2);
        $sth3->execute();
        $sth3->finish;
    }

    return $borrowernumber;
}


sub _verificarInfoAddPerson {
    my ($params, $msg_object)=@_;

    my $dbh = C4::Context->dbh;
    my $error= 0;
    my $habilitar_irregulares= C4::Context->preference("habilitar_irregulares");

    #Verificar que ya no exista como borrower
    my $sth2=$dbh->prepare("SELECT * 
                FROM borrowers 
                WHERE cardnumber=?");
    $sth2->execute($params->{'cardnumber'});
    my $borrower= $sth2->fetchrow_hashref;

    if($borrower){
        #ya existe el borrower      
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U346', 'params' => [$params->{'cardnumber'}]} ) ;
    }
    #Se verifica que el usuario sea regular puede habilitar usurios irregulares??
    elsif ( !($msg_object->{'error'}) && ($habilitar_irregulares eq 0)&&($params->{'regular'} eq 0)&&($params->{'categorycode'} eq 'ES')){
        # No es regular y no se puede habilitar regulares
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U349', 'params' => [$params->{'cardnumber'}]} ) ;
    }
}


sub resetPassword {
    
    my($params)=@_;
    my $id_socio = $params->{'id_socio'};
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = getSocioInfo($id_socio);
    
# FIXME esa funcion debe cambiar, porque cambiaron los parametros
#     $msg_object = _verficarEliminarUsuario($params,$msg_object);

        eval {
            $socio->resetPassword;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U359', 'params' => [$socio->getNro_socio]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U360', 'params' => [$socio->getNro_socio]} ) ;
        }

    return ($msg_object);
}

# Esta función es el manejador de transacción para eliminarUsuario. Recibe una hash conteniendo los campos:
#  borrowernumber y usuario.
sub eliminarUsuario {
    
    my($id_socio)=@_;
    my $msg_object= C4::AR::Mensajes::create();
    my $socio = getSocioInfo($id_socio);
# FIXME esa funcion debe cambiar, porque cambiaron los parametros
#     $msg_object = _verficarEliminarUsuario($params,$msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        eval {
            $socio->desactivar;
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U320', 'params' => [$socio->getNro_socio]} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B422','INTRA');
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U319', 'params' => [$socio->getNro_socio]} ) ;
        }
    }

    return ($msg_object);
}

#eliminarUsuario recibe un numero de borrower y lo que hace es deshabilitarlos de la lista de miembros de la biblioteca, se invoca desde eliminar borrower y desde ls funcion delmembers 


sub _eliminarUsuario{
    my ($borrowernumber)=@_;
    
    my $dbh = C4::Context->dbh;

    #   $sth=$dbh->prepare("Insert into deletedborrowers values (".("?,"x(scalar(@data)-1))."?)");
    #   $sth->execute(@data);
    #   $sth->finish;
    my $sth=$dbh->prepare("DELETE FROM borrowers
                   WHERE borrowernumber=?
                  ");
    $sth->execute($borrowernumber);
    $sth->finish;

# FIXME cuando se borra la reserva, habria que unificar todo, para que se conceda esa reserva al siguiente en la cola.
    $sth=$dbh->prepare("DELETE FROM circ_reserva
                WHERE borrowernumber=?
               ");
    $sth->execute($borrowernumber);
    $sth->finish;

    $sth=$dbh->prepare("UPDATE persons 
                SET borrowernumber=NULL 
                WHERE borrowernumber=?
               ");
    $sth->execute($borrowernumber);
    $sth->finish;
}

# Esta función verifica que un usuario exista en la DB. Recibe una hash conteneniendo: borrowernumber y  usuario.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
# FIXME fijarse que aca no se checkea nada, por ejemplo si tiene reservas, libros en su poder, etc...

sub _verficarEliminarUsuario {
    my($params,$msg_object)=@_;

    my ($cantVencidos,$cantIssues) = C4::AR::Issues::cantidadDePrestamosPorUsuario($params->{'borrowernumber'});

    my ($cantidadTotalDePrestamos) = $cantVencidos + $cantIssues;

    
    if( !($msg_object->{'error'}) && !( _existeUsuario($params->{'borrowernumber'})) ){
    #se verifica la existencia del usuario, que ahora no existe
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U321', 'params' => [$params->{'cardnumber'}]} ) ;
    } 
    elsif ($cantidadTotalDePrestamos > 0){
        #se verifica que no tenga prestamos activos
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U351', 'params' => [$params->{'cardnumber'}]} ) ;
    }

    

    elsif ($params->{'loggedInUser'} eq $params->{'borrowernumber'}){
    #   Se verifica que el usuario loggeado no sea el mismo que se va a eliminar
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U352', 'params' => [$params->{'cardnumber'}]} ) ;
    }
            
    return ($msg_object);
}

=item
Esta funcion verifica si existe el usuario o no en la base, devuelve 0 = NO EXISTE, 1 (o mas) = EXISTE
=cut
sub _existeUsuario {
    my ($borrowernumber)=@_;

    my $dbh = C4::Context->dbh;

    my $sth=$dbh->prepare("SELECT count(*) 
                   FROM borrowers 
                   WHERE borrowernumber=?
                  ");
    $sth->execute($borrowernumber);

    return $sth->fetchrow_array();
}




sub existeUsuario {
    my ($borrowernumber)=@_;
    if (_existeUsuario($borrowernumber)){
        return 1;
    }
    else{
        return 0;
        }
}
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
sub t_cambiarPermisos {
    my($params)=@_;

## FIXME ver si falta verificar algo!!!!!!!!!!
    my $msg_object= C4::AR::Mensajes::create();

    if(!$msg_object->{'error'}){
    #No hay error
        my  $socio = C4::Modelo::UsrSocio->new(id_socio => $params->{'id_socio'});
        $socio->load();
        my $db= $socio->db;
        # enable transactions, if possible
        $db->{connect_options}->{AutoCommit} = 0;
    
        eval {
            $socio->cambiarPermisos($params);  
            $db->commit;
            #se cambio el permiso con exito
            $msg_object->{'error'}= 0;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U317', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B421',"INTRA");
            eval {$db->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U331', 'params' => []} ) ;
        }

        $db->{connect_options}->{AutoCommit} = 1;

    }

    return ($msg_object);
}

#  Funcion que recibe una hash con newpassword y  newpassword1, para checkear que sean iguales. Retortan 0 en caso de exito y 1 en error.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
sub _verificarPassword {
    my($params)=@_;

    my ($msg_object)= &C4::AR::Validator::checkPassword($params->{'newpassword'});


    if( !($msg_object->{'error'}) && ( $params->{'newpassword'} ne $params->{'newpassword1'} ) ){
    #las password no coinciden
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U315', 'params' => [$params->{'cardnumber'}]} ) ;
    }

    if ( !($msg_object->{'error'}) && ( C4::Auth::getSessionIdSocio($params->{'session'}) != $params->{'id_socio'} ) ){
    #no coincide el usuario logueado con el usuario al que se le va a cambiar la password
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U362', 'params' => [$params->{'nro_socio'}]} ) ;
    }

    return ($msg_object);
}


# Controlador de transacción para persistir el cambio de password de un usuario. Recibe una hash con todos los datos del usuario.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN
## FIXME demasiados IF y ELSE!!!!
# sub cambiarPassword {
#     my($params)=@_;
# 
#     my ($msg_object)= _verificarPassword($params);
#     if ( C4::Auth::getSessionIdSocio($params->{'session'}) == $params->{'id_socio'} ){
#             if(!$msg_object->{'error'}){ #porque NO hay error...
#             #No hay error
#                 my  $socio = C4::Modelo::UsrSocio->new(id_socio => $params->{'id_socio'});
#                 if ($socio->load()){
#                     my $actualPassword = $socio->getPassword;
# 
#                     if ( ($params->{'changePassword'})&&($socio->getChange_password) ){
#                     #es un cambio forzado de la password, se obliga al usuario a cambiar la password, no se compara con la pass actual
#                         my $newPassword = $params->{'newpassword'};
#                         $socio->cambiarPassword($newPassword);
#                         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
#                     }
#                     else
#                         {
#                             $msg_object->{'error'}= 1;
#                             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
#                         }
#                   
#                     if ( $actualPassword eq C4::Auth::md5_base64($params->{'actualPassword'}) ){
#                     #es un cambio voluntario de la password
#                         my $newPassword = $params->{'newpassword'};
#                         $socio->cambiarPassword($newPassword);
#                         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
#                     }
#                     else
#                         {
#                             $msg_object->{'error'}= 1;
#                             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
#                         }
#                 }
#                 else
#                 {
#                         #Se setea error para el usuario
#                         $msg_object->{'error'}= 1;
#                         C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
#                     }
#             }
#             else
#                 {
#                     $msg_object->{'error'}= 1;
#                     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
#                 }
#     }
#     else
#         {
#             $msg_object->{'error'}= 1;
#             C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U362', 'params' => [$params->{'nro_socio'}]} ) ;
#         }
# close(A);
#     return ($msg_object);
# }


sub cambiarPassword {
    my($params)=@_;

    my ($msg_object)= _verificarPassword($params);
   
    if(!$msg_object->{'error'}){
    #No hay error
        my  $socio = C4::Modelo::UsrSocio->new(id_socio => $params->{'id_socio'});
        if ($socio->load()){
            my $actualPassword = $socio->getPassword;
            my $cambioDePasswordForzado= 1;
            if( ($params->{'changePassword'} eq 1)&&($socio->getChange_password) ){$cambioDePasswordForzado= 1;}

            if ( $cambioDePasswordForzado ){
            #es un cambio forzado de la password, se obliga al usuario a cambiar la password, no se compara con la pass actual
                my $newPassword = $params->{'newpassword'};
                $socio->cambiarPassword($newPassword);
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
            }
            elsif ( $actualPassword eq C4::Auth::md5_base64($params->{'actualPassword'}) && !$cambioDePasswordForzado ){
            #es un cambio voluntario de la password
                my $newPassword = $params->{'newpassword'};
                $socio->cambiarPassword($newPassword);
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U312', 'params' => [$params->{'nro_socio'}]} ) ;
            }
            else
                {
                    $msg_object->{'error'}= 1;
                    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U361', 'params' => [$params->{'nro_socio'}]} ) ;
                }
        }
        else
        {
                #Se setea error para el usuario
                $msg_object->{'error'}= 1;
                C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U313', 'params' => [$params->{'nro_socio'}]} ) ;
            }
    }
   
close(A);
    return ($msg_object);
}



# Cambia el password del usuario. Recibe como parámetro una hash con todos sus datos.
# Retorna $error = 1:true // 0:false * $codMsg: codigo de Mensajes.pm * @paraMens * EN ESE ORDEN

# sub _cambiarPassword{
#     my ($params, $msg_object) = @_;
#     my $dbh = C4::Context->dbh;
#     
#     my %env;
#     my ($borrower,$flags)= C4::Circulation::Circ2::getpatroninformation($params->{'usuario'},'');
# 
#     $params->{'userid'}= $borrower->{'userid'};
#     $params->{'surename'}= $borrower->{'surename'};
#     $params->{'firstname'}= $borrower->{'firstname'};
# 
#     my $digest= C4::Auth::md5_base64($params->{'newpassword'});
#     my $dbh=C4::Context->dbh;
#     #Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
#     #Then we need to tell the user and have them create a new one.
# ## FIXME el userid parece que no se usa!!!!!!!!!!!!!    
#     my $sth2=$dbh->prepare("    SELECT * 
#                     FROM borrowers 
#                     WHERE userid=? AND borrowernumber != ?");
# 
#     $sth2->execute($params->{'userid'},$params->{'usuario'});
#     
#     if ( ($params->{'userid'} ne '') && ($sth2->fetchrow) ) {
#     #ya existe el userid
#         $msg_object->{'error'}= 1;
#         C4::AR::Mensajes::add(  $msg_object, {  'codMsg'=> 'U311', 
#                             'params' => [$params->{'userid'}, $params->{'surename'}, $params->{'firstname'}]} ) ;
# 
#     }else {
#         #Esta todo bien, se puede actualizar la informacion
#         my $sth=$dbh->prepare(" UPDATE borrowers 
#                         SET userid=?, password=? 
#                     WHERE borrowernumber=? ");
# 
#         $sth->execute($params->{'userid'}, $digest, $params->{'usuario'});
#         
#         my $sth3=$dbh->prepare("    SELECT cardnumber 
#                         FROM borrowers 
#                         WHERE borrowernumber = ? ");
# 
#         $sth3->execute($params->{'usuario'});
# 
#         if (my $cardnumber= $sth3->fetchrow) {
#         #Se actualiza el ldap
# ## FIXME no se para que se le pasa el $template
#             my $template; 
#             if (C4::Membersldap::addupdateldapuser($dbh,$cardnumber,$digest,$template)){
# #               $template->param(errorldap => 1);
#             }
#         }
# 
#     }
# 
# #   return ($error,$codMsg,$paraMens);
#     return ($msg_object);
# }


# Como todos los manejadores de transacciones


# Esta funcion se utiliza para validar todos los datos de un borrower nuevo o modificación de uno existente.
# Recibe un hash con todos sus datos.
# Retorna $error (como siempre, al reves {1 true}) y un $codMsg, en ese orden
sub _verificarDatosBorrower{

    my ($data, $msg_object)=@_;
    my $actionType = $data->{'actionType'};
    my $checkStatus;

    my $emailAddress = $data->{'email'};
    
    if (!($msg_object->{'error'}) && (!(&C4::AR::Validator::isValidMail($emailAddress)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U332', 'params' => []} ) ;
    }
    
    #### EN ESTE IF VAN TODOS LOS CHECKS PARA UN NUEVO BORROWER, NO PARA UN UPDATE
    if ($actionType eq "new"){

        my $cardNumber = $data->{'nro_socio'};
        if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($cardNumber)))){
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U333', 'params' => []} ) ;
        }
    }

    #### FIN NUEVO BORROWER's CHECKS
    my $surname = $data->{'apellido'};
    if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($surname)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U334', 'params' => []} ) ;
    }

    my $firstname = $data->{'nombre'};
    if (!($msg_object->{'error'}) && (!(&C4::AR::Utilidades::validateString($firstname)))){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U335', 'params' => []} ) ;
    }

    
    my $documentnumber = $data->{'nro_documento'};
    $checkStatus = &C4::AR::Validator::isValidDocument($data->{'documenttype'},$documentnumber);
    if (!($msg_object->{'error'}) && ( $checkStatus == 0)){
        $msg_object->{'error'}= 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U336', 'params' => []} ) ;
    }
}
    




sub actualizarSocio {
    use C4::Modelo::UsrSocio::Manager;
    my($params)=@_;
    $params->{'actionType'} = "update";
    my $dbh = C4::Context->dbh;

    my $msg_object= C4::AR::Mensajes::create();

    _verificarDatosBorrower($params, $msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
    
        eval {
            my $socio = C4::Modelo::UsrSocio->new(nro_socio => $params->{'nro_socio'});
            $socio->load();
            $socio->modificar($params);
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U338', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B424',"INTRA");
            eval {$dbh->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U339', 'params' => []} ) ;
        }
        $dbh->{AutoCommit} = 1;

    }

    return ($msg_object);
}


sub t_updateBorrower {
    
    my($params)=@_;
    $params->{'actionType'} = "update";
    my $dbh = C4::Context->dbh;

    my $msg_object= C4::AR::Mensajes::create();

    _verificarDatosBorrower($params, $msg_object);

    if(!$msg_object->{'error'}){
    #No hay error

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
    
        eval {
            updateBorrower($params);        
            $dbh->commit;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U338', 'params' => []} ) ;
        };
    
        if ($@){
            #Se loguea error de Base de Datos
            &C4::AR::Mensajes::printErrorDB($@, 'B424',"INTRA");
            eval {$dbh->rollback};
            #Se setea error para el usuario
            $msg_object->{'error'}= 1;
            C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'U339', 'params' => []} ) ;
        }
        $dbh->{AutoCommit} = 1;

    }

    return ($msg_object);
}

sub updateBorrower {
    my ($params)=@_;

    my $dateformat = C4::Date::get_date_format();
    my $dbh = C4::Context->dbh;

    my $query=" UPDATE borrowers 

            SET     title=? , expiry=? , sex=? , ethnotes=? , streetaddress=?,
                faxnumber=? , firstname=? , altnotes=? , dateofbirth=?,
                contactname=? , emailaddress=? , textmessaging=? , dateenrolled=?,
                streetcity=? , altrelationship=? , othernames=? , phoneday=?,
                categorycode=? , city=? , area=? , phone=? , borrowernotes=?,
                altphone=? , surname=? , initials=? , physstreet=?,
                ethnicity=? , gonenoaddress=? , lost=? , debarred=? , branchcode =?,
                zipcode =? , homezipcode=? , documenttype =? , documentnumber=?,
                changepassword=? , studentnumber=?
            
            WHERE borrowernumber=? ";

    my $sth=$dbh->prepare($query);

    $params->{'dateofbirth'}=format_date_in_iso($params->{'dateofbirth'},$dateformat);
    
    $sth->execute(      $params->{'title'},$params->{'expiry'},$params->{'sex'},$params->{'ethnotes'},$params->{'streetaddress'},
                $params->{'faxnumber'},$params->{'firstname'},$params->{'altnotes'},$params->{'dateofbirth'},
                $params->{'contactname'},$params->{'emailaddress'},$params->{'textmessaging'},$params->{'joining'},
                $params->{'dstreetcity'},$params->{'altrelationship'},$params->{'othernames'},$params->{'phoneday'},
                $params->{'categorycode'},$params->{'city'},$params->{'area'},$params->{'phone'},$params->{'borrowernotes'},
                $params->{'altphone'},$params->{'surname'},$params->{'initials'},$params->{'physstreet'},
                $params->{'ethnicity'},$params->{'gonenoaddress'},$params->{'lost'},$params->{'debarred'},$params->{'branchcode'},$params->{'zipcode'},$params->{'homezipcode'},$params->{'documenttype'},$params->{'documentnumber'},
                $params->{'changepassword'},$params->{'studentnumber'},$params->{'borrowernumber'}
    );
    
    $sth->finish;
    

    # Curso de usuarios#
    if (C4::Context->preference("usercourse"))  {
        my $sql2="";
        if ($params->{'usercourse'} eq 1){
            $sql2= "UPDATE borrowers 
                SET usercourse=NOW() 
                WHERE borrowernumber=? 
                    AND 
                      usercourse is NULL ; ";}
        else{
            $sql2= "UPDATE borrowers 
                SET usercourse=NULL 
                WHERE borrowernumber=? ;";
        }

        my $sth3=$dbh->prepare($sql2);
        $sth3->execute($params->{'borrowernumber'});
        $sth3->finish;
    }
    ####################
}


# Devuelve todos los borrowers (borrowernumber, surname, firstname, cardnumber, documentnumber, studentnumber )
# que cumplan con el string pasado como parámetro. Los resultados son devueltos como un arreglo de hash.

sub buscarBorrower{
    my ($busqueda) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;
    $busqueda .= "%";

    my $query= "    SELECT borrowernumber, surname, firstname, cardnumber, documentnumber, studentnumber 
            FROM borrowers
            WHERE   (surname LIKE ?) OR (firstname LIKE ?)
                OR (cardnumber LIKE ?) OR (documentnumber LIKE ?)
                    OR (studentnumber LIKE ?) ";

    
    $sth = $dbh->prepare($query);
    $sth->execute($busqueda, $busqueda, $busqueda, $busqueda, $busqueda);

    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

# Devuelve informacion del usuario segun un borrowernumber, solo de la tabla borrowers
# Retorna los datos como una hash
## FIXME DEPRECATED, se usa ahora getSocioInfo
sub getBorrower{
    my ($borrowernumber) = @_;

    my $dbh = C4::Context->dbh;
    my $query=" SELECT * 
            FROM borrowers 
            WHERE borrowernumber=?";
    my $sth=$dbh->prepare($query);
    $sth->execute($borrowernumber);

    return ($sth->fetchrow_hashref);
}

# Devuelve toda la informacion del usuario segun un borrowernumber, matching con localidades, categories
# Retorna los datos como una hash
## FIXME DEPRECATED, se usa ahora getSocioInfo
sub getBorrowerInfo {

    my ($borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;

    $query= "   SELECT borrowers.* , ref_localidad.nombre AS cityname , usr_ref_categoria_socio.description AS categoria
            
            FROM borrowers LEFT JOIN usr_ref_categoria_socio ON 
                            (usr_ref_categoria_socio.categorycode = borrowers.categorycode)
                                LEFT JOIN ref_localidad ON 
                                    (ref_localidad.localidad = borrowers.city)
            WHERE (borrowers.borrowernumber = ?); ";

    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);

    return ($sth->fetchrow_hashref);
}

=item
Esta funcion devuelve la informacion del socio, segun el id_socio
=cut
sub getSocioInfo {
    
    use C4::Modelo::UsrSocio;
    use C4::Modelo::UsrSocio::Manager;

    my ($id_socio) = @_;

    my  $socio = C4::Modelo::UsrSocio->new(id_socio => $id_socio);
        $socio->load();

    return ($socio);
}

=item
Este funcion devuelve la informacion del usuario segun un nro_socio
=cut
sub getSocioInfoPorNroSocio{

    use C4::Modelo::UsrSocio;

    my ($nro_socio)= @_;

    my $socio_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( query => [ nro_socio => { eq => $nro_socio } ]);

    return ($socio_array_ref->[0]);
}


sub getPersonaLike {
    
    use C4::Modelo::UsrPersona;
    use C4::Modelo::UsrPersona::Manager;

    my ($persona,$orden,$ini,$cantR,$habilitados) = @_;
    my  $personas_array_ref;
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();
 
    if (($habilitados == 1)){
        push(@filtros, ( activo=> { eq => 0}) );
     }

    if($persona ne 'TODOS'){
        push(@filtros, ( apellido=> { like => $persona.'%' } ) );
    }
    
    $personas_array_ref = C4::Modelo::UsrPersona::Manager->get_usr_persona( query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($orden) ),
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
     ); 

    my $cant= C4::Modelo::UsrPersona::Manager->get_usr_persona_count( query => \@filtros);

    return ($cant, $personas_array_ref);
}

sub getSocioLike {
    
    use C4::Modelo::UsrSocio;
    use C4::Modelo::UsrSocio::Manager;

    my ($socio,$orden,$ini,$cantR,$habilitados) = @_;
    
    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();
    
    if (defined($habilitados)){
        push(@filtros, ( activo=> { eq => $habilitados}) );
     }

    if($socio ne 'TODOS'){
        push (@filtros, (apellido => { like => $socio.'%' }) );
    }
    my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($orden) ),
                                                                            limit   => $cantR,
                                                                            offset  => $ini,
                                                                            require_objects => [ 'persona' ]
     ); 
    return (scalar(@$socios_array_ref), $socios_array_ref);
}

#Verifica si un usuario es regular, todos los usuarios que no son estudiantes (ES), son regulares por defecto
sub esRegular {

        my ($bor) = @_;

        my $dbh = C4::Context->dbh;
    my $regular= 1; #Regular por defecto
        my $sth = $dbh->prepare("   SELECT regular 
                    FROM persons 
                    WHERE borrowernumber = ? 
                        AND 
                          categorycode='ES' " );
        $sth->execute($bor);
        my $reg = $sth->fetchrow();

    if (($reg eq 1) || ($reg eq 0)){$regular = $reg;}
        $sth->finish();
    
    return $regular;
    
}

#Verifica si el usuario llego al maximo de las resevas que puede relizar sengun la preferencia del sistema
sub llegoMaxReservas {

    my ($borrowernumber)=@_;

    my $cant= &C4::AR::Reservas::cant_reservas($borrowernumber);    

    return $cant >= C4::Context->preference("maxreserves");
}

#Verifica si un usuario esta sancionado segun un tipo de prestamo
sub estaSancionado {

    my ($borrowernumber,$issuecode)=@_;
    my $sancionado= 0;

    my @sancion= C4::AR::Sanctions::permitionToLoan($borrowernumber, $issuecode);

    if (($sancion[0]||$sancion[1])) { 
        $sancionado= 1;
    }

    return $sancionado;
}


# Funcion que retorna un arreglo de hash, con todos los datos de los usuarios (persons) que cumplen con el patrón de búsqueda.
# Recibe como parámetro un string, que puede ser compuesto (varias palabras), además tambien recibe el tipo ($type), para ver si es busqueda simple ó compuesta.


# FIXME SE USA???????????????????????????????????????????????????????????????????????
sub ListadoDePersonas  {
    my ($env,$searchstring,$type,$orden,$ini,$cantR)=@_;
    my $dbh = C4::Context->dbh;
    my $count; 
    my @data;
    my @bind=();
    my $query=" SELECT COUNT(*) 
            FROM persons ";
    my $query2="    SELECT * 
            FROM persons ";
    my $where;
    if($type eq "simple")   # simple search for one letter only
    {
        $where="WHERE surname LIKE ? ";
        @bind=("$searchstring%");
    }
    else    # advanced search looking in surname, firstname and othernames
    {
        @data=split(' ',$searchstring);
                $count=@data;
                $where="    WHERE ( surname LIKE ? OR surname LIKE ?
                    OR  firstname LIKE ? OR firstname LIKE ?
                            OR  documentnumber  LIKE ? OR  documentnumber LIKE ?
                            OR  cardnumber LIKE ? OR  cardnumber LIKE ? 
                    OR  studentnumber  LIKE ? OR  studentnumber LIKE ? )";

                @bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%", "$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%" );

                for (my $i=1;$i<$count;$i++){
                    $where.=" AND  (surname LIKE ? OR surname LIKE ?
                    OR  firstname LIKE ? OR firstname LIKE ?
                            OR  documentnumber  like ? OR documentnumber LIKE ?
                            OR  cardnumber LIKE ? OR  cardnumber LIKE ?
                            OR  studentnumber  LIKE ? OR  studentnumber LIKE ? )";

                push(@bind,"%$data[$i]%","%$data[$i]%","%$data[$i]%","%$data[$i]%","$data[$i]%","% $data[$i]%","%$data[$i]%","%$data[$i]%","%$data[$i]%","%$data[$i]%");
                }

    }

    $query.=$where;
    $query2.=$where." ORDER BY ".$orden." LIMIT ?,?";

    my $sth=$dbh->prepare($query);
    $sth->execute(@bind);
    my $cnt= $sth->fetchrow;
    $sth->finish;

    my $sth=$dbh->prepare($query2);
    $sth->execute(@bind,$ini,$cantR);
    my @results;
    while (my $data=$sth->fetchrow_hashref){
        push(@results,$data);
    }
    $sth->finish;

    return ($cnt,\@results);
}


# ObtenerCategoria
# Obtiene la categoria de un usuario en particular.

# FIXME OBSOLETO??
sub obtenerCategoriaPersona{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("   SELECT categorycode     
                    FROM persons 
                    WHERE borrowernumber = ?");
        $sth->execute($bor);
        my $condicion = $sth->fetchrow();
    $sth->finish();
        return $condicion;
}

sub obtenerCategoriaBorrower{
        my ($bor) = @_;
        my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("  SELECT categorycode 
                   FROM borrowers 
                   WHERE borrowernumber = ?");
    $sth->execute($bor);
        my $condicion = $sth->fetchrow();
    $sth->finish();
        return $condicion;
}




# Obtiene todas las categorías que hay en el sistema, y retorna 2 arreglos: uno con los codigos y otro con las descripciones.

sub obtenerCategorias {
    my $dbh = C4::Context->dbh;

    my $sth=$dbh->prepare(" SELECT categorycode , description 
                FROM usr_ref_categoria_socio 
                ORDER BY description");
    $sth->execute();
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'categorycode'};
      $labels{$data->{'categorycode'}}=$data->{'description'};
    }
    $sth->finish;

    return(\@codes,\%labels);
}


# FIXME el nombre de la funcion no parece ser el adecuado

# Obtiene todos los prestamos vencidos
 
sub mailIssuesForBorrower{
    my ($branch,$bornum)=@_;

    my $dbh = C4::Context->dbh;
    my $dateformat = C4::Date::get_date_format();
    my $sth=$dbh->prepare(" SELECT * 
                FROM  circ_prestamo
                LEFT JOIN cat_nivel3 n3 ON n3.id3 =  circ_prestamo.id3
                LEFT JOIN cat_nivel1 n1 ON n3.id1 = n1.id1
                WHERE  circ_prestamo.returndate IS NULL AND  circ_prestamo.date_due <= now( ) 
                AND  circ_prestamo.branchcode = ? AND  circ_prestamo.borrowernumber = ? ");
        $sth->execute($branch,$bornum);
    my @result;
    my @datearr = localtime(time);
    my $hoy =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
    while (my $data = $sth->fetchrow_hashref) {
        #Para que solo mande mail a los prestamos vencidos
        $data->{'vencimiento'}=format_date(C4::AR::Issues::vencimiento($data->{'id3'}),$dateformat);
        my $flag=Date::Manip::Date_Cmp($data->{'vencimiento'},$hoy);
        if ($flag lt 0){
            #Solo ingresa los prestamos vencidos a el arreglo a retornar
                push @result, $data;
        }
    }
    $sth->finish;

    return(scalar(@result), \@result);
}


# Obtiene los datos de una persona, que viene como parametro.
sub personData {
    my ($personNumber)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                FROM persons 
                WHERE personnumber=?");
    $sth->execute($personNumber);

    my $data=$sth->fetchrow_hashref;
    $sth->finish;

    return($data);
}


# Busca todos los usuarios, con sus datos, entre un par de nombres o legajo para poder crear los carnet.
sub BornameSearchForCard{
    my ($apellido1,$apellido2,$category,$branch,$orden,$regular,$legajo1,$legajo2) = @_;

    my @filtros;
    my $socioTemp = C4::Modelo::UsrSocio->new();

    if ((C4::AR::Utilidades::validateString($category))&& ($category ne 'SIN SELECCIONAR')) {
           push (@filtros, (cod_categoria => { eq => $category }) );
    }

    if ((C4::AR::Utilidades::validateString($apellido1)) || (C4::AR::Utilidades::validateString($apellido2))){
        if ((C4::AR::Utilidades::validateString($apellido1)) && (C4::AR::Utilidades::validateString($apellido2))){
                push (@filtros, ('persona.'.apellido => { gt => $apellido1, eq => $apellido1 }) ); # >=
                push (@filtros, ('persona.'.apellido => { lt => $apellido2, eq => $apellido2 }) ); # <=

        }
        elsif (C4::AR::Utilidades::validateString($apellido1)){ 
                push (@filtros, ('persona.'.apellido => { like => '%'.$apellido1.'%'}) );
        }
        else {
                 push (@filtros, ('persona.'.apellido => { like => '%'.$apellido2.'%'}) );
        }
    }

    if ((C4::AR::Utilidades::validateString($legajo1)) || (C4::AR::Utilidades::validateString($legajo2))){
        if ((C4::AR::Utilidades::validateString($legajo1)) && (C4::AR::Utilidades::validateString($legajo2))){
                push (@filtros, ('persona.'.legajo => { gt => $legajo1, eq => $legajo1 }) ); # >=
                push (@filtros, ('persona.'.legajo => { lt => $legajo2, eq => $legajo2 }) ); # <=
        }
        elsif (C4::AR::Utilidades::validateString($legajo1)) {
                push (@filtros, ('persona.'.legajo => { eq => $legajo1}) );
        }
        else {
               push (@filtros, ('persona.'.legajo => { eq => $legajo2}) );
        }
    }

     my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio(   query => \@filtros,
                                                                            sort_by => ( $socioTemp->sortByString($orden) ),
                                                                            require_objects => [ 'persona' ]
     );

    return (scalar(@$socios_array_ref), $socios_array_ref);
}
# 
=item 
NewBorrowerNumber
Devulve el maximo borrowernumber
Posiblemente no se usa o no sirve!!!!!!! VER!!!!!!!!!!!!
=cut
## FIXME BORRAR no es necesario
sub NewBorrowerNumber{
    my $dbh = C4::Context->dbh;

    my $sth=$dbh->prepare(" SELECT MAX(borrowernumber) 
                FROM borrowers");
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;

    $data->{'max(borrowernumber)'}++;

    return($data->{'max(borrowernumber)'});
}

=item 
findguarantees

  ($num_children, $children_arrayref) = &findguarantees($parent_borrno);
  $child0_cardno = $children_arrayref->[0]{"cardnumber"};
  $child0_borrno = $children_arrayref->[0]{"borrowernumber"};

C<&findguarantees> takes a borrower number (e.g., that of a patron
with children) and looks up the borrowers who are guaranteed by that
borrower (i.e., the patron's children).

C<&findguarantees> returns two values: an integer giving the number of
borrowers guaranteed by C<$parent_borrno>, and a reference to an array
of references to hash, which gives the actual results.

SE USA EN insertdata.pl ----- VER!!!!!!!!!!!!!!!!!!!!
POSIBLEMENTE SE PUEDA BORRAR !!!!! BUSCA HIJOS!!!!!!!
=cut
sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("   SELECT cardnumber , borrowernumber , firstname , surname 
                FROM borrowers 
                WHERE guarantor=?");
  $sth->execute($bornum);

  my @dat;
  while (my $data = $sth->fetchrow_hashref)
  {
    push @dat, $data;
  }
  $sth->finish;
  return (scalar(@dat), \@dat);
}

sub updateOpacBorrower{
    my($update) = @_;
    my $dbh = C4::Context->dbh;
    my $query=" UPDATE borrowers 
            SET streetaddress=? , faxnumber=?, firstname=?, emailaddress=?, 
                city=?, phone=?, surname=? 
            
            WHERE borrowernumber=?";

    my $sth=$dbh->prepare($query);
    $sth->execute($update->{'streetaddress'},$update->{'faxnumber'},$update->{'firstname'},$update->{'emailaddress'},$update->{'city'},$update->{'phone'},$update->{'surname'},$update->{'borrowernumber'});
    $sth->finish;
}

 


1;


