package C4::AR::Sphinx;

use strict;

require Exporter;

use C4::AR::Catalogacion;
use MARC::Record;
use C4::Modelo::RefEstado;
use C4::Modelo::RefEstado::Manager;

use vars qw(@EXPORT @ISA);
@ISA = qw(Exporter);
@EXPORT = qw(
                generar_indice
                reindexar
                sphinx_start
);


=head2
    sub reindexar
=cut
sub reindexar{
    C4::AR::Debug::debug("Sphinx => reindexar => run_indexer => indexado => ".C4::AR::Preferencias::getValorPreferencia('indexado'));

    if(C4::AR::Preferencias::getValorPreferencia('indexado')){
        C4::AR::Debug::debug("Sphinx => reindexar => EL INDICE SE ENCUENTRA ACTUALIZADO!!!!!!!");
    } else {
        C4::AR::Debug::debug("Sphinx => reindexar => EL INDICE SE ENCUENTRA DESACTUALIZADO!!!!!!!!");
        my $mgr = Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
        #verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada
        #Esto no deberia llamarse mas porque el sphinx es un servicio del squezze ahora!
        #asi que lo comento    
        #C4::AR::Sphinx::sphinx_start($mgr);

        my @args;
        push (@args, '--all');
        push (@args, '--rotate');
        push (@args, '--quiet');
        $mgr->indexer_sudo("sudo");
        $mgr->indexer_args(\@args);
        $mgr->run_indexer();
        C4::AR::Debug::debug("Sphinx => reindexar => --all --rotate => ");
        C4::AR::Preferencias::setVariable('indexado', 1);
    }

}

=head2
    sub sphinx_start
    verifica si sphinx esta levantado, sino lo está lo levanta, sino no hace nada
=cut
sub sphinx_start{
    my ($mgr)= @_;
    if (exists $ENV{MOD_PERL}){
        defined (my $kid = fork) or die "Cannot fork: $!\n";
        if ($kid) {
        # Parent runs this block
      } else {
          # Child runs this block
          # some code comes here
          $mgr = $mgr || Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
          $mgr->debug(0);
	  $mgr->searchd_sudo("sudo");
          my $pids = $mgr->get_searchd_pid;
          if(scalar(@$pids) == 0){
#               C4::AR::Debug::debug("Utilidades => generar_indice => el sphinx esta caido!!!!!!! => ");
              $mgr->start_searchd;
#               C4::AR::Debug::debug("Utilidades => generar_indice => levantó sphinx!!!!!!! => ");
          }
          CORE::exit(0);
      }
  }else{
      $mgr = $mgr || Sphinx::Manager->new({ config_file => C4::Context->config("sphinx_conf") });
      $mgr->debug(0);
      $mgr->searchd_sudo("sudo");
      my $pids = $mgr->get_searchd_pid;
      if(scalar(@$pids) == 0){
#           C4::AR::Debug::debug("Utilidades => generar_indice => el sphinx esta caido!!!!!!! => ");
          $mgr->start_searchd;
#           C4::AR::Debug::debug("Utilidades => generar_indice => levantó sphinx!!!!!!! => ");
      }
  }
}


sub getNombreFromEstadoByCodigo{
    my ($codigo)   = @_;
    
    my @filtros;
    
    push(@filtros, ( codigo => { eq => $codigo }) );

    my $nivel3 = C4::Modelo::RefEstado::Manager->get_ref_estado( query => \@filtros ); 

    if(scalar(@$nivel3) > 0){
        return ($nivel3->[0]->nombre);
    } else {
        return "NULL";
    }
}

=head2
    sub generar_indice
