#!/usr/bin/perl


use strict;
use CGI;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::AR::Busquedas;
use C4::AR::Catalogacion;

=item
armarCondicion
Arma la condicion para la busqueda. Si la condicion es un like agrega el % dependiende de la condicion y concatena el valor; si es cualquiera otra condicion solo concatena el valor a esa condicion.
Tambien verifica que el valor de busqueda se valido.
=cut
sub armarCondicion{
	my ($cond,$valor)=@_;
	$valor=&C4::AR::Utilidades::verificarValor($valor);
	if($cond eq "Empieza"){
		$cond=" like '".$valor."%' ";
	}
	elsif($cond eq "Contiene"){
		$cond=" like '%".$valor."%' ";
	}
	elsif($cond eq "Finaliza"){
		$cond=" like '%".$valor."' ";
	}
	else{
		$cond=$cond."'".$valor."'";
	}
	return $cond;
}

=item
Primero busca los autores que cumple con la condicion con la que se quiere realizar la busqueda. Despues construye un string con todos los id de los autores que cumple esa condicion para poder realizar la busqueda sobre la tabla nivel1
=cut
sub armarCondicionAutor{
	my ($cond,$valor)=@_;
	$cond=armarCondicion($cond,$valor);
	my @autores=&buscarAutorPorCond($cond);
	my $str="";
	foreach my $aut (@autores){
		$str.= "OR autor = ".$aut->{'id'}." ";
	}
	$str=substr($str,2,length($str));
	return "(".$str.")";
}

