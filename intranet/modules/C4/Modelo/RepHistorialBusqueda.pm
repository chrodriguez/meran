package C4::Modelo::RepHistorialBusqueda;

use strict;

use base qw(C4::Modelo::DB::Object::AutoBase2);

__PACKAGE__->meta->setup(
    table   => 'rep_historial_busqueda',

    columns => [
        idHistorial        => { type => 'serial', not_null => 1 },
        idBusqueda         => { type => 'integer', not_null => 1 },
        campo              => { type => 'varchar', length => 100, not_null => 1 },
        valor              => { type => 'varchar', length => 100, not_null => 1 },
        tipo               => { type => 'varchar', length => 10 },
        HTTP_USER_AGENT    => { type => 'varchar', length => 255 },
    ],

   primary_key_columns => [ 'idHistorial' ],
   relationships => [
         busqueda =>  {
            class       => 'C4::Modelo::RepBusqueda',
            key_columns => { idBusqueda => 'idBusqueda' },
            type        => 'one to one',
      },
         
    ],
);


sub agregarSimple{
   
   my $self = shift;
   my($id_rep_busqueda,$tipo_busqueda,$valor,$desde)=@_;
C4::AR::Debug::debug("agregar simple");
   $self->setIdBusqueda($id_rep_busqueda);
   $self->setCampo($tipo_busqueda);
   $self->setValor($valor);
   $self->setTipo($desde);
   $self->save();

}


sub agregar{
   
   my $self = shift;
   my($nro_socio,$desde,$http_user_agent,$search_array)=@_;

   my $db = $self->db;
   my $rep_busqueda = C4::Modelo::RepBusqueda->new(db => $db);
      $rep_busqueda->agregar($nro_socio);
   C4::AR::Debug::debug("ENTRO A AGREGAR");
   foreach my $search (@$search_array){

      my $historial_temp = C4::Modelo::RepHistorialBusqueda->new(db => $db);

      if (C4::AR::Utilidades::validateString($search->{'keyword'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'keyword', $search->{'keyword'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'dictionary'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'dictionary', $search->{'dictionary'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'virtual'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'virtual', $search->{'virtual'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'signature'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'signature', $search->{'signature'}, $desde);
      }  
   
      if (C4::AR::Utilidades::validateString($search->{'analytical'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'analytical', $search->{'analytical'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'id3'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'id3', $search->{'id3'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'class'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'class', $search->{'class'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'subjectitems'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'subjectitems', $search->{'subjectitems'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'isbn'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'isbn', $search->{'isbn'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'subjectid'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'subjectid', $search->{'subjectid'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'autor'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'autor', $search->{'autor'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'titulo'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'titulo', $search->{'titulo'}, $desde);
      }
   
      if (C4::AR::Utilidades::validateString($search->{'tipo_documento'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'tipo_documento', $search->{'tipo_documento'}, $desde);
      }

      if (C4::AR::Utilidades::validateString($search->{'barcode'}) ){
         $historial_temp->agregarSimple($rep_busqueda->getIdBusqueda, 'barcode', $search->{'barcode'}, $desde);
      }
   
      if( !C4::AR::Utilidades::isBrowser($http_user_agent) ){
            $http_user_agent= 'ROBOT';
      }
      
      $historial_temp->setAgent($http_user_agent);

      $historial_temp->save();
   }

}

sub getIdBusqueda{

   my $self = shift;
   return ($self->idBusqueda);
}

sub setIdBusqueda{

   my $self = shift;
   my $id_busqueda = @_;
   $self->idBusqueda($id_busqueda);
}


sub getAgent{

   my $self = shift;
   return ($self->HTTP_USER_AGENT);
}

sub setAgent{

   my $self = shift;
   my $http_user_agent = @_;
   $self->HTTP_USER_AGENT($http_user_agent);
}

sub getCampo{

   my $self = shift;
   return ($self->campo);
}

sub setCampo{

   my $self = shift;
   my $campo = @_;
   $self->campo($campo);
}

sub getValor{

   my $self = shift;
   return ($self->valor);
}

sub setValor{

   my $self = shift;
   my $valor = @_;
   $self->valor($valor);
}

sub getTipo{

   my $self = shift;
   return ($self->tipo);
}

sub setTipo{

   my $self = shift;
   my $tipo = @_;
   $self->tipo($tipo);
}






















1;

