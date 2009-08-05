#!/usr/bin/perl

use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Sanciones;
use C4::AR::Prestamos;
use JSON;

my $input = new CGI;
my $obj=$input->param('obj');
$obj=C4::AR::Utilidades::from_json_ISO($obj);

my $accion = $obj->{'tipoAccion'};
my $authnotrequired= 0;


if($accion eq "TIPOS_PRESTAMOS_SANCIONADOS"){
		my ($template, $session, $t_params)  = get_template_and_user({
								template_name => "admin/sanciones_tipo_de_prestamos.tmpl",
								query => $input,
								type => "intranet",
								authnotrequired => 0,
								flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
								debug => 1,
					});
	
		my $tipo_prestamo=$obj->{'tipo_prestamo'};
		my $categoria_socio=$obj->{'categoria_socio'};
		my $tipo_sancion=&C4::AR::Sanciones::getTipoSancion($tipo_prestamo, $categoria_socio);
		$t_params->{'tipo_sancion'}= $tipo_sancion;

		my $tipo_prestamos=&C4::AR::Prestamos::getTiposDePrestamos();
		$t_params->{'TIPOS_PRESTAMOS'}= $tipo_prestamos;

		C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
}#end if($accion eq "TIPOS_PRESTAMOS_SANCIONADOS")

if ($accion eq "GUARDAR_TIPOS_PRESTAMOS_QUE_APLICA") {

	my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

	my $tipos_que_aplica=$obj->{'tipos_que_aplica'};
C4::AR::Debug::debug("tipossss : ".$tipos_que_aplica->[0]);
	my $tipo_prestamo=$obj->{'tipo_prestamo'};
	my $categoria_socio=$obj->{'categoria_socio'};

    my $Message_arrayref = &C4::AR::Sanciones::actualizarTiposPrestamoQueAplica($tipo_prestamo,$categoria_socio,$tipos_que_aplica);
    my $infoOperacionJSON=to_json $Message_arrayref;
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

if($accion eq "REGLAS_SANCIONES"){
        my ($template, $session, $t_params)  = get_template_and_user({
                                template_name => "admin/sanciones_reglas.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                                debug => 1,
                    });
    
        my $tipo_prestamo=$obj->{'tipo_prestamo'};
        my $categoria_socio=$obj->{'categoria_socio'};

        my $tipo_sancion=&C4::AR::Sanciones::getTipoSancion($tipo_prestamo, $categoria_socio);
        $t_params->{'tipo_sancion'}= $tipo_sancion;

        my $reglas_tipo_sancion=&C4::AR::Sanciones::getReglasTipoSancion($tipo_sancion);
        $t_params->{'REGLAS_TIPOS_SANCIONES'}= $reglas_tipo_sancion;

        ######################Combos de las reglas de sancion##################################
        my $reglas_sancion=&C4::AR::Sanciones::getReglasSancion();
        if ($reglas_sancion) {
        my %regla_sancionlabels;
        my @regla_sancionvalues;
        foreach my $regla (@$reglas_sancion) {
            push @regla_sancionvalues, $regla->getRegla_sancion;
            $regla_sancionlabels{$regla->getRegla_sancion} = "Dias de demora: ".$regla->getDias_demora.". Dias de sancion: ".$regla->getDias_sancion;
        }
        my $CGIregla_sancion=CGI::scrolling_list(
                                -name => 'regla_sancion',
                                -id => 'regla_sancion',
                                -values   => \@regla_sancionvalues,
                                -labels   => \%regla_sancionlabels,
                                -size     => 1,
                                -multiple => 0 );

        $t_params->{'reglas_de_sancion'}= $CGIregla_sancion;
        }
        ######################Combos Orden##################################
        my %orden;
        my @orden;
        for (my $i=1; $i < 21; $i++) {
                push @orden, $i;
                $orden{$i} = $i;
        }
        my $sugestedOrder= 0; #Maximo +1
        foreach my $mi_regla (@$reglas_tipo_sancion) { 
            if($mi_regla->getOrden > $sugestedOrder){
                $sugestedOrder=$mi_regla->getOrden;
            } 
        }
        $sugestedOrder++;

        my $CGIorden=CGI::scrolling_list(
                                -name => 'orden',
                                -id => 'orden',
                                -values   => \@orden,
                                -labels   => \%orden,
                                -default => $sugestedOrder,
                                -size     => 1,
                                -multiple => 0 );

        $t_params->{'ordenes'}= $CGIorden;

        ######################Combos Cantidades##################################
        my %cantidad;
        my @cantidad;
        push @cantidad, 0;
        $cantidad{0} = "Infinito";
        for (my $i=1; $i < 21; $i++) {
                push @cantidad, $i;
                $cantidad{$i} = $i;
        }

        my $CGIcantidad=CGI::scrolling_list(
                                -name => 'cantidad', 
                                -id => 'cantidad',
                                -values   => \@cantidad,
                                -labels   => \%cantidad,
                                -default => 1,
                                -size     => 1,
                                -multiple => 0 );

        $t_params->{'cantidades'}= $CGIcantidad;


        C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);
        }#end if($accion eq "REGLAS_SANCIONES")


