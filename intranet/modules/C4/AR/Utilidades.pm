package C4::AR::Utilidades;

#Este modulo provee funcionalidades varias sobre las tablas de referencias en general, además de funciones que sirven como 
#apoyo a la funcionalidad de Meran. No existe una division clara de lo que incluye y lo que no, por lo tanto resta leer los comentarios de
#cada función.
#Escrito el 8/9/2006 por einar@info.unlp.edu.ar
#Update por Carbone Migue, Rajoy Gaspar
#
#Copyright (C) 2003-2006  Linti, Facultad de Informática, UNLP

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;
use C4::AR::Estadisticas;
use C4::AR::Referencias;
use C4::AR::ControlAutoridades;
use CGI::Session;
use CGI;
use Encode;
use JSON;
use POSIX qw(ceil floor); #para redondear cuando divido un numero
use Digest::SHA  qw(sha1 sha1_hex sha1_base64 sha256_base64 );

#use C4::Date;
use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
    &aplicarParches 
    &obtenerParches
    &obtenerTiposDeColaboradores 
    &obtenerReferencia 
    &obtenerTemas 
    &obtenerEditores 
    &noaccents 
    &saveholidays 
    &getholidays 
    &savedatemanip 
    &obtenerValores 
    &actualizarCampos 
    &buscarTablasdeReferencias 
    &listadoTabla 
    &obtenerCampos 
    &valoresTabla 
    &tablasRelacionadas 
    &valoresSimilares 
    &asignar 
    &obtenerDefaults 
    &guardarDefaults 
    &mailDeUsuarios 
    &obtenerAutores 
    &obtenerPaises 
    &crearComponentes 
    &obtenerTemas2 
    &obtenerBiblios 
    &verificarValor 
    &cantidadRenglones 
    &armarPaginas 
    &crearPaginador 
    &InitPaginador
    &from_json_ISO 
    &UTF8toISO 
    &obtenerIdentTablaRef 
    &obtenerValoresTablaRef 
    &obtenerValoresAutorizados 
    &obtenerDatosValorAutorizado
    &cambiarLibreDeuda 
    &checkdigit 
    &checkvalidisbn 
    &quitarduplicados
    &buscarCiudades
    &trim
    &validateString
    &joinArrayOfString
    &buscarLenguajes
    &buscarSoportes
    &buscarNivelesBibliograficos
    &generarComboTipoPrestamo
    &generarComboDeSocios
    &generarComboPermisos
    &generarComboPerfiles
    &generarComboTipoDeOperacion
    &existeInArray
    &paginarArreglo
    &capitalizarString
    &ciudadesAutocomplete
    &redirectAndAdvice
    &generarComboDeAnios
    &generarComboDeCredentials
    &generarComboTemasOPAC
    &generarComboTemasINTRA
    &getFeriados

);

# para los combos que no usan tablas de referencia
my @VALUES_COMPONENTS = (   "-1", "text", "texta", "texta2", "combo", "auto", "calendar", "anio" );
my %LABELS_COMPONENTS = (   "-1" => "SIN SELECCIONAR" => "text" => "Texto" , "texta" => "Texto Area", "texta2" => "Texto 1 por linea", 
                            "combo" => "ComoBox", "auto" => "Autocompletable", "calendar" => "Calendario", "anio" => "A&ntilde;o" );

=item sub getStringFor
    Devuelve el texto de la clave pasada por parametro
=cut
sub getStringFor{
    my ($key) = @_;

    if(defined %LABELS_COMPONENTS->{$key}){
        return C4::AR::Filtros::i18n(%LABELS_COMPONENTS->{$key});
    }else{ 
        return "INDEFINIDO";
    }
}

sub generarComboComponentes{
    my ($params) = @_;


    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}   = $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}    = $params->{'onFocus'};
    }
    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}     = $params->{'onBlur'};
    }

    $options_hash{'name'}           = $params->{'name'}||'disponibilidad_name';
    $options_hash{'id'}             = $params->{'id'}||'disponibilidad_id';
    $options_hash{'size'}           = $params->{'size'}||1;
    $options_hash{'multiple'}       = $params->{'multiple'}||0;
    $options_hash{'defaults'}       = $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultComboComponentes");
    $options_hash{'values'}         = \@VALUES_COMPONENTS;
    $options_hash{'labels'}         = \%LABELS_COMPONENTS;

    my $comboDeComponentes          = CGI::scrolling_list(\%options_hash);

    return $comboDeComponentes;
}

=item
crearComponentes
Crea los componentes que van a ir al tmpl.
$tipoInput es el tipo de componente que se va a crear en el tmpl.
$id el id del componente para poder recuperarlo.
$values los valores o que puede devolver el componente (combo, radiobotton y checkbox)
$labels lo que va a mostrar el componente (combo, radiobotton y checkbox).
$valor es el valor por defecto que tiene el componente, si es que tiene.
=cut

sub generarComboDeAnios{
    my $year_Default="Seleccione";
    my @years;
    my @yearsValues;
    push (@years,"Seleccione");
    for (my $i =2000 ; $i < 2036; $i++){
        push (@years,$i);
    }
    my $year_select=CGI::scrolling_list(   -name      => 'year',
                    -id    => 'year',
                                    -values    => \@years,
                                    -defaults  => 0,
                                    -size      => 1,
                                    -onChange  =>'consultar()'
                                );
    return ($year_select);
}


sub generarComboTemasOPAC{
    my ($params) = @_;
    my (@label,@values);
    my $temas = C4::AR::Preferencias::getPreferenciasByCategoria("temas_opac");
    my %labels;
    my %options_hash; 

    foreach my $pref (@$temas){
        push (@values,$pref->getValue());
        $labels{$pref->getValue()} = $pref->getValue();
    }
    
    my $socio = C4::Auth::getSessionNroSocio();
    $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($socio) || C4::Modelo::UsrSocio->new();

    $options_hash{'values'}= \@values;
    $options_hash{'labels'}=\%labels;
    $options_hash{'defaults'}= $socio->getTheme() || 'default';
    $options_hash{'size'}= 1;
    $options_hash{'name'}= 'temas_opac';
    $options_hash{'id'}= 'temas_opac';

    my $select = CGI::scrolling_list(\%options_hash);

    return($select);

}


sub generarComboTemasINTRA{
    my ($nro_socio) = @_;
    my (@label,@values);
    my $temas = C4::AR::Preferencias::getPreferenciasByCategoria("temas_intra");
    my %labels;
    my %options_hash; 

    foreach my $pref (@$temas){
        push (@values,$pref->getValue());
        $labels{$pref->getValue()} = $pref->getValue();
    }
    
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio) || C4::Modelo::UsrSocio->new();

    $options_hash{'values'}= \@values;
    $options_hash{'labels'}=\%labels;
    $options_hash{'defaults'}= $socio->getThemeINTRA() || 'default';
    $options_hash{'size'}= 1;
    $options_hash{'name'}= 'temas_intra';
    $options_hash{'id'}= 'temas_intra';

    my $select = CGI::scrolling_list(\%options_hash);

    return($select);

}

sub generarComboDeCredentials{

    my ($params) = @_;
    my @select_credentials;
    my %select_credentials;

    push @select_credentials, 'estudiante';
    push @select_credentials, 'librarian';
    push @select_credentials, 'superLibrarian';
    $select_credentials{'estudiante'} = 'estudiante';
    $select_credentials{'librarian'} = 'librarian';
    $select_credentials{'superLibrarian'} = 'superLibrarian';
    my $socio = C4::AR::Usuarios::getSocioInfoPorNroSocio($params->{'nro_socio'});

    my $default_credential = 'estudiante';
    if ($socio){
        $default_credential = $socio->getCredentialType;
    }

    my $CGIregular=CGI::scrolling_list(     -name      => 'credential',
                                            -id        => 'credential',
                                            -values    => \@select_credentials,
                                            -defaults  => $default_credential,
                                            -labels    => \%select_credentials,
                                            -size      => 1,
                                      );
    return ($CGIregular);
}

sub generarComboRegular{

    my @select_regular;
    my %select_regular;

    push @select_regular, '1';
    push @select_regular, '0';
    push @select_regular, 'Todos';
    $select_regular{'1'} = 'Regular';
    $select_regular{'0'} = 'Irregular';
    $select_regular{'Todos'} = 'Todos';

    my $CGIregular=CGI::scrolling_list(  -name      => 'regular',
                                            -id        => 'regular',
                                            -values    => \@select_regular,
                                            -defaults  => 'Todos',
                                            -labels    => \%select_regular,
                                            -size      => 1,
                                      );
    return ($CGIregular);
}


sub crearComponentes{

    my ($tipoInput,$id,$values,$labels,$valor)=@_;
    my $inputCampos;
    if ($tipoInput eq 'combo'){
        $inputCampos=CGI::scrolling_list(  
            -name      => $id,
            -id    => $id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
            -size      => 1,
                );
    }
    elsif($tipoInput eq 'radio'){
        $inputCampos=CGI::radio_group(
            -name      =>$id,
            -id        =>$id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
        );
        
        #el CGI::radio_group devuelve el radio entre tags <label>, se rompe el estilo, asi q se le saca los tags <label>
        $inputCampos = reemplazarEnString($inputCampos, '<label>', '');
        $inputCampos = reemplazarEnString($inputCampos, '<\/label>', '');
    }
    elsif($tipoInput eq 'check'){
        $inputCampos=CGI::checkbox_group(
            -name   =>$id,
            -id =>$id,
            -values    => $values,
            -labels    => $labels,
            -default   => $valor,
        );
    }
    elsif($tipoInput eq 'text'){
        $inputCampos=CGI::textfield(
            -name   =>$id,
            -id =>$id,
            -value  =>$valor,
            -size   =>$values,
                );
    }
    elsif($tipoInput eq 'texta'){
        $inputCampos=CGI::textarea(
            -name    =>$id,
            -id  =>$id,
            -value   =>$valor,
            -rows    =>$labels,
            -cols    =>$values,
                );
    }
    else{
        $inputCampos= CGI::hidden(-id=>$id,);
    }
    return($inputCampos);
}


#Obtiene los mail de todos los usuarios
# FIXME deprecated, o pasar a Rose y hacer el reporte
=item
sub mailDeUsuarios {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT emailaddress 
                FROM  borrowers 
                WHERE (emailaddress IS NOT NULL) AND (emailaddress <> '')");
    $sth->execute();
    my @results;
    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data); 
    }
      
    $sth->finish;

    return(@results);
}
=cut
sub in_array{

    my $val = shift @_ || return 0;
    my @array = @_;
    foreach (@array)
            { return 1 if ($val eq $_); }
    return 0;
}


