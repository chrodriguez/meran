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
my $query1=" SELECT * FROM cat_registro_marc_n1";
my $sth1=$dbh->prepare($query1);
$sth1->execute();


while (my $registro_marc_n1 = $sth1->fetchrow_hashref ){
    C4::AR::Debug::debug('ID1 '.$registro_marc_n1->{'id'});
    my $marc_record = MARC::Record->new_from_usmarc($registro_marc_n1->{'marc_record'});

    my $query2=" SELECT * FROM cat_registro_marc_n2 where id1 =?;";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute($registro_marc_n1->{'id'});

    while (my $registro_marc_n2 = $sth2->fetchrow_hashref ){
        C4::AR::Debug::debug('ID2 '.$registro_marc_n2->{'id'});
        my $marc_record2 = MARC::Record->new_from_usmarc($registro_marc_n2->{'marc_record'});
        $marc_record->add_fields($marc_record2->fields);


        my $query3=" SELECT * FROM cat_registro_marc_n3 where id1=? and id2=?;";
        my $sth3=$dbh->prepare($query3);
        $sth3->execute($registro_marc_n1->{'id'},$registro_marc_n2->{'id'});

        while (my $registro_marc_n3 = $sth3->fetchrow_hashref ){
            C4::AR::Debug::debug('ID3 '.$registro_marc_n3->{'id'});
            my $marc_record3 = MARC::Record->new_from_usmarc($registro_marc_n3->{'marc_record'});
            $marc_record->add_fields($marc_record3->fields);
        }
    }

#Ahora en $marc_record tenemos todo el registro completo
    #Autor
    my $autor = $marc_record->subfield("100","a");
        if(! $autor) { $autor = $marc_record->subfield("110","a");}
        if(! $autor) { $autor = $marc_record->subfield("111","a");}

    #Titulo
    my $titulo = $marc_record->subfield("245","a");

    #Armo el superstring
    my $superstring="";

   foreach my $field ($marc_record->fields){

            if ($superstring eq "") {$superstring =$field->as_string; }
                else {$superstring .=" ".$field->as_string; }
    }

    my $query4="INSERT INTO indice_busqueda (id,titulo,autor,string) VALUES (?,?,?,?) ";
    my $sth4=$dbh->prepare($query4);
    $sth4->execute($registro_marc_n1->{'id'},$titulo,$autor,$superstring);


}