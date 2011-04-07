package C4::AR::Sphinx;

use strict;

require Exporter;

use C4::AR::Catalogacion;
use MARC::Record;

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
        $mgr->indexer_args(\@args);
#         $mgr->run_indexer();

        my $err = system("wget -q  https://127.0.0.1/cgi-bin/koha/cron/reindexar.pl  --no-check-certificate 2>&1");

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
    my $string_tabla_con_dato   = "";
    my $string_con_dato         = "";
    my $MARC_result_array;

    C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => flag => ".$flag);
    if($flag eq "R_FULL"){
        #Vaciamos el indice
        my $truncate  =   " TRUNCATE TABLE `indice_busqueda`;";
        my $sth0      = $dbh->prepare($truncate);
        $sth0->execute();

        my $query1  =   " SELECT * FROM cat_registro_marc_n1";
        $sth1       =   $dbh->prepare($query1);
        $sth1->execute();

    } else {

        #se va a modificar un registro en particular
        my $query1  =   " SELECT * FROM cat_registro_marc_n1 WHERE id = ?";
        $sth1       =   $dbh->prepare($query1);
        $sth1->execute($id1);
    }


while (my $registro_marc_n1 = $sth1->fetchrow_hashref ){


    my %params;
    $params{'nivel'}        = "1";
    $params{'id_tipo_doc'}  = "ALL";
    $params{'id'}           = $registro_marc_n1->{'id'};

    my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => generando indice del id ".$registro_marc_n1->{'id'});

    foreach my $c (@resultEstYDatos){
#         C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

        foreach my $s (@{$c->{'subcampos_array'}}){ 
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
            $string_con_dato = $string_con_dato." ".$s->{'dato'};   
            if($s->{'referenciaTabla'} eq ""){
                $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'dato'};
            } else {
                $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'referenciaTabla'}."@".$s->{'dato'};
            }
        }
    }


    my $marc_record = MARC::Record->new_from_usmarc($registro_marc_n1->{'marc_record'});

    my $query2=" SELECT * FROM cat_registro_marc_n2 where id1 =?;";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute($registro_marc_n1->{'id'});



    #se agregan todos los ejemplares (nivel3) al nivel2
    while (my $registro_marc_n2 = $sth2->fetchrow_hashref ){


        $params{'nivel'}        = "2";
    # FIXME falta el itemtype y MODULARIZAR
        $params{'id_tipo_doc'}  = "ALL";
        $params{'id'}           = $registro_marc_n2->{'id'};

        my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

        foreach my $c (@resultEstYDatos){
#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

            foreach my $s (@{$c->{'subcampos_array'}}){ 
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
                $string_con_dato = $string_con_dato." ".$s->{'dato'};   
                if($s->{'referenciaTabla'} eq ""){
                    $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'dato'};
                } else {
                    $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'referenciaTabla'}."@".$s->{'dato'};
                }
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
# FIXME falta el itemtype y MODULARIZAR
            $params{'id_tipo_doc'}  = "ALL";
            $params{'id3'}           = $registro_marc_n3->{'id'};

# C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => NIVEL 3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa ".$registro_marc_n3->{'id3'});
            my @resultEstYDatos = C4::AR::Catalogacion::getEstructuraYDatosDeNivel(\%params);

#             C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => NIVEL 3 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa ");

            foreach my $c (@resultEstYDatos){
#                 C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => campo ".$c->{'campo'});

                foreach my $s (@{$c->{'subcampos_array'}}){ 
#                     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => subcampo ".$s->{'subcampo'});
#                     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => dato ".$s->{'dato'});
                    $string_con_dato = $string_con_dato." ".$s->{'dato'};   
                    if($s->{'referenciaTabla'} eq ""){
                        $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'dato'};
                    } else {
                        $string_tabla_con_dato = $string_tabla_con_dato." ".$s->{'referenciaTabla'}."@".$s->{'dato'};
                    }
                }
            }

        }
    }
#Ahora en $marc_record tenemos todo el registro completo
    #Autor
    my $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("100","a"));
#      C4::AR::Debug::debug("autor ANTES  ".$autor);
    $autor = C4::AR::Catalogacion::getDatoFromReferencia("100","a",$autor,"ALL");