=cut
sub generar_indice {
    my ($id1, $flag, $action)   = @_;


    my $dbh = C4::Context->dbh;
    my $sth1;
    my $dato;
    my $dato_ref;
    my $dato_con_tabla;
    my $campo;
    my $subcampo;
    my $string_con_dato         = "";
    my $MARC_result_array;
    
    $id1 = $id1 || 0;
    
#     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => flag => ".$flag);
    if($flag eq "R_FULL"){
        #Vaciamos el indice
        my $truncate  = " TRUNCATE TABLE `indice_busqueda`;";
        my $sth0      = $dbh->prepare($truncate);
        $sth0->execute();

        my $query1  = " SELECT * FROM cat_registro_marc_n1 WHERE id >= ?";
        $sth1       = $dbh->prepare($query1);
        $sth1->execute($id1);
    } elsif($flag eq "R_ACUMULATIVE") {

        #se va a modificar un registro en adelante, SIN TRUNCAR
        my $query1  = " SELECT * FROM cat_registro_marc_n1 WHERE id >= ?";
        $sth1       = $dbh->prepare($query1);
        $sth1->execute($id1);

    } else {

        #se va a modificar un registro en particular
        my $query1  = " SELECT * FROM cat_registro_marc_n1 WHERE id = ?";
        $sth1       = $dbh->prepare($query1);
        $sth1->execute($id1);
    }

while (my $registro_marc_n1 = $sth1->fetchrow_hashref ){

 eval{

    my %params;
    $params{'nivel'}        = "1";
    $params{'id'}           = $registro_marc_n1->{'id'};

    my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

#      C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => generando indice del id ".$registro_marc_n1->{'id'});

    foreach my $c (@resultEstYDatos){
#         C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

        foreach my $s (@{$c->{'subcampos_array'}}){ 
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
            $string_con_dato = $string_con_dato." ".$s->{'dato'};   
        }
    }


    my $marc_record = MARC::Record->new_from_usmarc($registro_marc_n1->{'marc_record'});

    my $query2=" SELECT * FROM cat_registro_marc_n2 where id1 =?;";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute($registro_marc_n1->{'id'});



    #se agregan todos los ejemplares (nivel3) al nivel2
    while (my $registro_marc_n2 = $sth2->fetchrow_hashref ){


        $params{'nivel'}        = "2";
        $params{'id'}           = $registro_marc_n2->{'id'};

        my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

        foreach my $c (@resultEstYDatos){
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

            foreach my $s (@{$c->{'subcampos_array'}}){ 
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
                $string_con_dato = $string_con_dato." ".$s->{'dato'};   
            }
        }


        my $marc_record2 = MARC::Record->new_from_usmarc($registro_marc_n2->{'marc_record'});
        $marc_record->add_fields($marc_record2->fields);

        my $query3=" SELECT * FROM cat_registro_marc_n3 where id1=? and id2=?;";
        my $sth3=$dbh->prepare($query3);
        $sth3->execute($registro_marc_n1->{'id'},$registro_marc_n2->{'id'});

        while (my $registro_marc_n3 = $sth3->fetchrow_hashref ){
#             C4::AR::Debug::debug('C4::AR::Sphinx::generar_indice => ID3 '.$registro_marc_n3->{'id'});
            my $marc_record3 = MARC::Record->new_from_usmarc($registro_marc_n3->{'marc_record'});
            $marc_record->add_fields($marc_record3->fields);


            $params{'nivel'}        = "3";
            $params{'id3'}          = $registro_marc_n3->{'id'};

# C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => NIVEL 3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa ".$registro_marc_n3->{'id3'});
            my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => NIVEL 3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa ");

            foreach my $c (@resultEstYDatos){
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

                foreach my $s (@{$c->{'subcampos_array'}}){ 
#                     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#                     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
                    $string_con_dato = $string_con_dato." ".$s->{'dato'};   
                }
            }

        }
    }
#Ahora en $marc_record tenemos todo el registro completo
    #Autores
    my @autores;

    my $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("100","a"));
    if ($autor){
        $autor = C4::AR::Catalogacion::getDatoFromReferencia("100", "a", $autor, $registro_marc_n1->{'template'});
        ($autor ne "NO_TIENE")?push (@autores,$autor):"";
    }

       $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("110","a"));
    if ($autor){
        $autor = C4::AR::Catalogacion::getDatoFromReferencia("110", "a", $autor, $registro_marc_n1->{'template'});
        ($autor ne "NO_TIENE")?push (@autores,$autor):"";
    }

       $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("111","a"));
    if ($autor){
        $autor = C4::AR::Catalogacion::getDatoFromReferencia("111", "a", $autor, $registro_marc_n1->{'template'});
        ($autor ne "NO_TIENE")?push (@autores,$autor):"";
    }

    #Ahora los adicionales
    my @field700 =$marc_record->field("700");
    foreach my $f700 (@field700){     
        my @autores_adicionales = $f700->subfield("a");

        foreach my $au_ad (@autores_adicionales){
            $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($au_ad);          
            C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => autor adicional ".$au_ad);

            if ($autor){
                $autor = C4::AR::Catalogacion::getDatoFromReferencia("700", "a", $autor, $registro_marc_n1->{'template'});
                ($autor ne "NO_TIENE")?push (@autores,$autor):"";
            }
        }
    }

      my @field700 =$marc_record->field("710");
       foreach my $f710 (@field700){     
          my @autores_adicionales =$f710->subfield("a");
          foreach my $au_ad (@autores_adicionales){
          $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($au_ad);
            
          C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => autor adicional ".$au_ad);

              if ($autor){
                $autor = C4::AR::Catalogacion::getDatoFromReferencia("710", "a", $autor, $registro_marc_n1->{'template'});
                ($autor ne "NO_TIENE")?push (@autores,$autor):"";
              }
          }
      }

    $autor = join(' | ',@autores);

    #Titulo
    my $titulo                  = $marc_record->subfield("245","a");
    #Armo el superstring
    my $superstring             = "";    

    #recorro los campos
    foreach my $field ($marc_record->fields){
        $campo = $field->tag;

        #recorro los subcampos
        foreach my $subfield ($field->subfields()) {

            $subcampo                       = $subfield->[0];
            $dato                           = $subfield->[1];
#             C4::AR::Debug::debug("generar_indice => campo => ".$field->tag);
#             C4::AR::Debug::debug("generar_indice => subcampo => ".$subfield->[0]);
            $dato_ref                       = C4::AR::Catalogacion::getRefFromStringConArrobasByCampoSubcampo($campo, $subcampo, $dato);
            $dato                           = C4::AR::Catalogacion::getDatoFromReferencia($campo, $subcampo, $dato_ref, $registro_marc_n1->{'template'});

            next if ($dato eq 'NO_TIENE');
            next if ($dato eq '');
            
# TODO modularizame!!!!!!!!!!!!!
            #aca van todas las excepciones que no son referencias pero son necesarios para las busquedas 
            if (($campo eq "020") && ($subcampo eq "a")){
                $dato = 'isbn%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 020, a => dato ".$dato);
            }

            if (($campo eq "995") && ($subcampo eq "o")){
                $dato = 'ref_disponibilidad%'.$dato;
                $dato .= ' ref_disponibilidad_code%'.$dato_ref;  
#                 C4::AR::Debug::debug("generar_indice => 020, a => dato ".$dato);
            }

            if (($campo eq "995") && ($subcampo eq "e")){
                 C4::AR::Debug::debug(" ================================== generar_indice => 995, e => dato ".$dato);
                $dato = 'ref_estado%'.getNombreFromEstadoByCodigo($dato_ref);  
            }

            if (($campo eq "995") && ($subcampo eq "f")){
                $dato = 'barcode%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 995, f => dato ".$dato);
            }

            if (($campo eq "995") && ($subcampo eq "t")){
                $dato = 'signatura%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 995, f => dato ".$dato);
            }

            if (($campo eq "650") && ($subcampo eq "a")){
                $dato = 'cat_tema%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 650, a => dato ".$dato);
            }
   
            if (($campo eq "910") && ($subcampo eq "a")){
# FIXME es para la busqueda MATCH EXTENDED
                $dato .= ' cat_ref_tipo_nivel3%'.$dato_ref;
                
#                 C4::AR::Debug::debug("generar_indice => 995, f => dato ".$dato);
            }


# C4::AR::Debug::debug("dato despues de buscar ref => ".$dato);
    
            if ($superstring eq "") {
                $superstring            = $dato;
            } else {
                $superstring .= " ".$dato;
            }
        } #END foreach my $subfield ($field->subfields())
    } #END foreach my $field ($marc_record->fields)