if ($accion eq "ELIMINAR_REGLA_TIPO_SANCION") {

    my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

    my $tipo_sancion=$obj->{'tipo_sancion'};
    my $regla_sancion=$obj->{'regla_sancion'};

    my $Message_arrayref = &C4::AR::Sanciones::eliminarReglaTipoSancion($tipo_sancion,$regla_sancion);
    my $infoOperacionJSON=to_json $Message_arrayref;
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}

if ($accion eq "AGREGAR_REGLA_TIPO_SANCION") {

    my ($userid, $session, $flags) = checkauth( $input, 
                                            $authnotrequired,
                                            {   ui => 'ANY', 
                                                tipo_documento => 'ANY', 
                                                accion => 'BAJA', 
                                                entorno => 'undefined'},
                                            "intranet"
                                );

    my $tipos_que_aplica=$obj->{'tipos_que_aplica'};
C4::AR::Debug::debug("tipossss : ".$tipos_que_aplica->[0]);
    my $tipo_prestamo=$obj->{'tipo_prestamo'};
    my $categoria_socio=$obj->{'categoria_socio'};

    my $Message_arrayref = &C4::AR::Sanciones::actualizarTiposPrestamoQueAplica($tipo_prestamo,$categoria_socio,$tipos_que_aplica);
    my $infoOperacionJSON=to_json $Message_arrayref;
    C4::Output::printHeader($session);
    print $infoOperacionJSON;
}
# 
# my $input = new CGI;
# my $issue= $input->param('circ_ref_tipo_prestamo') || undef;
# my $category= $input->param('usr_ref_categoria_socio') || undef;
# my @issuestypes= $input->param('issuestypes');
# 
# #FIXME salvar los valores enviados y ver que se hizo clic en Guardar
# #open L,">/tmp/lucho";
# #my $v;
# #foreach $v (@issuestypes) { 
# #	printf L  "$v\n";
# #}
# 
# sub in_array() {
# 	my $val = shift @_ || return 0;
# 	my @array = @_;
# 	foreach (@array)
# 		{ return 1 if ($val eq $_); }
# 	return 0;
# }
# 
# my $sugestedOrder= 1;
# my $tipo_sancion= undef;
# my $dbh = C4::Context->dbh;
# 
# my $action= $input->param('accion') || undef;
# if ($action eq 'delete') {
# 	my $tipo_sancion1= $input->param('tipo_sancion');
# 	my $regla_sancion= $input->param('regla_sancion');
# 	my $sth = $dbh->prepare("delete from circ_regla_tipo_sancion where tipo_sancion = ? and regla_sancion = ?");
# 	$sth->execute($tipo_sancion1, $regla_sancion);
# } elsif ($action eq 'add') {
# 	my $order= $input->param('orden');
# 	my $amount= $input->param('cantidad');
# 	my $tipo_sancion1= $input->param('tipo_sancion');
# 	my $regla_sancion= $input->param('regla_sancion');
# 	my $sth = $dbh->prepare("insert into circ_regla_tipo_sancion (tipo_sancion,regla_sancion,orden,amount) values (?,?,?,?)");
# 	$sth->execute($tipo_sancion1, $regla_sancion, $order, $amount);
# }
# 
# my ($template, $session, $params) = get_template_and_user({
# 									template_name => "admin/sanctions.tmpl",
# 									query => $input,
# 									type => "intranet",
# 									authnotrequired => 0,
# 									flagsrequired => { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
# 									debug => 1,
# 			    });
# 
# my $sth = $dbh->prepare("select * from circ_ref_tipo_prestamo order by descripcion");
# $sth->execute();
# my %issueslabels;
# my @issuesvalues;
# while (my $res = $sth->fetchrow_hashref) {
# 	$issue= $res->{'tipo_prestamo'} unless $issue;
# 	push @issuesvalues, $res->{'tipo_prestamo'};
# 	$issueslabels{$res->{'tipo_prestamo'}} = $res->{'descripcion'};
# }
# $sth->finish;
# 
# 
# # FIXME esta lista se puede armar con lo que se hizo???????
# 
# my $CGIcirc_ref_tipo_prestamo=CGI::scrolling_list( 
# 			-name => 'circ_ref_tipo_prestamo',
#                         -values   => \@issuesvalues,
#                         -labels   => \%issueslabels,
# 			-default => $issue,
# 			-onChange => "submit();",
#                         -size     => 1,
#                         -multiple => 0 );
# 
# my $sth = $dbh->prepare("select * from usr_ref_categoria_socio order by description");
# $sth->execute();
# my %usr_ref_categoria_sociolabels;
# my @usr_ref_categoria_sociovalues;
# while (my $res = $sth->fetchrow_hashref) {
# 	$category= $res->{'categoria_socio'} unless $category;
#         push @usr_ref_categoria_sociovalues, $res->{'categoria_socio'};
#         $usr_ref_categoria_sociolabels{$res->{'categoria_socio'}} = $res->{'descripcion'};
# }
# $sth->finish;
# 
# # FIXME esta lista se puede armar con lo que se hizo???????
# my $CGIusr_ref_categoria_socio=C4::AR::Utilidades::generarComboCategoriasDeSocio();
# 
# 
# my $sth = $dbh->prepare("select *,circ_ref_tipo_prestamo.descripcion as descissuetype, usr_ref_categoria_socio.description as desccategory from circ_tipo_sancion inner join circ_regla_tipo_sancion on circ_tipo_sancion.tipo_sancion = circ_regla_tipo_sancion.tipo_sancion inner join circ_regla_sancion on circ_regla_tipo_sancion.regla_sancion = circ_regla_sancion.regla_sancion inner join circ_ref_tipo_prestamo on circ_tipo_sancion.tipo_prestamo = circ_ref_tipo_prestamo.id_tipo_prestamo inner join usr_ref_categoria_socio on usr_ref_categoria_socio.categorycode = circ_tipo_sancion.categoria_socio where circ_tipo_sancion.tipo_prestamo = ? and circ_tipo_sancion.categoria_socio = ? order by circ_regla_tipo_sancion.orden");
# $sth->execute($issue, $category);
# my @sanctionsarray;
# while (my $res = $sth->fetchrow_hashref) {
# 	$tipo_sancion= $res->{'tipo_sancion'} unless $tipo_sancion;
# 	($res->{'amount'} eq '0')?$res->{'amount'}='Infinito':undef;
#         push (@sanctionsarray, $res);
# }
# $sth->finish;
# 
# unless ($tipo_sancion) {
# 	my $sth = $dbh->prepare("select * from circ_tipo_sancion where tipo_prestamo = ? and categoria_socio = ?");
# 	$sth->execute($issue, $category);
# 	my $res;
# 	if ($res= $sth->fetchrow_hashref) {
# 		$tipo_sancion= $res->{'tipo_sancion'};
# 	} else {
# 		my $sth = $dbh->prepare("insert into circ_tipo_sancion (tipo_prestamo,categoria_socio) values (?,?)");
# 		$sth->execute($issue, $category);
# 		my $sth = $dbh->prepare("select * from circ_tipo_sancion where tipo_prestamo = ? and categoria_socio = ?");
# 		$sth->execute($issue, $category);
# 		$res= $sth->fetchrow_hashref;
# 		$tipo_sancion= $res->{'tipo_sancion'};
# 	}
# }
# 
# if ($action eq 'issuestypes') {
# 	my $sth = $dbh->prepare("delete from circ_tipo_prestamo_sancion where tipo_sancion = ?");
# 	$sth->execute($tipo_sancion);
# 	my $i;
# 	foreach $i (@issuestypes) { 
# 		my $sth = $dbh->prepare("insert into circ_tipo_prestamo_sancion (tipo_sancion,tipo_prestamo) values (?,?)");
# 		$sth->execute($tipo_sancion,$i);
# 	}
# }
# 
# 
# my $sth = $dbh->prepare("select * from circ_regla_sancion order by dias_demora, dias_sancion");
# $sth->execute();
# my %regla_sancionlabels;
# my @regla_sancionvalues;
# while (my $res = $sth->fetchrow_hashref) {
# 	push @regla_sancionvalues, $res->{'regla_sancion'};
# 	$regla_sancionlabels{$res->{'regla_sancion'}} = "Dias de demora: ".$res->{'dias_demora'}.". Dias de sancion: ".$res->{'dias_sancion'};
# }
# $sth->finish;
# 
# # FIXME esta???
# my $CGIregla_sancion=CGI::scrolling_list(
#                         -name => 'regla_sancion',
#                         -values   => \@regla_sancionvalues,
#                         -labels   => \%regla_sancionlabels,
#                         -size     => 1,
#                         -multiple => 0 );
# 
# if ($tipo_sancion) {
# 	my $sth= $dbh->prepare("select max(circ_regla_tipo_sancion.orden) from circ_regla_tipo_sancion where tipo_sancion = ?");
# 	$sth->execute($tipo_sancion);
# 	my $data= $sth->fetchrow_array;
# 	$sugestedOrder=  $data + 1;
# }
# 
# my %orden;
# my @orden;
# for (my $i=1; $i < 21; $i++) {
#         push @orden, $i;
#         $orden{$i} = $i;
# }
# $sth->finish;
# 
# 
# # FIXME esta???
# my $CGIorden=CGI::scrolling_list(
#                         -name => 'orden',
#                         -values   => \@orden,
#                         -labels   => \%orden,
# 			-default => $sugestedOrder,
#                         -size     => 1,
#                         -multiple => 0 );
# 
# my %cantidad;
# my @cantidad;
# push @cantidad, 0;
# $cantidad{0} = "Infinito";
# for (my $i=1; $i < 21; $i++) {
#         push @cantidad, $i;
#         $cantidad{$i} = $i;
# }
# $sth->finish;
# 
# 
# # FIXME esta???
# my $CGIcantidad=CGI::scrolling_list(
#                         -name => 'cantidad',
#                         -values   => \@cantidad,
#                         -labels   => \%cantidad,
#                         -default => 1,
#                         -size     => 1,
#                         -multiple => 0 );
# 
# 
# my $sth= $dbh->prepare("SELECT * FROM circ_tipo_prestamo_sancion where tipo_sancion = ?");
# $sth->execute($tipo_sancion);
# my @issuescodes;
# while (my $res = $sth->fetchrow_hashref) {
#         push @issuescodes, $res->{'tipo_prestamo'};
# }
# 
# my $sth= $dbh->prepare("SELECT * FROM circ_ref_tipo_prestamo ORDER BY descripcion");
# $sth->execute();
# my @issues;
# while (my $res = $sth->fetchrow_hashref) {
# 	$res->{'checked'}= &in_array($res->{'tipo_prestamo'}, @issuescodes);
#         push @issues, $res;
# }
# $sth->finish;
# 
# $params->{'issues'}= \@issues;
# $params->{'cantidad'}= $CGIcantidad;
# $params->{'orden'}= $CGIorden;
# $params->{'tipo_sancion'}= $tipo_sancion;
# $params->{'loop_sanctions_types'}= \@sanctionsarray;
# $params->{'sanctions_regla_sancion'}= $CGIregla_sancion;
# $params->{'issues_types'}= $CGIcirc_ref_tipo_prestamo;
# $params->{'usr_ref_categoria_socio'}= $CGIusr_ref_categoria_socio;
# 
# C4::Auth::output_html_with_http_headers($input, $template, $params);