#     C4::AR::Debug::debug("autor DESPUES  ".$autor);
    if(! $autor) { 
       $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("110","a"));
       $autor = C4::AR::Catalogacion::getDatoFromReferencia("110","a",$autor,"ALL");
    }

    if(! $autor) { 
       $autor = C4::AR::Catalogacion::getRefFromStringConArrobas($marc_record->subfield("111","a"));
       $autor = C4::AR::Catalogacion::getDatoFromReferencia("111","a",$autor,"ALL");
    }



    #Titulo
    my $titulo = $marc_record->subfield("245","a");

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
#                 C4::AR::Debug::debug("generar_indice => dato ".$dato);
            $dato                           = C4::AR::Catalogacion::getDatoFromReferencia($campo, $subcampo, $dato_ref, "ALL");

# TODO modularizame!!!!!!!!!!!!!
            #aca van todas las excepciones que no son referencias pero son necesarios para las busquedas 
            if (($campo eq "020") && ($subcampo eq "a")){
                $dato = 'isbn%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 020, a => dato ".$dato);
            }

            if (($campo eq "995") && ($subcampo eq "o")){
                $dato = 'ref_disponilidad%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 020, a => dato ".$dato);
            }

            if (($campo eq "995") && ($subcampo eq "f")){
                $dato = 'barcode%'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 995, f => dato ".$dato);
            }
   
            if (($campo eq "910") && ($subcampo eq "a")){
# FIXME es para la busqueda MATCH EXTENDED
                $dato = 'cat_ref_tipo_nivel3%'.$dato_ref;   
#                 $superstring .= " ".$dato;
#                 $dato = 'cat_ref_tipo_nivel3@'.$dato;  
#                 C4::AR::Debug::debug("generar_indice => 995, f => dato ".$dato);
            }


# C4::AR::Debug::debug("dato despues de buscar ref => ".$dato);
    
            if ($superstring eq "") {
                $superstring            = $dato;
#                 $string_tabla_con_dato  = $dato;
            } else {
                $superstring .= " ".$dato;
#                 $string_tabla_con_dato .= " ".$dato;
            }
        }
    }

#     C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => superstring!!!!!!!!!!!!!!!!!!! => ".$superstring);

    if($action eq "ALTA"){
        my $query4  =   " INSERT INTO indice_busqueda (id, titulo, autor, string, string_tabla_con_dato, string_con_dato) ";
        $query4 .=      " VALUES (?,?,?,?,?,?) ";
        my $sth4    = $dbh->prepare($query4);
        $sth4->execute($registro_marc_n1->{'id'}, $titulo, $autor, $superstring, $string_tabla_con_dato, $string_con_dato);
    } else {    

        my $query4  = "SELECT COUNT(*) as cant FROM indice_busqueda WHERE id = ?";
        my $sth4    = $dbh->prepare($query4);
        $sth4->execute($registro_marc_n1->{'id'});
        my $data = $sth4->fetchrow_hashref;

        if($data->{'cant'}) {
            my $query4  =   " UPDATE indice_busqueda SET titulo = ?, autor = ?, string = ?, string_tabla_con_dato = ?, string_con_dato = ? ";
            $query4 .=      " WHERE id = ? ";
            my $sth4    = $dbh->prepare($query4);
            $sth4->execute($titulo, $autor, $superstring, $string_tabla_con_dato, $string_con_dato, $registro_marc_n1->{'id'});

        } else {

            my $query4  =   " INSERT INTO indice_busqueda (id, titulo, autor, string, string_tabla_con_dato, string_con_dato) ";
            $query4 .=      " VALUES (?,?,?,?,?,?) ";
            my $sth4    = $dbh->prepare($query4);
            $sth4->execute($registro_marc_n1->{'id'}, $titulo, $autor, $superstring, $string_tabla_con_dato, $string_con_dato);

        }

        C4::AR::Debug::debug("C4::AR::Sphinx::generar_indice => UPDATE => id1 => ".$registro_marc_n1->{'id'});
    }
}

}
=pod

=back

=cut

1;

__END__
