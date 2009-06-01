package C4::AR::Referencias;

#Este modulo provee funcionalidades varias sobre las tablas de referencias en general
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use JSON;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
            &obtenerTiposDeDocumentos
            &obtenerCategoriaDeSocio
				&getCamposDeTablaRef
				&obtenerValoresTablaRef
				&obtenerTablasDeReferencia
    );


#Este modulo provee funcionalidades varias sobre las tablas de referencias en general
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
# #of the License, or (at your option) any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::Modelo::PrefTablaReferencia;
use C4::Modelo::PrefTablaReferencia::Manager;
use C4::Modelo::UsrRefTipoDocumento;
use C4::Modelo::UsrRefTipoDocumento::Manager;
use C4::Modelo::UsrRefCategoriasSocio;
use C4::Modelo::UsrRefCategoriasSocio::Manager;
use C4::Modelo::PrefUnidadInformacion;
use C4::Modelo::PrefUnidadInformacion::Manager;
use C4::Modelo::RefDisponibilidad;
use C4::Modelo::RefDisponibilidad::Manager;
use C4::Modelo::CatRefTipoNivel3;
use C4::Modelo::CatRefTipoNivel3::Manager;
use C4::Modelo::RefLocalidad;
use C4::Modelo::RefLocalidad::Manager;
# use JSON;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
            &obtenerTiposDeDocumentos
            &obtenerTiposNivel3
          );

=item
Esta funcion devuelve un arreglo de objetos tipo de documento
=cut
sub obtenerTiposDeDocumentos {
    my $tiposDoc = C4::Modelo::UsrRefTipoDocumento::Manager->get_usr_ref_tipo_documento;
    my @results;

    foreach my $tipo_doc (@$tiposDoc) {
        push (@results, $tipo_doc);
    }

    return(\@results);
}

=item
Esta funcion devuelve un arreglo de objetos con los tipos de nivel3
=cut
sub obtenerTiposNivel3 {
    my $tiposNivel3 = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3();
    my @results;

    foreach my $tipo_nivel3 (@$tiposNivel3) {
        push (@results, $tipo_nivel3);
    }

    return(\@results);
}

=item
Esta funcion devuelve un arreglo de objetos de categorias de socios
=cut
sub obtenerCategoriaDeSocio {
    my $categorias_array_ref = C4::Modelo::UsrRefCategoriasSocio::Manager->get_usr_ref_categoria_socio;
    my @results;

    foreach my $objeto_categoria (@$categorias_array_ref) {
        push (@results, $objeto_categoria);
    }

    return(\@results);
}

=item
Devuelve un arreglo de objetos Unidades de Informacion
=cut
sub obtenerUnidadesDeInformacion {
    my $unidades_array_ref = C4::Modelo::PrefUnidadInformacion::Manager->get_pref_unidad_informacion;
    my @results;

    foreach my $objeto_ui (@$unidades_array_ref) {
        push (@results, $objeto_ui);
    }

    return(\@results);
}

=item
Devuelve un arreglo de objetos Autor
=cut
sub obtenerAutores {
    my $autores_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor;
    my @results;

    foreach my $objeto_autor (@$autores_array_ref) {
        push (@results, $objeto_autor);
    }

    return(\@results);
}

=item
Devuelve un arreglo de objetos Autor
=cut
sub obtenerAutoresLike {
	my ($autor) = @_;

    my $autores_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor(
																query => [ completo => { like => '%'.$autor.'%' } ]
											);
    my @results;

    foreach my $objeto_autor (@$autores_array_ref) {
        push (@results, $objeto_autor);
    }

    return(\@results);
}

=item
Devuelve un arreglo de objetos Unidades de Informacion
=cut
sub obtenerDisponibilidades {
    my $disponibilidades_array_ref = C4::Modelo::RefDisponibilidad::Manager->get_ref_disponibilidad;
    my @results;

    foreach my $objeto_disponibilidad (@$disponibilidades_array_ref) {
        push (@results, $objeto_disponibilidad);
    }

    return(\@results);
}


=item
Devuelve un arreglo de objetos PrefTablaReferencia
=cut
sub obtenerTablasDeReferencia {
    my $referencias_array_ref = C4::Modelo::PrefTablaReferencia::Manager->get_pref_tabla_referencia;
    my @results;

    foreach my $objeto_ref (@$referencias_array_ref) {
		push (@results, $objeto_ref);
    }

    return(\@results);
}

=item
Devuelve un arreglo de los alias de objetos PrefTablaReferencia en string
=cut
sub obtenerTablasDeReferenciaAsString {
   
    my $referencias_array_ref = obtenerTablasDeReferencia();
    my @results;

    foreach my $objeto_ref (@$referencias_array_ref) {
        push (@results, $objeto_ref->getAlias_tabla);
    }

    return(\@results);
}



sub getCamposDeTablaRef{
    # (Chain Of Responsibility Object Pattern)
    use C4::Modelo::PrefTablaReferencia;
    my ($tableAlias) = @_;

    my $db = C4::Modelo::PrefTablaReferencia->new();
       $db = $db->createFromAlias($tableAlias);
    if ($db){
        return( $db->getCamposAsHash );
    }else{
        return (0);
    }
}