=item
Esta funcion reemplaza en string lo indicado por cadena_a_reemplazar por cadena_reemplazo, con expresiones regulares
tener en cuenta escapar algunos caracteres como <\label> => <\/label>
=cut
sub reemplazarEnString{
    my ($string, $cadena_a_reemplazar, $cadena_reemplazo) = @_;

    $string =~ s/$cadena_a_reemplazar/$cadena_reemplazo/g;  

    return $string;  
}

sub array_diff{

# A $array1 le resta $array2
    my ($array1_ref,@array2) = @_;
    my @array_res;
    foreach (@$array1_ref) {
        push(@array_res, $_) unless (&in_array($_,@array2));
    }
    return(@array_res);
}

sub saveholidays{

    my ($hol) = @_;
    if ($hol){ # FIXME falla si borro todos los feriados
        my @feriados = split(/,/, $hol);
        savedatemanip(@feriados);
        my ($cant,@feriados_anteriores)= &getholidays();
        my @feriados_nuevos= &array_diff(\@feriados,@feriados_anteriores);
        my @feriados_borrados= &array_diff(\@feriados_anteriores,@feriados);
        foreach (@feriados_nuevos) { updateForHoliday($_,"+"); }
        foreach (@feriados_borrados) { updateForHoliday($_,"-"); }
        my $dbh = C4::Context->dbh;
#Se borran todos los feriados de la tabla
        if (scalar(@feriados_borrados)) {
            my $sth=$dbh->prepare(" DELETE FROM pref_feriado 
                                    WHERE fecha IN (".join(',',map {"('".$_."')"} @feriados_borrados).")");
            $sth->execute();
            $sth->finish;
        }
#Se dan de alta todos los feriados
        if (scalar(@feriados_nuevos)) {
            my $sth=$dbh->prepare(" INSERT INTO pref_feriado (fecha) 
                                    VALUES ".join(',',map {"('".$_."')"} @feriados_nuevos));
            $sth->execute();
            $sth->finish;
        }
    }
}

sub obtenerTiposDeColaboradores{

    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT codigo,descripcion 
                            FROM cat_ref_colaborador 
                            ORDER BY (descripcion)");
    $sth->execute();
    my %results;
    while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
    $results{$data->{'codigo'}}=$data->{'descripcion'};
    }
    # while
    $sth->finish;
    return(%results);#,@results);
}

=item obtenerParches
la funcion obtenerParches devuelve toda la informacion sobre los parches de actualizacion que hay que aplpicar, con esto se logra cambiar de la version 2 a las versiones futuras sin problemas, via web
=cut
sub obtenerParches{

    my ($version)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                            FROM parches 
                            WHERE (corresponde > ?) 
                            ORDER BY (id)");
    $sth->execute($version);
    my @results;
    while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
        push(@results,$data);
    }
    # while
    $sth->finish;
    return(@results);
}