=item
parsearString
Esta funcion parsea los string que viene desde el tmpl armando asi el string para hacer las consultas y verificado que el dato sea correcto previniendo el sql injection.
=cut
sub parsearString{
	my ($str,$rep)=@_;
	my @arrayCampos;
	my @arrayVal;
	my $string="";
	my $valor;
	my $cond;
	if($str ne ""){
		my @arrayCampos=split(/#/,$str);
		foreach my $cons (@arrayCampos){
			@arrayVal=split(/\//,$cons);
			if($rep){
				$cond=armarCondicion($arrayVal[2],$arrayVal[3]);
				$string.="(".$rep.".campo=".$arrayVal[0]." AND ".$rep.".subcampo='".$arrayVal[1]."' AND ".$rep.".dato".$cond.")#";
			}
			else{
				if($arrayVal[0] eq "autor"){
					$string.=armarCondicionAutor($arrayVal[1],$arrayVal[2])."#";
				}
				else{
					$cond=armarCondicion($arrayVal[1],$arrayVal[2]);
					$string.=$arrayVal[0].$cond."#";
				}
				
			}
		}
	}
	return $string;
}

my $input = new CGI;
my $obj=C4::AR::Utilidades::from_json_ISO($input->param('obj'));
my $accion= $obj->{'accion'};

if($accion eq "buscar"){
                my ($template, $session, $t_params) = get_template_and_user ({
                                template_name	=> 'busquedas/busquedaResult.tmpl',
                                query		=> $input,
                                type		=> "intranet",
                                authnotrequired	=> 0,
                                flagsrequired	=> { ui => 'ANY', tipo_documento => 'ANY', accion => 'CONSULTA', entorno => 'undefined'},
                        });
        
                my $nivel1=parsearString($obj->{'nivel1'},0);
                my $nivel2=parsearString($obj->{'nivel2'},0);
                my $nivel3=parsearString($obj->{'nivel3'},0);
                my $nivel1rep=parsearString($obj->{'nivel1rep'},"n1r");
                my $nivel2rep=parsearString($obj->{'nivel2rep'},"n2r");
                my $nivel3rep=parsearString($obj->{'nivel3rep'},"n3r");
                my $operador=$obj->{'operador'};
        
                my $ini=$obj->{'ini'};
                my $orden=$obj->{'orden'}||'titulo';
                my $funcion=$obj->{'funcion'};
                my ($ini,$pageNumber,$cantR)=C4::AR::Utilidades::InitPaginador($ini);
        
                my ($cantidad,$resultId1)= C4::AR::Busquedas::busquedaAvanzada($nivel1, $nivel2, $nivel3, $nivel1rep, $nivel2rep, $nivel3rep,$operador,$ini,$cantR);
        
                C4::AR::Utilidades::crearPaginador($cantidad,$cantR, $pageNumber,$funcion,$t_params);
        
        my @resultsarray;
        my %result;
        my $nivel1;
        my $autor;
        my $id1;
        for (my $i=0;$i<scalar(@$resultId1);$i++){
                $id1=$resultId1->[$i];
                $result{$i}->{'id1'}= $id1;
                $nivel1= &buscarNivel1($id1);
                $result{$i}->{'titulo'}= $nivel1->{'titulo'};
                $autor= getautor($nivel1->{'autor'});
                $result{$i}->{'idAutor'}=$autor->{'id'};
                $result{$i}->{'nomCompleto'}= $autor->{'completo'};
                my $ediciones=obtenerGrupos($id1, 'ALL','INTRA');
                $result{$i}->{'grupos'}=$ediciones;
                my @disponibilidad=&obtenerDisponibilidadTotal($id1, 'ALL');
                $result{$i}->{'disponibilidad'}=\@disponibilidad;
        }
        
        
        my @keys=keys %result;
        @keys= sort{$result{$a}->{$orden} cmp $result{$b}->{$orden}} @keys; #PARA EL ORDEN
        foreach my $row (@keys){
                push (@resultsarray, $result{$row});
        }
        
        $t_params->{'SEARCH_RESULTS'}= \@resultsarray;
        
        
        C4::Auth::output_html_with_http_headers($input, $template, $t_params, $session);

}else{
	my ($userid, $session, $flags) = checkauth($input, 0,{ catalogue => 1});
	
	my $string="";

	if($accion eq "seleccionCampoX"){
		my $campoX= $obj->{'campoX'};
		my @campos=&C4::AR::Busquedas::buscarCamposMARC($campoX);
		for(my $i=0; $i < scalar(@campos); $i++){
			$string .= $campos[$i]."#";
		}
	}
	elsif($accion eq "seleccionCampo"){
		my $campo= $obj->{'campo'};
		my @subcampos=&C4::AR::Busquedas::buscarSubCamposMARC($campo);
		for(my $i=0; $i < scalar(@subcampos); $i++){
			$string .= $subcampos[$i]."#";
		}
	}
	else{#accion = busquedaReferencia
		my $campo= $obj->{'campo'};
		my $tipo='combo';
		my @valuesMapeo;
		my %labelsMapeo;
		my $labels="";
		my $value;
		if($campo eq "nivel_bibliografico"){
			%labelsMapeo=C4::AR::Busquedas::getLevels();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "lenguaje"){
			%labelsMapeo=C4::AR::Busquedas::getLanguages();
			my @keys= keys %labelsMapeo;
			@keys= sort{$labelsMapeo{$a} cmp $labelsMapeo{$b}} @keys;
			foreach my $key (@keys){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "pais_publicacion"){
			%labelsMapeo=C4::AR::Busquedas::getCountryTypes();
			my @keys= keys %labelsMapeo;
			@keys= sort{$labelsMapeo{$a} cmp $labelsMapeo{$b}} @keys;
			foreach my $key (@keys){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "wthdrawn"){
			%labelsMapeo=C4::AR::Busquedas::getAvails();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "holdingbranch" || $campo eq "homebranch" ){
			$labels=C4::AR::Busquedas::getBranches();
			foreach my $key (keys %$labels){
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=$labels->{$key}->{'branchname'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "tipo_documento"){
			my($i,@labels)=C4::AR::Busquedas::getItemTypes();
			my $key;
			foreach my $itemtype (@labels){
				$key=$itemtype->{'itemtype'};
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=$itemtype->{'description'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "notforloan"){
			my @labels=&C4::AR::Prestamos::IssuesType();
			my $key;
			foreach my $issuetype (@labels){
				$key=$issuetype->{'issuecode'};
				push(@valuesMapeo,$key);
				$labelsMapeo{$key}=$issuetype->{'description'};
			}
			$labels=\%labelsMapeo;
		}
		elsif($campo eq "soporte"){
			%labelsMapeo=&C4::AR::Busquedas::getSupportTypes();
			foreach my $key (keys %labelsMapeo){
				push(@valuesMapeo,$key);
			}
			$labels=\%labelsMapeo;
		}
		else{
			$tipo='text';
		}
		$string= &C4::AR::Utilidades::crearComponentes( $tipo,'valor1',\@valuesMapeo,$labels,'');
	}
    C4::Output::printHeader($session);
	print $string;
}