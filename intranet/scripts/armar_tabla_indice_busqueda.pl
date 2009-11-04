#!/usr/bin/perl
use Date::Manip;
use C4::Date;
use C4::AR::Catalogacion;
use C4::AR::Utilidades;
use C4::AR::Reservas;
use C4::AR::Nivel1;
use C4::AR::Nivel2;
use C4::AR::Nivel3;
use C4::AR::PortadasRegistros;
use C4::AR::Busquedas;
use MARC::Record;

  my $dbh = C4::Context->dbh;
  my $query=" SELECT id1 FROM cat_nivel1";
  my $sth=$dbh->prepare($query);
  $sth->execute();
  while (my $id1=$sth->fetchrow){
  C4::AR::Debug::debug('ID1 '.$id1);
    my @result;
    my ($nivel1_object)= C4::AR::Nivel1::getNivel1FromId1($id1);
        if($nivel1_object ne 0){
          C4::AR::Debug::debug('recupero el nivel1');
          my $marc_array_nivel1 = $nivel1_object->nivel1CompletoToMARC;
          push(@result, @$marc_array_nivel1);
        }

    
  my $query2=" SELECT id2 FROM cat_nivel2 where id1=? ";
  my $sth2=$dbh->prepare($query2);
  $sth2->execute($id1);
  
  while (my $id2=$sth2->fetchrow){
        my ($nivel2_object)= C4::AR::Nivel2::getNivel2FromId2($id2);
        
        if($nivel2_object ne 0){
          C4::AR::Debug::debug('recupero el nivel2 '.$id2);
          my $marc_array_nivel2 = $nivel2_object->nivel2CompletoToMARC;
          C4::AR::Debug::debug('MARCDetail => cant '.scalar(@$marc_array_nivel2));
          push(@result, @$marc_array_nivel2);
        }

        
  my $query3=" SELECT id3 FROM cat_nivel3 where id2=? ";
  my $sth3=$dbh->prepare($query3);
  $sth3->execute($id2);
  
  while (my $id3=$sth3->fetchrow){
  
     my ($nivel3_object)= C4::AR::Nivel3::getNivel3FromId3($id3);
     
        if($nivel3_object ne 0){
          C4::AR::Debug::debug('recupero el nivel3');
          my $marc_array_nivel3 = $nivel3_object->nivel3CompletoToMARC;
          push(@result, @$marc_array_nivel3);
        }
  }
  
  }

    my $superstring="";
        
    my $marc=MARC::Record->new();
    
    for(my $i=0; $i< scalar(@result); $i++){
      if ($superstring eq "") {$superstring =@result[$i]->{'dato'}; }
        else {$superstring .=" ".@result[$i]->{'dato'}; }
    }
      
    my $query4="INSERT INTO indice_busqueda (id,titulo,autor,string) VALUES (?,?,?,?) ";
    my $sth4=$dbh->prepare($query4);
    my $autor = C4::AR::Referencias::getAutor($nivel1_object->getAutor);
    if($autor){$autor = $autor->getCompleto;}
    $sth4->execute($id1,$nivel1_object->getTitulo,$autor,$superstring);
      
  }