=item aplicarParches
la funcion aplicarParches aplica el parche que le llega por parametro.
Para hacer esto lo que hace es leer la base de datos y aplicar las instrucciones mysql que corresponden con ese parche 
=cut
sub aplicarParches{

    my ($parche)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                            FROM parches_scripts 
                            WHERE (parche= ?) 
                            ORDER BY (id)");
    $sth->execute($parche);
    my $sth2;
    my $error='';
    while (my $data = $sth->fetchrow_hashref) {#push(@results, $data); 
        $sth2=$dbh->prepare($data->{'sql'});
        $sth2->execute();  
        if ($sth2 -> errstr){
            $error=$sth2 -> errstr;
        }
        # while
        $sth->finish;
        if (not $error){
            my $sth3=$dbh->prepare("UPDATE parches 
                                    SET aplicado='1' 
                                    WHERE id=?");
            $sth3->execute($parche);
        }
    }
    $sth2->finish;
    return($error);
}


sub getholidays{

    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                            FROM pref_feriado");
    $sth->execute();

    my @results;

    while (my $data = $sth->fetchrow) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(scalar(@results),@results);
}

#27/03/07 Miguel - Cuando agregaba un autor en Colaboradores
#obtenerReferencia devuelve los autores cuyos apellidos sean like el parametro
sub obtenerReferencia{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT UPPER(concat_ws(', ',apellido,nombre)) 
                            FROM cat_autor 
                            WHERE apellido LIKE ? 
                            ORDER BY apellido 
                            LIMIT 0,15");
    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

#obtenerReferencia devuelve los autores cuyos apellidos sean like el parametro
sub obtenerAutores{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT completo, id 
                            FROM cat_autor 
                            WHERE apellido LIKE ? 
                            ORDER BY (apellido)");
    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

=head2
    sub obtenerPaises
=cut
sub obtenerPaises{

#    my ($dato)=@_;
    #   my $dbh = C4::Context->dbh;
    #my $sth=$dbh->prepare(" SELECT nombre_largo, iso 
    #                        FROM ref_pais 
    #                        WHERE nombre_largo LIKE ? 
    #                        ORDER BY (nombre_largo)");

    #$sth->execute($dato.'%');

    #my @results;

    #while (my $data = $sth->fetchrow_hashref) {
    #    push(@results, $data);
    #} # while
    #$sth->finish;
    #return(@results);

    my ($pais) = @_;

    my @filtros;

    push(@filtros, ( nombre_largo => { like => $pais.'%'}) );

    my $paises_array_ref = C4::Modelo::RefPais::Manager->get_ref_pais(

        query => \@filtros,
        sort_by => 'nombre_largo ASC',
        limit   => C4::AR::Preferencias->getValorPreferencia("limite_resultados_autocompletables"),
    );

    return (scalar(@$paises_array_ref), $paises_array_ref);

    
}

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerTemas{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("select catalogueentry from catalogueentry where catalogueentry LIKE ? order by catalogueentry limit 0,15");
    my $sth=$dbh->prepare(" SELECT nombre 
                            FROM cat_tema 
                            WHERE nombre LIKE ? 
                            ORDER BY nombre 
                            LIMIT 0,15");

    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

sub obtenerTemas2{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT nombre, id 
                            FROM cat_tema 
                            WHERE nombre LIKE ? 
                            ORDER BY nombre");

    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data);
    } # while
    $sth->finish;
    return(@results);
}

#obtenerEditores devuelve los editores que sean like el parametro
sub obtenerEditores{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT UPPER(concat_ws(', ',apellido,nombre)) 
                            FROM cat_autor 
                            WHERE apellido LIKE ? 
                            ORDER BY (apellido) 
                            LIMIT 0,15");

    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}

sub obtenerBiblios{

    my ($dato)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT branchname, branchcode AS id 
                            FROM pref_unidad_informacion 
                            WHERE branchname LIKE ? 
                            ORDER BY branchname");

    $sth->execute($dato.'%');

    my @results;

    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data);
    } # while
    $sth->finish;
    return(@results);
}

sub noaccents{

    my $word = @_[0];
    my @chars = split(//,$word);
    my $newstr = ""; 
    foreach my $ch (@chars) {
        if (ord($ch) == 225 || ord($ch) == 193) {$newstr.= 'a'} 
        elsif (ord($ch) == 233 || ord($ch) == 201) {$newstr.= 'e'}
        elsif (ord($ch) == 237 || ord($ch) == 205) {$newstr.= 'i'}
        elsif (ord($ch) == 243 || ord($ch) == 211) {$newstr.= 'o'}
        elsif (ord($ch) == 250 || ord($ch) == 218) {$newstr.= 'u'}
        else {$newstr.= $ch}
    } 
    return(uc($newstr));
}

sub savedatemanip{

    my @feriados= @_;
#Actualizo el archivo de configuracion de DateManip
    open (F,'>/var/www/.DateManip.cnf'); #FIXME hay que sacar /var/www/ y poner algo asi como $ENV{HOME}
    printf F "*Holiday\n\n";
    foreach my $f (@feriados) {
        my @fecha = split('-',$f);
        my $fnue = $fecha[2].'/'.$fecha[1].'/'.$fecha[0];

        printf F $fnue."\t= Feriado\n\n";
    }
    close F;
}


sub listadoTabla{

    my($tabla,$ind,$cant,$id,$orden,$search,$bloqueIni,$bloqueFin)=@_;
    #$cant=$cant+$ind;
    ($id||($id=0));

    $search=$search.'%';

    my $dbh = C4::Context->dbh;
    # my $sth=$dbh->prepare("select count(*) from $tabla  where $orden like '$search'");
    # $sth->execute();
    my $sth;
    my @cantidad;

    if( ($bloqueIni ne "")&&($bloqueFin ne "") ){
        $sth=$dbh->prepare("    SELECT count(*)
                                FROM $tabla
                                WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' ");

        $sth->execute();
        @cantidad=$sth->fetchrow_array;

        $sth=$dbh->prepare("    SELECT *
                                FROM $tabla
                                WHERE $orden BETWEEN  '$bloqueIni%' AND '$bloqueFin%' 
                                ORDER BY $orden limit $ind,$cant ");
        $sth->execute();
    }else{
        $sth=$dbh->prepare("  SELECT COUNT(*) 
                                FROM $tabla  
                                WHERE $orden LIKE '$search'");
        $sth->execute();

        @cantidad=$sth->fetchrow_array;
        $sth=$dbh->prepare("    SELECT * 
                                FROM $tabla 
                                WHERE $orden LIKE '$search' 
                                ORDER BY $orden LIMIT $ind,$cant");
        $sth->execute();
    }

    my @results;

    while (my @data=$sth->fetchrow_array){
        my @results2;
        my $i;

        for ($i=0;$i<@data;$i++) {
            my $aux;
            $aux->{'campo'} = $data[$i];
                push(@results2,$aux);
        }

        my $aux2;

        $aux2->{'registro'}=\@results2;
        $aux2->{'id'}=$data[$id];
        push(@results,$aux2);
    }

    $sth->finish;
    return ($cantidad[0],@results);
}

#devuelve los valores de un elemento en particular de la tabla de referencia que se esta editando
#recibe la tabla, el nombre del campo que es identificador y el valor que debe buscar 
#estos tres parametros se obtienen anteriorimente de la tabla tablasDeReferencias
sub valoresTabla{

    my ($tabla,$indice,$valor)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("SHOW FIELDS FROM $tabla");

    $sth->execute();

    my @results;

    while (my @data=$sth->fetchrow_array){
        my $aux;
        $aux->{'campo'} = $data[0];
            push(@results,$aux);
    }

    $sth=$dbh->prepare("    SELECT * 
                            FROM $tabla 
                            WHERE $indice=?");
    $sth->execute($valor);

    my @results2;

    while (my $data=$sth->fetchrow_hashref){
        my $i;
        foreach $i (@results){
            my $aux;
            $aux->{'campo'} = $i->{'campo'};
            $aux->{'valor'}=$data->{$i->{'campo'}};
            push(@results2,$aux);
        }
    }
    $sth->finish;
    return @results2;
}


sub tablasRelacionadas{

    my ($tabla,$indice,$valor)=@_;

    my $dbh = C4::Context->dbh;

    #Se verfica si tiene referencias
    #Tabla referencias
    #referencia nomcamporeferencia camporeferencia referente             camporeferente
    #autores    id      0       biblio          author
    #autores    id      0       colaboradores       idColaborador
    #autores    id      0       additionalauthors   author
    #autores    id      0       analyticalauthors   author
    my $sth=$dbh->prepare(" SELECT * 
                            FROM pref_tabla_referencia 
                            WHERE referencia= ?");
    $sth->execute($tabla);

    my @results;

    while (my $data=$sth->fetchrow_hashref){
        my $aux;
        my $sth2=$dbh->prepare("SELECT $data->{'nomcamporeferencia'} 
                                FROM $data->{'referencia'} 
                                WHERE $indice = ?");
        $sth2->execute($valor);

        my $identificador=$sth2->fetchrow_array;

        $sth2=$dbh->prepare("   SELECT COUNT(*) 
                                FROM $data->{'referente'} 
                                WHERE $data->{'camporeferente'}= ?");
        $sth2->execute($identificador);
        $aux->{'relacionadoTabla'} = $data->{'referente'};
        if (my $canti= $sth2->fetchrow_array){
            $aux->{'relacionadoTablaCantidad'}=$canti;
            push(@results,$aux);
        }
    }
    return @results;
}



#devuelve los valores similares de un elemento en particular de la tabla de referencia que se esta editando basandose en la tablaDeReferenciaInfo 
#recibe la tabla, el nombre del campo que es identificador y el valor que debe buscar 
#estos tres parametros se obtienen anteriorimente de la tabla tablasDeReferencias
sub valoresSimilares{

    my($tabla,$camporeferencia,$id)=@_;
    ($id||($id=0));
    my $dbh = C4::Context->dbh;
    #Obtengo que campo voy a utilizar para buscar similares, es en tablasDeReferenciasInfo
    my $sth=$dbh->prepare(" SELECT similares 
                FROM pref_tabla_referencia_info 
                WHERE referencia=? ");

    $sth->execute($tabla);

    my $similar=$sth->fetchrow_array;
    #Busco el valor del campo similar que corresponde al registro para el cual estoy buscando similares 

    $sth=$dbh->prepare("    SELECT $similar 
                FROM $tabla 
                WHERE $camporeferencia = ? 
                LIMIT 0,1");
    $sth->execute($id);

    my $valorAbuscarSimil=$sth->fetchrow_array;
    my $tamano=(length($valorAbuscarSimil))-1;
    #Busco los valores similares, con una expresion regular que busca aquellas tuplas que coincidan en campo similar en todos los caracteres-1 del original

    $sth=$dbh->prepare("    SELECT * 
                            FROM $tabla 
                            WHERE $similar REGEXP '[$valorAbuscarSimil]{$tamano,}' AND $camporeferencia  != ? 
                            ORDER BY $similar 
                            LIMIT 0,15");
    $sth->execute($id);

    my $sth3=$dbh->prepare("SELECT camporeferencia 
                            FROM pref_tabla_referencia 
                            WHERE referencia=? 
                            LIMIT 0,1");
    $sth3->execute($tabla);

    my $idnum=$sth3->fetchrow_array;
    my @results;

    while (my @data=$sth->fetchrow_array){
        my @results2;
        my $i;
        for ($i=0;$i<@data;$i++) {
            my $aux;
            $aux->{'campo'} = $data[$i];
            push(@results2,$aux);
        }
        my $aux2;

        $aux2->{'registro'}=\@results2;
        $aux2->{'id'}=$data[$idnum];
        push(@results,$aux2);
    }
    $sth->finish;
    return (@results);
}

#Busca todas las tablas relacionadas con $tabla y actualiza la referencia a el nuevo valor que esta en valorNuevo. Ej: actualiza todos los libros para que hayan sido escritos por autor id=58 y le pone que fueron esvcritos por autor id=60 
sub asignar{

    my ($tabla,$indice,$identificador,$valorNuevo,$borrar)=@_;
    #ACa hay q hacer q sea una transaccion
    my $dbh = C4::Context->dbh;
    my $asignar;
    my $sthT=$dbh->prepare("START TRANSACTION");

    $sthT->execute();

    my $sth=$dbh->prepare(" SELECT * 
                            FROM pref_tabla_referencia 
                            WHERE referencia= ?");
    $sth->execute($tabla);

    my @results;
    my $asignar=0;

    while (my $data=$sth->fetchrow_hashref){
        $asignar=1;
        my $aux;
        my $sth2=$dbh->prepare("SELECT $data->{'nomcamporeferencia'} 
                                FROM $data->{'referencia'} 
                                WHERE $indice = ?");
        $sth2->execute($identificador);
        my $identificador2=$sth2->fetchrow_array;

        $sth2=$dbh->prepare("   UPDATE $data->{'referente'} 
                                SET $data->{'camporeferente'}= ? 
                                WHERE $data->{'camporeferente'}= ?");
        $sth2->execute($valorNuevo,$identificador2);
    }
    if ($borrar){
        my $sth3=$dbh->prepare("DELETE FROM $tabla 
                                WHERE $indice= ?");
        $sth3->execute($identificador);
        $borrar=1;
    }
    $sthT=$dbh->prepare("COMMIT");
    $sthT->execute();
    return ($asignar,$borrar);
}

sub obtenerValores{

    my ($tabla,$indice,$valor)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("SHOW FIELDS FROM ?");

    $sth->execute($tabla);
    my @data=$sth->fetchrow_array;

    $sth=$dbh->prepare("    SELECT * 
                            FROM ? 
                            WHERE ?=?");
    $sth->execute($tabla,$indice,$valor);
    my $data2=$sth->fetchrow_hashref;

    $sth->finish;
    my %row;

    foreach my $campo (@data) {
        my %row = ($campo => $data2->{$campo});
    }
    return \%row;
}

#Esta funcion recibe tres parametros, el nombre de la tabla que se esta editando, el campo identificador de la tabla y un hash de los campos y valores que se van a actualizar en esa tabla   
sub actualizarCampos{

    my ($tabla,$id,%valores)=@_;
    my $dbh = C4::Context->dbh;
    my $sql='';

    foreach my $key (keys(%valores)){
        $sql.=', '.$key.'="'.$valores{$key}.'"';
    }
    $sql=substr($sql,2);
    my $sth=$dbh->prepare(" UPDATE $tabla 
                            SET $sql 
                            WHERE $id=?");

    $sth->execute($valores{$id});
    $sth->finish;
}

#obtenerTemas devuelve los temas que sean like el parametro
sub obtenerDefaults{

    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" SELECT * 
                FROM defaultbiblioitem");

    $sth->execute();
    my @results;

    while (my $data = $sth->fetchrow_hashref) {
        push(@results, $data); 
    } # while
    $sth->finish;
    return(@results);
}
sub guardarDefaults{

    my ($biblioitem)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare(" UDPATE defaultbiblioitem 
                            SET valor = ? 
                            WHERE campo=?");

    $sth->execute($biblioitem->{'volume'},'volume');
    $sth->execute($biblioitem->{'number'},'number');
    $sth->execute($biblioitem->{'classification'},'selectlevel');
    $sth->execute($biblioitem->{'itemtype'},'selectitem');
    $sth->execute($biblioitem->{'isbncode'},'isbn');
    $sth->execute($biblioitem->{'issn'},'issn');
    $sth->execute($biblioitem->{'lccn'},'lccn');
    $sth->execute($biblioitem->{'publishercode'},'publishercode');
    $sth->execute($biblioitem->{'publicationyear'},'publicationyear');
    $sth->execute($biblioitem->{'dewey'},'dewey');
    $sth->execute($biblioitem->{'url'},'url');
    $sth->execute($biblioitem->{'volumeddesc'},'volumeddesc');
    $sth->execute($biblioitem->{'illus'},'illus');
    $sth->execute($biblioitem->{'pages'},'pages');
    $sth->execute($biblioitem->{'bnotes'},'notes');
    $sth->execute($biblioitem->{'size'},'size');
    $sth->execute($biblioitem->{'place'},'place');
    $sth->execute($biblioitem->{'language'},'selectlang');
    $sth->execute($biblioitem->{'support'},'selectsuport');
    $sth->execute($biblioitem->{'country'},'selectcountry');
    $sth->execute($biblioitem->{'serie'},'serie');
}

=item
verificarValor
Verifica que el valor que ingresado no tenga sentencias peligrosas, se filtran.
=cut
sub verificarValor{
    my ($valor) = @_;

    my @array = split(/;/,$valor);

    if(scalar(@array) > 1){
        #por si viene un ; saco las palabras peligrosas, que son las de sql.
        $valor=~ s/\b(SELECT|WHERE|INSERT|SHUTDOWN|DROP|DELETE|UPDATE|FROM|AND|OR|BETWEEN)\b/ /gi;
    }
    $valor=~ s/%|"|'|=|;|\*|-(<,>)//g;    
    $valor=~ s/\<SCRIPT>|\<\/SCRIPT>//gi;

    return $valor;
}

#*****************************************Paginador*********************************
#Funciones para paginar en el Servidor
#

sub InitPaginador{

    my ($iniParam,$obj)=@_;
    my $pageNumber;
    my $ini;
    my $cantR=cantidadRenglones();

    if (($iniParam eq "")|($iniParam <= 0)){
            $ini=0;
        $pageNumber=1;
    } else {
        $ini= ($iniParam-1)* $cantR;
        $pageNumber= $iniParam;
    };

    return ($ini,$pageNumber,$cantR);
}

sub crearPaginador{

    my ($cantResult, $cantRenglones, $pagActual, $funcion,$t_params)=@_;

    my ($paginador, $cantPaginas)=C4::AR::Utilidades::armarPaginas($pagActual, $cantResult, $cantRenglones,$funcion,$t_params);
    return $paginador;

}

sub armarPaginas{
#@actual, es la pagina seleccionada por el usuario
#@cantRegistros, cant de registros que se van a paginar
#@$cantRenglones, cantidad de renglones maximo a mostrar
#@$t_params, para obtener el path para las imagenes

# FIXME falta pasar las imagenes al estilo
    my ($actual, $cantRegistros, $cantRenglones,$funcion, $t_params)=@_;

    my $pagAMostrar=C4::AR::Preferencias->getValorPreferencia("paginas") || 10;
    my $numBloq=floor($actual / $pagAMostrar);
    my $limInf=($numBloq * $pagAMostrar);
    my $limSup=$limInf + $pagAMostrar;
    my $previous_text = "« ".C4::AR::Filtros::i18n('Anterior');
    my $next_text = C4::AR::Filtros::i18n('Siguiente')." »";
    if($limInf == 0){
        $limInf= 1;
        $limSup=$limInf + $pagAMostrar -1;
    }
    my $totalPaginas = ceil($cantRegistros/$cantRenglones);

    my $themelang= $t_params->{'themelang'};

    my $paginador= "<div class='pagination'><div id='content_paginator'  align='center' >";
    my $class="paginador";

    if($actual > 1){
        #a la primer pagina
        my $ant= $actual-1;
        $paginador .= "<a class='click previous' onClick='".$funcion."(".$ant.")' title='".$previous_text."'> ".$previous_text."</a>";

    }else{
        $paginador .= "<span class='disabled' title='".$previous_text."'>".$previous_text."</span>";
    }

    for (my $i=$limInf; ($totalPaginas >1 and $i <= $totalPaginas and $i <= $limSup) ; $i++ ) {
        my $onClick = "";
        if($actual == $i){
            $class="'current'";
        }else{
            $class="'pagination click'";
            $onClick = "onClick='".$funcion."(".$i.")'";
        }
        $paginador .= "<a class=".$class." ".$onClick."> ".$i." </a>";
    }

    if($actual >= 1 && $actual < $totalPaginas){
        my $sig= $actual+1;
        $paginador .= "<a class='click next' onClick='".$funcion."(".$sig.")' title='".$next_text."'>".$next_text."</a>";

    }
    $paginador .= "</div></div>"; 

    if ($totalPaginas <= 1){
      $paginador="";
    }
    return($paginador, $totalPaginas);
}

#
#Cantidad de renglones seteado en las preferencias del sistema para ver por cada pagina
sub cantidadRenglones{

    my $dbh = C4::Context->dbh;
    my $query="	SELECT value
                FROM pref_preferencia_sistema
                WHERE variable='renglones'";
    my $sth=$dbh->prepare($query);

    $sth->execute();

    return($sth->fetchrow_array);
}

#**************************************Fins***Paginador*********************************

=item
cambiarLibreDeuda
guarda el nuevo valor de la variable libreDeuda de la tabla de las preferencias
NOTA: cambiar de PM a uno donde esten todo lo referido a las preferencias de sistema, esta funcion se utiliza en los archivos adminLibreDeuda.pl y libreDeuda.pl
=cut
sub cambiarLibreDeuda{

    my ($valor)=@_;
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("	UPDATE pref_preferencia_sistema 
                            SET value=? 
                            WHERE variable='libreDeuda'");

    $sth->execute($valor);
}

=item 
checkdigit
  $valid = &checkdigit($env, $cardnumber $nounique);
Takes a card number, computes its check digit, and compares it to the
checkdigit at the end of C<$cardnumber>. Returns a true value iff
C<$cardnumber> has a valid check digit.
C<$env> is ignored.
VIENE DEL PM INPUT QUE FUE ELIMINADO
=cut
sub checkdigit{

    my ($env,$infl, $nounique) =  @_;
    $infl = uc $infl;
    #Check to make sure the cardnumber is unique
    #FIXME: We should make the error for a nonunique cardnumber
    #different from the one where the checkdigit on the number is
    #not correct
    unless ( $nounique ){
        my $dbh=C4::Context->dbh;
        my $query=qq{   SELECT * 
                        FROM borrowers 
                        WHERE cardnumber=?};
        my $sth=$dbh->prepare($query);

        $sth->execute($infl);
        my %results = $sth->fetchrow_hashref();

        if ( $sth->rows != 0 ){
            return 0;
        }
    }
    if (C4::AR::Preferencias->getValorPreferencia("checkdigit") eq "none") {
        return 1;
    }
    my @weightings = (8,4,6,3,5,2,1);
    my $sum;
    my $i = 1;
    my $valid = 0;

    foreach $i (1..7) {
        my $temp1 = $weightings[$i-1];
        my $temp2 = substr($infl,$i,1);

        $sum += $temp1 * $temp2;
    }

    my $rem = ($sum%11);

    if ($rem == 10) {
        $rem = "X";
    }
    if ($rem eq substr($infl,8,1)) {
        $valid = 1;
    }
    return $valid;
} # sub checkdigit

=item
checkvalidisbn
  $valid = &checkvalidisbn($isbn);
Returns a true value iff C<$isbn> is a valid ISBN: it must be ten
digits long (counting "X" as a digit), and must have a valid check
digit at the end.
VIENE DEL PM INPUT QUE FUE ELIMINADO
=cut
#--------------------------------------
# Determine if a number is a valid ISBN number, according to length
#   of 10 digits and valid checksum
# VIENE DEL PM INPUT QUE FUE ELIMINADO
sub checkvalidisbn{

    my ($q)=@_ ;    # Input: ISBN number
    my $isbngood = 0; # Return: true or false

    $q=~s/x$/X/g;           # upshift lower case X
    $q=~s/[^X\d]//g;
    $q=~s/X.//g;
    #return 0 if $q is not ten digits long
    if (length($q)!=10) {
        return 0;
    }
    #If we get to here, length($q) must be 10
    my $checksum=substr($q,9,1);
    my $isbn=substr($q,0,9);
    my $i;
    my $c=0;

    for ($i=0; $i<9; $i++) {
        my $digit=substr($q,$i,1);

        $c+=$digit*(10-$i);
    }
    $c %= 11;
    ($c==10) && ($c='X');
    $isbngood = $c eq $checksum;

    return ($isbngood);
} # sub checkvalidisbn

=item
quitarduplicados
simplemente devuelve el arreglo que recibe sin elementos duplicados
=cut
sub quitarduplicados{

    my (@arreglo)=@_;
    my @arreglosin=();

    for(my $i=0;$i<scalar(@arreglo);$i++){
        my $ok=1;

        for(my $j=0;$j<scalar(@arreglosin);$j++){
            if ($arreglo[$i] == $arreglosin[$j] ){
                $ok=0;
            }
        }

        if ($ok eq 1) {
            push(@arreglosin, $arreglo[$i] );
        }
    }
    return (@arreglosin);
}

#pasa de codificacion UTF8 a ISO-8859-1,
sub UTF8toISO {

    my ($data)=@_;
#POR QUE ROMPE LOS ACENTOS???? VERRRRRRRRRRRRRRRRRRRRRRR
    return $data= Encode::decode('utf8', $data);
    return ($data);
}

=head2
    sub from_json_ISO
=cut
sub from_json_ISO {

    eval {
        my ($data)=@_;
#         $data= UTF8toISO($data);
#         return from_json($data, {ascii => 0});
        return from_json($data, {utf8 => 1});
    }
    or do{
# FIXME falta generar un codigo de error para error de sistema
        &C4::AR::Mensajes::printErrorDB($@, 'UT001','INTRA');
        return "0";
    }
}

=head2
    sub ASCIItoHEX
=cut
sub ASCIItoHEX {
    my ($char) = @_;

    use Switch;
   
    switch ($char) {
        case "#"    { $char =  "\x".C4::AR::Utilidades::dec2hex(32)   }
        else        { $char =  $char }
    }

    return $char;
}

=head2
    sub HEXtoASCII
=cut
sub HEXtoASCII {
    my ($char) = @_;

    use Switch;
   
    switch ($char) {
        case "\x20"     { $char =  "#"   }
        else            { $char =  $char }
    }

    return $char;
}


sub dec2hex {
    # parameter passed to
    # the subfunction
    my $decnum = $_[0];
    # the final hex number
    my $hexnum;
    my $tempval;
    while ($decnum != 0) {
        # get the remainder (modulus function)
        # by dividing by 16
        $tempval = $decnum % 16;
        # convert to the appropriate letter
        # if the value is greater than 9
        if ($tempval > 9) {
            $tempval = chr($tempval + 55);
        }
        # 'concatenate' the number to
        # what we have so far in what will
        # be the final variable
        $hexnum = $tempval . $hexnum ;
        # new actually divide by 16, and
        # keep the integer value of the
        # answer
        $decnum = int($decnum / 16);
        # if we cant divide by 16, this is the
        # last step
        if ($decnum < 16) {
        # convert to letters again..
            if ($decnum > 9) {
                $decnum = chr($decnum + 55);
            }
    
            # add this onto the final answer..
            # reset decnum variable to zero so loop
            # will exit
            $hexnum = $decnum . $hexnum;
            $decnum = 0
        }
    }

    return $hexnum;
} # end sub

=item
obtenerValoresAutorizados
Obtiene todas las categorias, sin repetición de la tabla authorised_values.
=cut
sub obtenerValoresAutorizados{

    use C4::Modelo::PrefValorAutorizado;
    use C4::Modelo::PrefValorAutorizado::Manager;

    my $valAuto_array_ref;
    my @filtros;
    my $valTemp = C4::Modelo::PrefValorAutorizado->new();

    $valAuto_array_ref = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado( 
                                        select => ['category'],
                                        group_by => ['category'],
                                    ); 

    return ($valAuto_array_ref);

}

=item
obtenerDatosValorAutorizado
Obtiene todos los valores de una categoria.
=cut
sub obtenerDatosValorAutorizado{

    my ($categoria)= @_;

    use C4::Modelo::PrefValorAutorizado;
    my $valAuto_array_ref = C4::Modelo::PrefValorAutorizado::Manager->get_pref_valor_autorizado( query => [ category => { eq => $categoria} ]);
    my %autoValueHash;

    foreach my $av (@$valAuto_array_ref){
       $autoValueHash{trim($av->getAuthorisedValue)}= trim($av->getLib);
    }
    return (%autoValueHash);
}

=item
buscarCiudades
Busca las ciudades con todas la relaciones. Se usa para el autocomplete en la parte de agregar usuario.
=cut
sub buscarCiudades{

    my ($ciudad) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "   SELECT  ref_localidad.id, ref_pais.nombre AS pais, ref_provincia.nombre AS provincia, 
                            ref_dpto_partido.nombre AS partido, ref_localidad.localidad AS localidad,
                            ref_localidad.nombre AS nombre 

                    FROM ref_localidad LEFT JOIN ref_dpto_partido ON 
                                (ref_localidad.DPTO_PARTIDO = ref_dpto_partido.DPTO_PARTIDO) 
                                    LEFT JOIN ref_provincia ON 
                                        (ref_dpto_partido.provincia = ref_provincia.provincia) LEFT JOIN ref_pais ON 
                                            (ref_pais.codigo = ref_provincia.pais)

                    WHERE (ref_localidad.nombre LIKE ?) OR (ref_localidad.nombre LIKE ?)
                    ORDER BY (ref_localidad.nombre)";
    my $sth = $dbh->prepare($query);

    $sth->execute($ciudad.'%', '% '.$ciudad.'%');
    my @results;
    my $cant;

    while (my $data=$sth->fetchrow_hashref){ 
        push(@results,$data); 
        $cant++;
    }
    $sth->finish;
    return ($cant, \@results);
}


=item
buscarLenguajes
=cut
sub buscarLenguajes{

      my ($lenguaje) = @_;

      my $lenguajes = C4::Modelo::RefIdioma::Manager->get_ref_idioma(query => [ description => { like => '%'.$lenguaje.'%' } ]);

      return (scalar(@$lenguajes), $lenguajes);
}

=item
buscarSoportes
=cut
sub buscarSoportes{

      my ($soporte) = @_;

      my $soportes = C4::Modelo::RefSoporte::Manager->get_ref_soporte(query => [ description => { like => '%'.$soporte.'%' } ]);

      return (scalar(@$soportes), $soportes);
}

=item
buscarSoportes
=cut
sub buscarNivelesBibliograficos{

      my ($nivelBibliografico) = @_;

      my $nivelesBibliograficos = C4::Modelo::RefNivelBibliografico::Manager->get_ref_nivel_bibliografico(
                                                                          query => [ description => { like => '%'.$nivelBibliografico.'%' } ]
                                                                                );

      return (scalar(@$nivelesBibliograficos), $nivelesBibliograficos);
}

=head2
# Esta funcioin remueve los blancos del principio y el final del string
=cut;
sub trim{
    my ($string) = @_;

    $string =~ s/^\s+//;
    $string =~ s/\s+$//;

    return $string;
}

#FUNCION QUE VALIDA QUE UN STRING NO SEA SOLAMENTE UNA SECUENCIA DE BLANCOS (USA Trim())
sub validateString{
    my ($string) = @_;

    $string = trim($string);
    if (length($string) == 0){
        return 0; #EL STRING ERA SOLO BLANCOS, FALSE
    }
    return 1; # TODO OK, TRUE
}

#FUNCION QUE VALIDA QUE UN STRING NO SEA SOLAMENTE UNA SECUENCIA DE BLANCOS (USA Trim())
sub validateBarcode{
    my ($barcode)=@_;
# TODO recupear desde una preferencia de sistema la expresion regular que indique como es un barcode valido para la UI en particular

    return validateString($barcode);
}


#********************************************************Generacion de Combos****************************************************
sub generarComboPermisos{

    my (@label,$values);
    use C4::Modelo::PermCatalogo;
    push (@label,"Unidad De Informaci&oacute;n");
    push (@label,"Tipo de Documento");
    push (@label,"Datos Nivel 1");
    push (@label,"Datos Nivel 2");
    push (@label,"Datos Nivel 3");
    push (@label,"Estantes Virtuales");
    push (@label,"Estructura de Catalogaci&oacute;n Nivel 1");
    push (@label,"Estructura de Catalogaci&oacute;n Nivel 2");
    push (@label,"Estructura de Catalogaci&oacute;n Nivel 3");
    push (@label,"Tablas de Referencia");
    push (@label,"Control de Autoridades");

    $values = C4::Modelo::PermCatalogo->new()->meta->columns;
    
    my %labels;
    
    my %options_hash; 
    foreach my $permiso (@$values) {
        $labels{$permiso}= $permiso;
    }

    $options_hash{'values'}= $values;
    $options_hash{'labels'}=\%labels;
    $options_hash{'defaults'}= "ui";
    $options_hash{'size'}= 1;
    $options_hash{'name'}= 'permisos';
    $options_hash{'id'}= 'permisos';

    my $select = CGI::scrolling_list(\%options_hash);

    return($select);

}

sub generarComboPerfiles{
    my ($params) = @_;

    my (@label,@values);
# FIXME podria ir a tabla PERFILES, pero se vera en un futuro...
    push (@label,"SuperLibrarian");
    push (@label,"Librarian");

    my %labels;
    my %options_hash; 
    @values[0]='SL';
    @values[1]='L';
    @values[2]='E';
    @values[3]='custom';
    $labels{"SL"}= 'SuperLibrarian';
    $labels{"L"}= 'Librarian';
    $labels{"E"}= C4::AR::Filtros::i18n('Estudiante');
    $labels{"custom"}= 'Custom';

    $options_hash{'onChange'}= $params->{'onChange'} || 'profileSelection(this)';
    $options_hash{'values'}= \@values;
    $options_hash{'labels'}=\%labels;
    $options_hash{'defaults'}= 'custom';
    $options_hash{'size'}= 1;
    $options_hash{'name'}= 'perfiles';
    $options_hash{'id'}= 'perfiles';

    my $select = CGI::scrolling_list(\%options_hash);

    return($select);

}


sub generarComboDeDisponibilidad{

    my ($params) = @_;

    my @select_disponibilidades_array;
    my %select_disponibilidades_hash;
    my ($disponibilidades_array_ref)= &C4::AR::Referencias::obtenerDisponibilidades();

    foreach my $disponibilidad (@$disponibilidades_array_ref) {
        push(@select_disponibilidades_array, $disponibilidad->getCodigo);
        $select_disponibilidades_hash{$disponibilidad->getCodigo}= $disponibilidad->nombre;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}= $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}= $params->{'onFocus'};
    }
    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'disponibilidad_name';
    $options_hash{'id'}= $params->{'id'}||'disponibilidad_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultDisponibilidad");

    push (@select_disponibilidades_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_disponibilidades_array;
    $options_hash{'labels'}= \%select_disponibilidades_hash;

    my $comboDeDisponibilidades= CGI::scrolling_list(\%options_hash);

    return $comboDeDisponibilidades;
}

#GENERA EL COMBO CON LAS CATEGORIAS, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboCategoriasDeSocio{

    my ($params) = @_;
    my @select_categorias_array;
    my %select_categorias_hash;
    my ($categorias_array_ref)= &C4::AR::Referencias::obtenerCategoriaDeSocio();

    foreach my $categoria (@$categorias_array_ref) {
        push(@select_categorias_array, $categoria->getCategory_code);
        $select_categorias_hash{$categoria->getCategory_code}= $categoria->description;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}= $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}= $params->{'onFocus'};
    }
    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'categoria_socio_id';
    $options_hash{'id'}= $params->{'id'}||'categoria_socio_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultCategoriaSocio");

    push (@select_categorias_array, '');
    $select_categorias_hash{''} = "SIN SELECCIONAR";
    $options_hash{'values'}= \@select_categorias_array;
    $options_hash{'labels'}= \%select_categorias_hash;

    my $comboDeCategorias= CGI::scrolling_list(\%options_hash);

    return $comboDeCategorias;
}

#GENERA EL COMBO CON LOS DOCUMENTOS, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboTipoDeDoc{

    my ($params)=@_;

    my @select_docs_array;
    my %select_docs;
    my $docs=&C4::AR::Referencias::obtenerTiposDeDocumentos();

    foreach my $doc (@$docs) {
        push(@select_docs_array, $doc->nombre);
        $select_docs{$doc->nombre}= $doc->descripcion;
    }
    $select_docs{''}= 'SIN SELECCIONAR';

    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}= $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}= $params->{'onFocus'};
    }
    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'tipo_documento_id';
    $options_hash{'id'}= $params->{'id'}||'tipo_documento_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'class'}=  'required';
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoDoc");

    push (@select_docs_array, '');
    $options_hash{'values'}= \@select_docs_array;
    $options_hash{'labels'}= \%select_docs;

    my $combo_tipo_documento= CGI::scrolling_list(\%options_hash);

    return $combo_tipo_documento; 
}

sub generarComboTipoNivel3{

    my ($params) = @_;

    my @select_tipo_nivel3_array;
    my %select_tipo_nivel3_hash;
    my ($tipoNivel3_array_ref)= &C4::AR::Referencias::obtenerTiposNivel3();

    foreach my $tipoNivel3 (@$tipoNivel3_array_ref) {
        push(@select_tipo_nivel3_array, $tipoNivel3->id_tipo_doc);
        $select_tipo_nivel3_hash{$tipoNivel3->id_tipo_doc}= $tipoNivel3->nombre;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}= $params->{'onChange'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}= $params->{'class'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}= $params->{'onFocus'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'tipo_nivel3_name';
    $options_hash{'id'}= $params->{'id'}||'tipo_nivel3_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");

    push (@select_tipo_nivel3_array, 'ALL');
    $select_tipo_nivel3_hash{'ALL'}= 'TODOS';

    push (@select_tipo_nivel3_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_tipo_nivel3_array;
    $options_hash{'labels'}= \%select_tipo_nivel3_hash;

    my $comboTipoNivel3= CGI::scrolling_list(\%options_hash);

    return $comboTipoNivel3;
}

sub generarComboTipoPrestamo{

    my ($params) = @_;

    my @select_tipo_nivel3_array;
    my %select_tipo_prestamo_hash;

    use C4::Modelo::CircRefTipoPrestamo::Manager;
    my ($tipoPrestamo_array)= C4::Modelo::CircRefTipoPrestamo::Manager->get_circ_ref_tipo_prestamo();

    foreach my $tipoPrestamo (@$tipoPrestamo_array) {
        push(@select_tipo_nivel3_array, $tipoPrestamo->id_tipo_prestamo);
        $select_tipo_prestamo_hash{$tipoPrestamo->id_tipo_prestamo}= $tipoPrestamo->descripcion;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}= $params->{'onChange'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}= $params->{'onFocus'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}= $params->{'class'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'tipo_prestamo_name';
    $options_hash{'id'}= $params->{'id'}||'tipo_prestamo_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;

#FIXME falta un default no?
#     $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");


    push (@select_tipo_nivel3_array, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_tipo_nivel3_array;
    $options_hash{'labels'}= \%select_tipo_prestamo_hash;

    my $comboTipoNivel3= CGI::scrolling_list(\%options_hash);

    return $comboTipoNivel3;
}


sub generarComboTablasDeReferencia{

    my ($params) = @_;

    my @select_tabla_ref_array;
    my %select_tabla_ref_array;

    use C4::Modelo::PrefTablaReferencia::Manager;
    my ($tabla_ref_array)= C4::Modelo::PrefTablaReferencia::Manager->get_pref_tabla_referencia();
    

    foreach my $tabla (@$tabla_ref_array) {
        push(@select_tabla_ref_array, $tabla->getAlias_tabla);
        $select_tabla_ref_array{$tabla->getAlias_tabla}= $tabla->getAlias_tabla;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}  = $params->{'onChange'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}      = $params->{'onFocus'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}     = $params->{'class'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}       = $params->{'onBlur'};
    }

    $options_hash{'name'}           = $params->{'name'}||'tablas_ref';
    $options_hash{'id'}             = $params->{'id'}||'tablas_ref';
    $options_hash{'size'}           = $params->{'size'}||1;
    $options_hash{'multiple'}       = $params->{'multiple'}||0;
    $options_hash{'defaults'}       = $params->{'default'} || 'SIN SELECCIONAR';

#FIXME falta un default no?
#     $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");


    push (@select_tabla_ref_array, '-1');
    $select_tabla_ref_array{'-1'}   = 'SIN SELECCIONAR';
    $options_hash{'values'}         = \@select_tabla_ref_array;
    $options_hash{'labels'}         = \%select_tabla_ref_array;

    my $comboTipoNivel3             = CGI::scrolling_list(\%options_hash);

    return $comboTipoNivel3;
}


sub generarComboDePerfilesOPAC{

    my ($params) = @_;

    my @select_perfil_ref_array;
    my %select_perfil_ref_array;

    use C4::Modelo::CatPerfilOpac::Manager;
    my ($perfiles)= C4::Modelo::CatPerfilOpac::Manager->get_cat_perfil_opac();
    

    foreach my $perfil (@$perfiles) {
        push(@select_perfil_ref_array, $perfil->id);
        $select_perfil_ref_array{$perfil->id}= $perfil->getNombre;
    }

    my %options_hash; 

    $params->{'onChange'} = $params->{'onChange'} || 'eleccionDePerfil()';
    if ( $params->{'onChange'} ){
         $options_hash{'onChange'}  = $params->{'onChange'};
    }

    if ( $params->{'onFocus'} ){
      $options_hash{'onFocus'}      = $params->{'onFocus'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}     = $params->{'class'};
    }

    if ( $params->{'onBlur'} ){
      $options_hash{'onBlur'}       = $params->{'onBlur'};
    }

    $options_hash{'name'}           = $params->{'name'}||'perfiles_ref';
    $options_hash{'id'}             = $params->{'id'}||'perfiles_ref';
    $options_hash{'size'}           =  $params->{'size'}||1;
    $options_hash{'multiple'}       = $params->{'multiple'}||0;
    $options_hash{'defaults'}       = 'SIN SELECCIONAR';

#FIXME falta un default no?
#     $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultTipoNivel3");


    push (@select_perfil_ref_array, 'SIN SELECCIONAR');
    $options_hash{'values'}         = \@select_perfil_ref_array;
    $options_hash{'labels'}         = \%select_perfil_ref_array;

    my $combo_perfiles              = CGI::scrolling_list(\%options_hash);

    return $combo_perfiles;
}

#GENERA EL COMBO CON LOS BRANCHES, Y SETEA COMO DEFAULT EL PARAMETRO (QUE DEBE SER EL VALUE), SINO HAY PARAMETRO, SE TOMA LA PRIMERA
sub generarComboUI{

    my ($params) = @_;
    my @select_ui;
    my %select_ui;

    my $unidades_de_informacion= C4::AR::Referencias::obtenerUnidadesDeInformacion();

    foreach my $ui (@$unidades_de_informacion) {
        push(@select_ui, $ui->id_ui);
        $select_ui{$ui->id_ui}= $ui->nombre;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}= $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}= $params->{'onFocus'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}= $params->{'class'};
    }

    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= $params->{'name'}||'id_ui';
    $options_hash{'id'}= $params->{'id'}||'id_ui';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || C4::AR::Preferencias->getValorPreferencia("defaultUI");

    if ($params->{'optionALL'}){
        push (@select_ui, 'ALL');
        $select_ui{'ALL'}='TODOS';
    }else{
        push (@select_ui, '');
        $select_ui{''}='SIN SELECCIONAR';
    }
    $options_hash{'values'}= \@select_ui;
    $options_hash{'labels'}= \%select_ui;

    my $CGIunidadDeInformacion= CGI::scrolling_list(\%options_hash);

    return $CGIunidadDeInformacion; 
}


sub generarComboDeSocios{

    my ($params) = @_;
    my @select_socios;
    my %select_socios;
    my $socios  = C4::Modelo::UsrSocio::Manager->get_usr_socio( query => [ 
                                                                          activo => {eq => 1},
                                                                       ],);

    foreach my $socio (@$socios) {
        push(@select_socios, $socio->getNro_socio);
        $select_socios{$socio->getNro_socio}= $socio->persona->getApeYNom." (".$socio->getNro_socio.")" ;
    }

    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}   = $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}    = $params->{'onFocus'};
    }

    if ( $params->{'class'} ){
         $options_hash{'class'}     = $params->{'class'};
    }

    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}     = $params->{'onBlur'};
    }

    $options_hash{'name'}           = $params->{'name'}||'ui_name';
    $options_hash{'id'}             = $params->{'id'}||'socios';
    $options_hash{'size'}           =  $params->{'size'}||1;
    $options_hash{'multiple'}       = $params->{'multiple'}||0;
    $options_hash{'defaults'}       = $params->{'default'} || '-1';

#     push (@select_socios, 'SIN SELECCIONAR');
    push (@select_socios, '-1');
    $select_socios{'-1'}            ='SIN SELECCIONAR';
    $options_hash{'values'}         = \@select_socios;
    $options_hash{'labels'}         = \%select_socios;

    my $CGIsocios                   = CGI::scrolling_list(\%options_hash);

    return $CGIsocios; 
}


sub generarComboCampoX{

    my $onReadyFunction = shift;
    my $defaultCampoX = shift;
    #Filtro de numero de campo
    my %camposX;
    my @values;

    push (@values, -1);
    $camposX{-1}="Elegir";
    my $option;

    for (my $i =0 ; $i <= 9; $i++){
        push (@values, $i);
        $option= $i."xx";
        $camposX{$i}=$option;
    }
    my $defaulCX= $defaultCampoX || 'Elegir';

    my $selectCampoX=CGI::scrolling_list(  -name      => 'campoX',
                    -id    => 'campoX',
                    -values    => \@values,
                    -labels    => \%camposX,
                    -defaults  => $defaulCX,
                    -size      => 1,
                    -onChange  => $onReadyFunction,
    );

    return ($selectCampoX);
}

sub generarComboTipoDeOperacion{

    my ($params) = @_;

    use C4::Modelo::RefTipoOperacion::Manager;
    my @select_tipoOperacion_Values;
    my %select_tipoOperacion_Labels;
    my $result = C4::Modelo::RefTipoOperacion::Manager->get_ref_tipo_operacion();

    foreach my $tipoOperacion (@$result) {
        if ( $params->{'clone_values'} ){
        #si el label y el ID son iguales
            push (@select_tipoOperacion_Values, $tipoOperacion->descripcion);
            $select_tipoOperacion_Labels{$tipoOperacion->descripcion} = $tipoOperacion->descripcion;
        }else{
            push (@select_tipoOperacion_Values, $tipoOperacion->id);
            $select_tipoOperacion_Labels{$tipoOperacion->id} = $tipoOperacion->descripcion;
        }
    }

    my $CGISelectTipoOperacion=CGI::scrolling_list(    -name      => 'tipoOperacion',
                                                        -id        => 'tipoOperacion',
                                                        -values    => \@select_tipoOperacion_Values,
                                                        -labels    => \%select_tipoOperacion_Labels,
                                                        -size      => 1,
                                                        -defaults  => 'SIN SELECCIONAR'
                                                    );

    return $CGISelectTipoOperacion;
}

sub generarComboNiveles{

    my ($params) = @_;
    my @nivel;
    my $cantNivel=3;

#     push(@nivel, "Niveles");
    for (my $i=1; $i<=$cantNivel; $i++){
        push(@nivel, $i);
    }
    my @select_niveles;
    my %select_niveles;

    foreach my $nivel (@nivel) {
        push(@select_niveles, $nivel);
        $select_niveles{$nivel}= $nivel;
    }
    my %options_hash; 

    if ( $params->{'onChange'} ){
        $options_hash{'onChange'}= $params->{'onChange'};
    }
    if ( $params->{'onFocus'} ){
        $options_hash{'onFocus'}= $params->{'onFocus'};
    }
    if ( $params->{'class'} ){
         $options_hash{'class'}= $params->{'class'};
    }
    if ( $params->{'onBlur'} ){
        $options_hash{'onBlur'}= $params->{'onBlur'};
    }

    $options_hash{'name'}= 'niveles_name';
    $options_hash{'id'}= 'niveles_id';
    $options_hash{'size'}=  $params->{'size'}||1;
    $options_hash{'multiple'}= $params->{'multiple'}||0;
    $options_hash{'defaults'}= $params->{'default'} || 'SIN SELECCIONAR';

    push (@select_niveles, 'SIN SELECCIONAR');
    $options_hash{'values'}= \@select_niveles;
    $options_hash{'labels'}= \%select_niveles;

    my $CGINiveles= CGI::scrolling_list(\%options_hash);

    return $CGINiveles; 
}

#****************************************************Fin****Generacion de Combos**************************************************
sub getToday{

    my @datearr = localtime(time);
    my $today =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
    my $dateformat = C4::Date::get_date_format();

    return (format_date($today,$dateformat));
}

sub printARRAY{

    my ($array_ref) = @_;

    C4::AR::Debug::debug("PRINT ARRAY: \n");

    if($array_ref){
        foreach my  $value (@$array_ref) {
                C4::AR::Debug::debug("value: $value\n");
            }
    }
}


sub printHASH{

    my ($hash_ref) = @_;

    C4::AR::Debug::debug("PRINT HASH: \n");

    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
                C4::AR::Debug::debug("key: $key => value: $value\n");
            }
    }
}

sub initHASH{

    my ($hash_ref) = @_;
    my @keys = keys(%$hash_ref);

    foreach my $key (@keys) {
        C4::AR::Debug::debug("key ".$key.": has the value ".$hash_ref->{$key}."\n");
        $hash_ref->{$key}= undef;
    }

    $hash_ref= \{};
}

sub joinArrayOfString{

    my (@columns) = @_;
    my ($fieldsString) = "";

    foreach my $campo (@columns){
        $fieldsString.= $campo." ";
    }

    return ($fieldsString);
}

=item
Esta funcion convierte el arreglo de objetos (Rose::DB) a JSON
=cut
sub arrayObjectsToJSONString{

    my ($objects_array) = @_;
    my @objects_array_JSON;

    use utf8;

    for(my $i=0; $i<scalar(@$objects_array); $i++ ){
        push (@objects_array_JSON, $objects_array->[$i]->as_json);
    }

    my $infoJSON= '[' . join(',' ,@objects_array_JSON) . ']';

    utf8::decode($infoJSON);

    return $infoJSON;
}

=item
Esta funcion convierte el arreglo de valores a JSON {campo->campo}
=cut
sub arrayToJSONString{

    my ($array) = @_;
    my @array_JSON;

    for(my $i=0; $i<scalar(@$array); $i++ ){
        push (@array_JSON,"{'campo':'".$array->[$i]->{'campo'}."'}");
    }

    my $infoJSON= '[' . join(',' ,@array_JSON) . ']';

    return $infoJSON;
}

=item
Esta funcion convierte el arreglo de los pares clave/valor a JSON {clave->clave,valor->valor}
=cut
sub arrayClaveValorToJSONString{

    my ($array) = @_;
    my @array_JSON;

    for(my $i=0; $i<scalar(@$array); $i++ ){
        push (@array_JSON,"{'clave':'".$array->[$i]->{'clave'}."',valor':'".$array->[$i]->{'valor'}."'}");
    }

    my $infoJSON= '[' . join(',' ,@array_JSON) . ']';

    return $infoJSON;
}


=head2
sub existeInArray
 
   Esta funcion busca en el arreglo el string, ambos pasados por parametro y devuelve 1 o 0
=cut
sub existeInArray{
    my ($string,@array) = @_;

    if (grep {$_ eq $string} @array) {
#         C4::AR::Debug::debug("Utilidades => existeInArray => EXISTE => ".$string." en el arreglo");
        return 1;
    }
    
#         C4::AR::Debug::debug("Utilidades => existeInArray => NO EXISTE => ".$string." en el arreglo");
    return 0;
}

=item
Esta funcion verifica si el user_agent es un browser
=cut
sub isBrowser{

    my $browser= $ENV{'HTTP_USER_AGENT'};
    my $ok=1;

    if ( $browser =~ s/Mozilla// ) {
        if ($browser =~ s/(MSIE)//){
            # print Z "IE \n";	
        }
        if($browser =~ s/(Chrome)//){
            # print Z "Chrome \n";
        }

        if($browser =~ s/(Iceweasel)//){
            # print Z "Iceweasel \n";
        }
    }elsif( $browser =~ s/(Opera)//) {
        # print Z "Opera \n";	
    }else{
        # print Z "otro \n";
        $ok= 0;
    }
    return $ok;
}

=item
Esta funcion "corta" un arreglo desde ini hasta fin
se la utiliza cuando se realiza una consulta a la base, se recupera la info y deben procesarse todos los resultados si o si
o sea cuando no se puede limitar con MYSQL
=cut
sub paginarArreglo{

    #La variable $ini, no es el numero de pagina, sino es la posicion ya calculada (la que devuelve InitPaginador)
    my ($ini,$fin,@array) = @_;
    C4::AR::Debug::debug(" Utilidades::paginarArreglo => INI: ".$ini." FIN: ".$fin);
    C4::AR::Debug::debug(" Utilidades::paginarArreglo => CANT ARRAY antes de paginar: ".scalar(@array));

    my $cant_total = scalar(@array);
    my $division_temp  = floor ($cant_total / $fin);
    my $resto = $cant_total - ($division_temp * $fin);
    my $numPagina = ceil($ini / $fin) + 1;

    if ( ($numPagina > $division_temp) ){
        @array = @array[$ini..($ini + $resto-1)];
        C4::AR::Debug::debug(" Utilidades::paginarArreglo => CANT ARRAY if: ".scalar(@array));
    }else{
        @array = @array[$ini..($ini + $fin-1)];
        C4::AR::Debug::debug(" Utilidades::paginarArreglo => CANT ARRAY else: ".scalar(@array));
    }

    C4::AR::Debug::debug(" Utilidades::paginarArreglo => CANT ARRAY despues de paginar: ".scalar(@array));

    return ($cant_total,@array);
}

=item
Esta funcion recibe un string separado por 1 o mas blancos, y devuelve un arreglo de las palabras que se ingresaron
para realizar la busqueda
=cut
sub obtenerBusquedas{

    my ($searchstring) = @_;
    my @search_array;
    my @busqueda= split(/ /,$searchstring); #splitea por blancos, retorna un arreglo de substring, puede estar
    my $pal;

    foreach my  $b (@busqueda){
        $pal= trim($b);
        if( length($pal) > 0 ){
#             C4::AR::Debug::debug('agrego: '.$pal);
            push(@search_array, $pal);
        }
    }

    return (@search_array);
}

=item
obtenerCoincidenciasDeBusqueda
=cut
sub obtenerCoincidenciasDeBusqueda{

    my ($string, $search_array) = @_;
    my $cant= 0;
    my $cont= 0;

    $string= lc $string;
    foreach my $search (@$search_array){
        $cant= 0;
        $search= lc $search;
        while ($string =~ /$search/g) { 
            $cant++;
        }
        $cont += $cant;
    }

    return $cont;
}


#CAPITALIZAR UN STRING (primer letra en mayuscula, el resto en minuscula

sub capitalizarString{

    my ($string) = @_;

    $string = ucfirst(lc trim($string));

    return ($string);
}
=item
Esta funcion ordena una HASH de strings
orden: es el orden por el que se va a ordenar la HASH
DESC: 1 si es descendente, 0 = ascendente
info: la informacion de la HASH a ordenar
devuelve un arreglo de HASHES listo para enviar al template
=cut
sub sortHASHString{

    my ($params) = @_;
    my $desc= $params->{'DESC'};
    my $orden= $params->{'orden'};
    my $info= $params->{'info'};
    my @keys=keys %$info;

    if($desc){
    #ordena la HASH de strings de manera DESC
        @keys= sort{$info->{$a}->{$orden} cmp $info->{$b}->{$orden}} @keys;
    }else{
    #ordena la HASH de strings de manera ASC
        @keys= sort{$info->{$b}->{$orden} cmp $info->{$a}->{$orden}} @keys;
    }
    my @resultsarray;

    foreach my $row (@keys){
        push (@resultsarray, $info->{$row});
    }

    return @resultsarray;
}

=item
Esta funcion ordena una HASH de numericos
orden: es el orden por el que se va a ordenar la HASH
DESC: 1 si es descendente, 0 = ascendente
info: la informacion de la HASH a ordenar
devuelve un arreglo de HASHES listo para enviar al template
=cut
sub sortHASHNumber{

    my ($params) = @_;
    my $desc= $params->{'DESC'};
    my $orden= $params->{'orden'};
    my $info= $params->{'info'};
    my @keys=keys %$info;

    if($desc){
    #ordena la HASH de strings de manera DESC
        @keys= sort{$info->{$b}->{$orden} <=> $info->{$a}->{$orden}} @keys;
    }else{
    #ordena la HASH de strings de manera ASC
        @keys= sort{$info->{$a}->{$orden} <=> $info->{$b}->{$orden}} @keys;
    }
    my @resultsarray;

    foreach my $row (@keys){
        push (@resultsarray, $info->{$row});
    }

    return @resultsarray;
}

sub stringToArray{

    my ($string);

    return( split(/\b/,$string) );
}

############################## Funciones para AUTOCOMPLETABLES #############################################################

sub autorAutocomplete{

    my ($autorStr) = @_;
    my $textout;
    my $autores_array_ref= C4::AR::Referencias::obtenerAutoresLike($autorStr);

    foreach my $autor (@$autores_array_ref){
        $textout.= $autor->getId."|".$autor->getCompleto."\n";
    }
    
#     return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
    return ($textout eq '')?"-1|".$autorStr:$textout;
}

sub obtenerDescripcionDeSubCampos{

    my ($campo)= @_;
    my ($sub_campos_marc_array_ref) = &C4::AR::Referencias::obtenerSubCamposDeCampo($campo);
    my $textout;

    foreach my $sub_campo_marc (@$sub_campos_marc_array_ref) {
        $textout .= $sub_campo_marc->getSubcampo."/".$sub_campo_marc->getSubcampo." - ".$sub_campo_marc->getLiblibrarian."#";
    }

    return $textout;
}

sub ayudaCampoMARCAutocomplete{
    my ($campo) = @_;

    my $campos_marc_array_ref= &C4::AR::Referencias::obtenerCamposLike($campo); 
    my $textout;

    foreach my $campo_marc (@$campos_marc_array_ref){
        $textout.= $campo_marc->getCampo."| (".$campo_marc->getCampo.") ".$campo_marc->getLiblibrarian."\n";
    }
    
    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub uiAutocomplete{
    my ($uiStr) = @_;

    my $textout;
    my $autores_array_ref= C4::AR::Referencias::obtenerUILike($uiStr);

    foreach my $ui (@$autores_array_ref){
        $textout.= $ui->getId_ui."|".$ui->getNombre."\n";
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}


sub bibliosAutocomplete{

    my ($biblioStr) = @_;
    my $textout="";
    my @result=C4::AR::UtilidadesobtenerBiblios($biblioStr);

    foreach my $biblio (@result){
        $textout.=$biblio->{'branchname'}."|".$biblio->{'id'}."\n";
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub autocompleteTemas{

    my ($tema) = @_;
    my $i=0;
    my ($cant, $temas_array_ref)= &C4::AR::ControlAutoridades::search_temas($tema);
    my $resultado="";

    foreach my $tema (@$temas_array_ref){
        $resultado .=  $tema->getId."|". $tema->getNombre. "\n";
    }

        return ($resultado eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$resultado;
}


=head2
    sub autoresAutocomplete

=cut
sub autoresAutocomplete{
    my ($autor) = @_;

    my ($cant, $autores_array_ref) = &C4::AR::ControlAutoridades::search_autores($autor);
    my $resultado = "";
   
    foreach my $autor (@$autores_array_ref){
        $resultado .=  $autor->getId."|". $autor->getCompleto. "\n";
    }

#     return ($resultado eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$resultado;
    return ($resultado eq '')?"-1|".$autor:$resultado;
}

sub autocompleteEditoriales{

    my ($editorial) = @_;
    my $resultado="";
    my ($cant, $editoriales_array_ref)= &C4::AR::ControlAutoridades::search_editoriales($editorial);
    my $resultado="";

    foreach my $editorial (@$editoriales_array_ref){
                      $resultado .=  $editorial->getId."|". $editorial->getEditorial. "\n";

    }

    return ($resultado eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$resultado;

}

sub autocompleteAyudaMarc{

    my ($editorial) = @_;
    my ($cant, @results)= &C4::AR::ControlAutoridades::search_editoriales($editorial);
    my $i=0;
    my $resultado="";
    my $field;
    my $data;

    for ($i; $i<$cant; $i++){
        $field=$results[$i]->{'campo'};
        $data=$results[$i]->{'liblibrarian'};
        $resultado .= $field."|".$data. "\n";
    }

    return ($resultado eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$resultado;

}

sub lenguajesAutocomplete{

    my ($lenguaje) = @_;
    my $textout;
    my @result;

    if ($lenguaje){
        my($cant, $result) = C4::AR::Utilidades::buscarLenguajes($lenguaje);# agregado sacar
        $textout= "";
        for (my $i; $i<$cant; $i++){
            $textout.= $result->[$i]->{'idLanguage'}."|".$result->[$i]->{'description'}."\n";
        }
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;

#    my ($cant, $lenguajes_array_ref)= C4::AR::Utilidades::buscarLenguaje($lenguaje);
#    my $resultado="";

#    foreach my $lenguaje (@$lenguajes_array_ref){
#        $resultado .=  $lenguaje->getId."|". $lenguaje->getDescription. "\n";
#    }

#    return ($resultado eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$resultado;

}

sub nivelBibliograficoAutocomplete{

    my ($nivelBibliografico) = @_;
    my $textout;
    my @result;

    if ($nivelBibliografico){
        my($cant, $result) = C4::AR::Utilidades::buscarNivelesBibliograficos($nivelBibliografico);
        $textout= "";
        for (my $i; $i<$cant; $i++){
            $textout.= $result->[$i]->{'code'}."|".$result->[$i]->{'description'}."\n";
        }
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub paisesAutocomplete{

    my ($paisesStr)= @_;;
    my $textout="";
    my ($cant, $paises_array_ref)=C4::AR::Utilidades::obtenerPaises($paisesStr);

    foreach my $pais (@$paises_array_ref){
        $textout.=$pais->getIso."|".$pais->getNombre_largo."\n";
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub ciudadesAutocomplete{

    my ($ciudad)= @_;
    my $textout;
    my @result;
    if ($ciudad){
        my($cant, $result) = C4::AR::Utilidades::buscarCiudades($ciudad);# agregado sacar
        $textout= "";
        for (my $i; $i<$cant; $i++){
            $textout.= $result->[$i]->{'id'}."|".$result->[$i]->{'nombre'}."\n";
        }
    }


    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub soportesAutocomplete{

    my ($soporte) = @_;
    my $textout;
    my @result;

    if ($soporte){
        my($cant, $result) = C4::AR::Utilidades::buscarSoportes($soporte);# agregado sacar
        $textout= "";
        for (my $i; $i<$cant; $i++){
            $textout.= $result->[$i]->{'idSupport'}."|".$result->[$i]->{'description'}."\n";
        }
    }
    
    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub temasAutocomplete{

    my ($temaStr,$campos,$separador) = @_;
    my $textout="";
    my @result=C4::AR::Utilidades::obtenerTemas2($temaStr);
    my @arrayCampos=split(",",$campos);
    my $texto="";

    foreach my $tema (@result){
        foreach my $valor(@arrayCampos){
            if($texto eq ""){
                $texto.=$tema->{$valor};
            }
            else{
                $texto.=$separador.$tema->{$valor};
            }
        }
        $textout.=$texto."|".$tema->{'id'}."\n";
        $texto="";
    }
    
    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub usuarioAutocomplete{

    my ($usuarioStr)= @_;
    my $textout="";
    my ($cant, $usuarios_array_ref)= C4::AR::Usuarios::getSocioLike($usuarioStr);

    if ($cant > 0){
        foreach my $usuario (@$usuarios_array_ref){
            $textout.= $usuario->getNro_socio."|".$usuario->persona->getApeYNom." (".$usuario->getNro_socio.")\n";
        }
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

=item
busca barcodeStr sobre todos los barcodes
=cut
sub barcodeAutocomplete{

    my ($barcodeStr)= @_;
    my $textout="";
    my ($cant, $cat_nivel3_array_ref)= C4::AR::Nivel3::getBarcodesLike($barcodeStr);

    if ($cant > 0){
        foreach my $nivel3 (@$cat_nivel3_array_ref){
            $textout.= $nivel3->getBarcode."|".$nivel3->getBarcode."\n";
        }
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}

sub barcodePrestadoAutocomplete{

    my ($barcodeStr)= @_;
    my $textout="";
    #busco el barcode en el conj. de los barcodes prestados
    my ($cant, $circ_prestamo_array_ref)= C4::AR::Nivel3::getBarcodesPrestadoLike($barcodeStr);
    #devuelve un arreglo de objetos prestamos con cat_nivel3

    if ($cant > 0){
        foreach my $prestamo (@$circ_prestamo_array_ref){
            #se muestra el barcode, pero en el hidden queda el usuario al que se le realizo el prestamo
            $textout.= $prestamo->getId_prestamo."|".$prestamo->nivel3->getBarcode."\n";
        }
    }

    return ($textout eq '')?"-1|".C4::AR::Filtros::i18n("SIN RESULTADOS"):$textout;
}
############################## Fin funciones para AUTOCOMPLETABLES #############################################################


#######################################FUNCIONES PARA TRABAJAR CON BINARIOS##########################################
sub bin2dec {
    return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub dec2bin {
    my $str = unpack("B32", pack("N", shift));
    $str =~ s/^0+(?=\d)//;   # otherwise you'll get leading zeros
    return $str;
}
####################################FIN###FUNCIONES PARA TRABAJAR CON BINARIOS#######################################

=item sub isAjaxRequest

    verifica si el request fue realizado con AJAX
    Parametros:

=cut
sub isAjaxRequest {
    if($ENV{'HTTP_X_REQUESTED_WITH'} eq 'XMLHttpRequest'){
        return 1;
    }else { return 0}
}

=item sub md5ToSHA_B64_256

    Esta funcion se utiliza para actualizar las passwords de los socios de MD5 a SHA256_base64
=cut
sub md5ToSHA_B64_256 {
       
    my $socios_array_ref = C4::Modelo::UsrSocio::Manager->get_usr_socio( );

    foreach my $socio (@$socios_array_ref){
        if($socio->getPassword() ne undef){
            $socio->setPassword(sha256_base64($socio->getPassword()));
        }
        $socio->save();
    }
}


sub crearPaginadorOPAC{

    my ($cantResult, $cantRenglones, $pagActual, $url, $t_params)=@_;

    my ($paginador, $cantPaginas)=C4::AR::Utilidades::armarPaginasOPAC($pagActual, $cantResult, $cantRenglones,$url,$t_params);
    return $paginador;

}
sub armarPaginasOPAC{
#@actual, es la pagina seleccionada por el usuario
#@cantRegistros, cant de registros que se van a paginar
#@$cantRenglones, cantidad de renglones maximo a mostrar
#@$t_params, para obtener el path para las imagenes

# FIXME falta pasar las imagenes al estilo
    my ($actual, $cantRegistros, $cantRenglones, $url, $t_params)=@_;
    my $pagAMostrar=C4::AR::Preferencias->getValorPreferencia("paginas") || 10;
    my $numBloq=floor($actual / $pagAMostrar);
    my $limInf=($numBloq * $pagAMostrar);
    my $limSup=$limInf + $pagAMostrar;
    my $previous_text = "« ".C4::AR::Filtros::i18n('Anterior');
    my $next_text = C4::AR::Filtros::i18n('Siguiente')." »";
    if($limInf == 0){
        $limInf= 1;
        $limSup=$limInf + $pagAMostrar -1;
    }
    my $totalPaginas = ceil($cantRegistros/$cantRenglones);

    my $themelang= $t_params->{'themelang'};

    my $paginador= "<div class='pagination'><div id='content_paginator' align='center' >";
    my $class="paginador";

    if($actual > 1){
        #a la primer pagina
        my $ant= $actual-1;
        $paginador .= "<a href='".$url."&page=".$ant."' class='previous' title='".$previous_text."'> ".$previous_text."</a>";

    }else{
        $paginador .= "<span class='disabled' title='".$previous_text."'>".$previous_text."</span>";
    }

    for (my $i=$limInf; ($totalPaginas >1 and $i <= $totalPaginas and $i <= $limSup) ; $i++ ) {
        if($actual == $i){
            $class="'current'";
            $paginador .= "<span class=".$class."> ".$i." </span>";
        }else{
            $class="'pagination'";
            $paginador .= "<a href='".$url."&page=".$i."' class=".$class."> ".$i." </a>";
        }
    }

    if($actual >= 1 && ($actual < $totalPaginas)){
        my $sig= $actual+1;
        $paginador .= "<a href='".$url."&page=".$sig."' class='next' title='".$next_text."'>".$next_text."</a>";

    }
    $paginador .= "</div></div>"; 

    if ($totalPaginas <= 1){
      $paginador="";
    }
    return($paginador, $totalPaginas);
}

sub getDate{

    my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings) = localtime();
    my %date_hash = {};

    $date_hash{'year'} = 1900 + $yearOffset;
    $date_hash{'month'} = $month;

    return (\%date_hash);
}


sub getFeriados{
    use C4::Modelo::PrefFeriado;
    use C4::Modelo::PrefFeriado::Manager;

    my $feriados = C4::Modelo::PrefFeriado::Manager->get_pref_feriado(sort_by => ['fecha DESC']);
    my @dates;

    foreach my $date (@$feriados){
        push (@dates, $date);
    }

    return (\@dates);
}

sub setFeriado{

    my ($fecha,$status,$texto_feriado) = @_;

    use C4::Modelo::PrefFeriado;
    use C4::Modelo::PrefFeriado::Manager;
    my $dateformat      = C4::Date::get_date_format();
    $fecha              = C4::Date::format_date_in_iso($fecha, $dateformat);

    my $feriado = C4::Modelo::PrefFeriado::Manager->get_pref_feriado(query => [ fecha => { eq => $fecha } ] );
    
    if (scalar(@$feriado)){
        $feriado->[0]->setFecha($fecha,$status,$texto_feriado);
    }else{
        $feriado = C4::Modelo::PrefFeriado->new();
        eval{
            $feriado->agregar($fecha,$status,$texto_feriado);
        };
    }
    return (1);
}



sub redirectAndAdvice{

    my ($cod_msg)= @_;
    my ($session) = CGI::Session->load();

    $session->param('codMsg',$cod_msg);
#     $session->param('redirectTo', '/cgi-bin/koha/informacion.pl');
    C4::Auth::redirectTo('/cgi-bin/koha/informacion.pl');
#     exit;
}

END { }       # module clean-up code here (global destructor)

1;
__END__
