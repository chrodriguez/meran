package C4::AR::EstructuraCatalogacionBase;

=item
Este modulo sera el encargado del manejo de la carga de datos en las tablas MARC
Tambien en la carga de los items en los distintos niveles y de la creacion del catalogo.
=cut
use strict;
require Exporter;
use C4::Context;
use C4::Modelo::PrefEstructuraSubcampoMarc::Manager;
use C4::Modelo::PrefEstructuraSubcampoMarc;


use vars qw(@EXPORT @ISA);

@ISA=qw(Exporter);

@EXPORT=qw(
	&getCamposXLike
    &getSubCampos
    &getSubCamposLike
    &getEstructuraBaseFromCampoSubCampo
);


=head2 sub getCamposXLike
    Busca un campo like..., segun nivel indicado
=cut
sub getCamposXLike{
    my ($nivel,$campoX) = @_;

    my @filtros;

    push(@filtros, ( campo => { like => $campoX.'%'} ) );
    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                                        query => \@filtros,
                                                                                        sort_by => ('campo'),
                                                                                        select   => [ 'campo', 'liblibrarian'],
                                                                                        group_by => [ 'campo'],
                                                                       );
    return($db_campos_MARC);
}

=head2 sub getSubCampos
    Obtiene los subcampos MARC para el nivel indicado
=cut
sub getSubCampos{
    my ($nivel) = @_;

    my @filtros;

    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                query => \@filtros,
                                                            );
    return($db_campos_MARC);
}

=head2 sub getSubCamposLike
    Obtiene los subcampos haciendo busqueda like, para el nivel indicado
=cut
sub getSubCamposLike{
    my ($nivel,$campo) = @_;

    my @filtros;

    push(@filtros, ( campo => { eq => $campo} ) );
    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                query => \@filtros,
                                                                sort_by => ('subcampo'),
                                                                select   => [ 'subcampo', 'liblibrarian', 'obligatorio' ],
                                                                group_by => [ 'subcampo'],
                                                            );
    return($db_campos_MARC);
}


=head2 sub getEstructuraBaseFromCampo
    Esta funcion retorna la estructura BASE de MARC segun un campo
=cut
sub getEstructuraBaseFromCampo{
    my ($campo) = @_;

    my @filtros;

    push(@filtros, ( campo      => { eq => $campo } ) );

    my $estructura_base = C4::Modelo::PrefEstructuraCampoMarc::Manager->get_pref_estructura_campo_marc(
                                                                                        query    => \@filtros,
                                                                       );

    if(scalar(@$estructura_base) > 0){  
        return $estructura_base->[0];
    }else{
        return 0;
    }
}

=head2 sub getEstructuraBaseFromCampoSubCampo
    Esta funcion retorna la estructura BASE de MARC segun un campo y subcampo
=cut
sub getEstructuraBaseFromCampoSubCampo{
    my ($campo, $subcampo) = @_;

    my @filtros;

    push(@filtros, ( campo      => { eq => $campo } ) );
    push(@filtros, ( subcampo   => { eq => $subcampo } ) );

    my $estructura_base = C4::Modelo::PrefEstructuraSubcampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                                        query    => \@filtros,
                                                                       );

    if(scalar(@$estructura_base) > 0){  
        return $estructura_base->[0];
    }else{
        return 0;
    }
}


=head2 sub getNivelFromEstructuraBaseByCampo
    Esta funcion retorna el nivel de la estructura BASE de MARC segun un campo
=cut
sub getNivelFromEstructuraBaseByCampo{
    my ($campo) = @_;

    my @filtros;

    push(@filtros, ( campo  => { eq => $campo } ) );

    my $estructura_base = C4::Modelo::PrefEstructuraCampoMarc::Manager->get_pref_estructura_campo_marc(
                                                                                        select  => ['nivel'],
                                                                                        query   => \@filtros,
                                                                       );

    if(scalar(@$estructura_base) > 0){  
        return $estructura_base->[0]->getNivel;
    }else{
        return 0;
    }
}

=head2 sub getCampos
    Obtiene los campos MARC para el nivel indicado desde la estructura de campos marc
=cut
sub getCampos{
    my ($nivel) = @_;

    my @filtros;

    push(@filtros, ( nivel => { eq => $nivel } ) );

    my $db_campos_MARC = C4::Modelo::PrefEstructuraCampoMarc::Manager->get_pref_estructura_subcampo_marc(
                                                                query => \@filtros,
                                                            );
    return($db_campos_MARC);
}