#     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => superstring!!!!!!!!!!!!!!!!!!! => ".$superstring);

    if($action eq "INSERT"){
        my $query4  =   " INSERT INTO indice_busqueda (id, titulo, autor, string) ";
        $query4 .=      " VALUES (?,?,?,?) ";
        my $sth4    = $dbh->prepare($query4);
        $sth4->execute($registro_marc_n1->{'id'}, $titulo, $autor, $superstring);
    } else {    

        my $query4  = "SELECT COUNT(*) as cant FROM indice_busqueda WHERE id = ?";
        my $sth4    = $dbh->prepare($query4);
        $sth4->execute($registro_marc_n1->{'id'});
        my $data = $sth4->fetchrow_hashref;

        if($data->{'cant'}) {
            my $query4  =   " UPDATE indice_busqueda SET titulo = ?, autor = ?, string = ? ";
            $query4 .=      " WHERE id = ? ";
            my $sth4    = $dbh->prepare($query4);
            $sth4->execute($titulo, $autor, $superstring, $registro_marc_n1->{'id'});
        } else {
            my $query4  =   " INSERT INTO indice_busqueda (id, titulo, autor, string) ";
            $query4 .=      " VALUES (?,?,?,?) ";
            my $sth4    = $dbh->prepare($query4);
            $sth4->execute($registro_marc_n1->{'id'}, $titulo, $autor, $superstring);
        }

#         C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => UPDATE => id1 => ".$registro_marc_n1->{'id'});
    }
    
     }; #END eval
    if ($@){
        C4::AR::Debug::debug("ERROR AL GENERAR EL INDICE EN EL REGISTRO: ". $registro_marc_n1->{'id'}." !!! ( ".$@." )");
    }
    
} #END while (my $registro_marc_n1 = $sth1->fetchrow_hashref )

}
=pod

=back

=cut

1;

__END__