=item
obtenerValoresTablaRef
Obtiene las tuplas con los campos requeridos de la tabla a la cual se esta haciendo referencia. Devuelve un string json y una hash.
=cut
sub obtenerValoresTablaRef{
    my ($tableAlias,$campo, $orden)=@_;

    use C4::Modelo::PrefTablaReferencia;
    my $ref = C4::Modelo::PrefTablaReferencia->new();
	my ($cantidad,$valores)= $ref->obtenerValoresTablaRef($tableAlias,$campo, $orden);

    return($cantidad,$valores);

}

=item
obtenerIdentTablaRef
Obtiene el campo clave de la tabla a la cual se esta asi referencia
=cut
sub obtenerIdentTablaRef{
    my ($tableAlias)=@_;

    use C4::Modelo::PrefTablaReferencia;
    my $ref = C4::Modelo::PrefTablaReferencia->new();

    return($ref->obtenerIdentTablaRef($tableAlias));
}

=item
Devuelve el nombre del pais segun el iso pasado por paramentro, si no existe devuelve 0
=cut
sub getNombrePais {
	my ($iso)= @_;

    my $pais_array_ref = C4::Modelo::RefPais::Manager->get_ref_pais(
																	query => [ iso => $iso]
														);

	if(scalar(@$pais_array_ref) > 0){
 		return $pais_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}


=item
Devuelve el nombre del del tipo de documento segun el id_tipo_doc pasado por paramentro, si no existe devuelve 0
=cut
sub getNombreTipoDocumento {
	my ($id_tipo_doc)= @_;

    my $tipo_doc_array_ref = C4::Modelo::CatRefTipoNivel3::Manager->get_cat_ref_tipo_nivel3(
																	query => [ id_tipo_doc => $id_tipo_doc]
														);

	if(scalar(@$tipo_doc_array_ref) > 0){
 		return $tipo_doc_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}

=item
Devuelve el nombre del la ciudad segun el paramentro pasado, si no existe devuelve 0
=cut
sub getNombreCiudad {
	my ($localidad)= @_;

    my $localidad_array_ref = C4::Modelo::RefLocalidad::Manager->get_ref_localidad(
																	query => [ LOCALIDAD => $localidad ]
														);

	if(scalar(@$localidad_array_ref) > 0){
 		return $localidad_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}

sub getNombreLenguaje {
	my ($id_lenguaje)= @_;

    my $idioma_array_ref = C4::Modelo::RefIdioma::Manager->get_ref_idioma(
																	query => [ idLanguage => $id_lenguaje ]
														);

	if(scalar(@$idioma_array_ref) > 0){
 		return $idioma_array_ref->[0]->getDescription;
	}else{
		return 0;
	}
}

sub getNombreSoporte {
	my ($idSupport)= @_;

    my $soporte_array_ref = C4::Modelo::RefSoporte::Manager->get_ref_soporte(
																	query => [ idSupport => $idSupport ]
														);

	if(scalar(@$soporte_array_ref) > 0){
 		return $soporte_array_ref->[0]->getDescription;
	}else{
		return 0;
	}
}

sub getNombreNivelBibliografico {
	my ($code)= @_;

    my $nivel_bibliografico_array_ref = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico(
																	query => [ code => $code ]
														);

	if(scalar(@$nivel_bibliografico_array_ref) > 0){
 		return $nivel_bibliografico_array_ref->[0]->getDescription;
	}else{
		return 0;
	}
}

sub getNombreUI {
	my ($id_ui)= @_;

    my $ui_array_ref = C4::Modelo::PrefUnidadInformacion::Manager->get_pref_unidad_informacion(
																	query => [ id_ui => $id_ui ]
														);

	if(scalar(@$ui_array_ref) > 0){
 		return $ui_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}

sub getNombreEstado {
	my ($codigo)= @_;

    my $estado_array_ref = C4::Modelo::RefEstado::Manager->get_ref_estado(
																	query => [ codigo => $codigo ]
														);

	if(scalar(@$estado_array_ref) > 0){
 		return $estado_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}

sub getNombreDisponibilidad {
	my ($codigo)= @_;

    my $disponibilidad_array_ref = C4::Modelo::RefDisponibilidad::Manager->get_ref_disponibilidad(
																	query => [ codigo => $codigo ]
														);

	if(scalar(@$disponibilidad_array_ref) > 0){
 		return $disponibilidad_array_ref->[0]->getNombre;
	}else{
		return 0;
	}
}


sub getNombreAutor {
	my ($id)= @_;

    my $autor_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor(
																	query => [ id => $id ]
														);

	if(scalar(@$autor_array_ref) > 0){
 		return $autor_array_ref->[0]->getCompleto;
	}else{
		return 0;
	}
}

=item
Retorna el objeto autor segun el id pasado por parametro, si no existe el autor retorna 0
=cut
sub getAutor {
	my ($id)= @_;

    my $autor_array_ref = C4::Modelo::CatAutor::Manager->get_cat_autor(
																	query => [ id => $id ]
														);

	if(scalar(@$autor_array_ref) > 0){
 		return $autor_array_ref->[0];
	}else{
		return 0;
	}
}

1;
