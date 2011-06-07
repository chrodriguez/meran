#!/usr/bin/perl
#
#Para configurar los campos involucrados en los reportes genericos
#Escrito el 28/9/2007 por matiasp@info.unlp.edu.ar
#
#Copyright (C) 2003-2007  Linti, Facultad de Inform�tica, UNLP
#This file is part of Koha-UNLP
#
#This program is free software; you can redistribute it and/or0
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
use C4::Output;

use C4::AR::Auth;
use CGI;
use C4::Context;
use C4::AR::Generic_Report;
use HTML::Template;

my $query=new CGI;
my $input = $query;
my $op = $query->param('op');

my $nbstatements = $query->param('nbstatements');
my @statements = ();

#Se recupera el estado
my @fieldlist = $query->param('fieldlist');
my @and_or = $query->param('and_or');
my @excluding = $query->param('excluding');
my @operator = $query->param('operator');
my @value = $query->param('value');

my ($template, $nro_socio, $cookie);

if ($op eq "do_search") { #HACER LA BUSQUEDA

        my $startfrom=$query->param('startfrom');
                ($startfrom) || ($startfrom=0);
        
        my ($template, $session, $t_params) = get_template_and_user({
                                    template_name => "reports/generic_result.tmpl",
                                    query => $input,
                                    type => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'undefined'},
                                    debug => 1,
                            });

        my ($results,$campos,$count,$filename) = reportSearch(\@fieldlist,\@value, \@operator, \@excluding , \@and_or , $startfrom , $nro_socio );
        
        my @campos=split(/,/,$campos);
        my $fields='';
        
        foreach my $field (@campos){
            $fields.="<td align='left'><b>".$field."</b></td>";
        }
        
        my @RES=();
        
        my $class='impar';
        
        for(my $i = 0 ; $i <= $#{$results} ; $i++)
        { 
            my $row='';
            my $res;
            my $j=0;
            foreach my $field (@campos){
            $row.="<td class='".$class."'>".@$results->[$i][$j]."</td>";
            $j++;
            }
            $res->{'result'}=$row;
            push (@RES,$res);
            if($class eq 'impar'){$class='par';}else{$class='impar';} #Intercambiar el estilo
        }
        
        
        $t_params->{'campos'}=$fields;
        $t_params->{'result'}=\@RES;
        $t_params->{'total'}=$count;
        $t_params->{'filename'}=$filename;
            
        ####PAGINADOR#####
        #
        my $num=C4::AR::Preferencias::getValorPreferencia("renglones");
        
        $t_params->{'startfrom'}= $startfrom+1;
        ($startfrom+$num<=$count) ? ($t_params->{'endat'}=( $startfrom+$num)) : ($t_params->{'endat'}= $count);
        $t_params->{'numrecords'}= $count;
        my $nextstartfrom=($startfrom+$num<$count) ? ($startfrom+$num) : (-1);
        my $prevstartfrom=($startfrom-$num>=0) ? ($startfrom-$num): (-1);
        $t_params->{'nextstartfrom'}= $nextstartfrom;
        my $displaynext=1;
        my $displayprev=0;
        ($nextstartfrom==-1) ? ($displaynext=0) : ($displaynext=1);
        ($prevstartfrom==-1) ? ($displayprev=0) : ($displayprev=1);
        $t_params->{'displaynext'}= $displaynext;
        $t_params->{'displayprev'}= $displayprev;
        $t_params->{'prevstartfrom'}= $prevstartfrom;
        
        my @numbers = ();
        if ($count>$num) {
        for (my $i=0; $i<(($count/$num)); $i++) {
                my $highlight=0;
                ($startfrom==(($i)*($num))) && ($highlight=1);
                my $break=0;
                if ((($i+1) % 40) eq 0){$break=1;}
                push @numbers, { number => $i+1, highlight => $highlight, startfrom => (($i)*($num)), break => $break };
                }
                }
        $t_params->{'numbers'}= \@numbers;
        
        
        #
        ##################
        
        #Para poder volver a hacer la busqueda
        #Armo los hashes
        my @loop;
        for(my $i = 0 ; $i <= scalar(@fieldlist) ; $i++){
        if(@value[$i]){
        my $tmp;
        $tmp->{'fieldlist'}=@fieldlist[$i];
        $tmp->{'value'}=@value[$i];
        $tmp->{'operator'}=@operator[$i];
        $tmp->{'excluding'}=@excluding[$i];
        $tmp->{'and_or'}=@and_or[$i];
        push (@loop,$tmp);
        }
        }
        $t_params->{'LOOP'}=\@loop;
        #
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
} else {
           my $fieldarray = C4::AR::Generic_Report::getFieldsArray();
           my ($template, $session, $t_params) = get_template_and_user({
                                template_name => "reports/generic_reports.tmpl",
                                query => $input,
                                type => "intranet",
                                authnotrequired => 0,
                                flagsrequired => {  ui => 'ANY', 
                                                    tipo_documento => 'ANY', 
                                                    accion => 'CONSULTA', 
                                                    entorno => 'undefined'},
                                debug => 1,
                           });
	 my %labels;
	 my @values;
     
     	for(my $i = 0 ; $i <= $#{$fieldarray} ; $i++)
	  {
	  push @values, @$fieldarray[$i]->{'value'};
	  if(@$fieldarray[$i]->{'label'} ne ''){
	      $labels{@$fieldarray[$i]->{'value'}} = @$fieldarray[$i]->{'label'};
		    }else{
	     $labels{@$fieldarray[$i]->{'value'}} = @$fieldarray[$i]->{'value'};
			}
		       }

           my $fieldlist = CGI::scrolling_list(-name=>"fieldlist",
	   				      -values => \@values,
			   		      -labels => \%labels,
					      -size=>1,											                                   -multiple=>0,
					      -onChange => "sql_update()"
					      );



        if ($op eq "AddStatement") {
        #Agregar una linea
        
                $nbstatements = 1 if(!defined $nbstatements);
        
                for(my $i = 0 ; $i < $nbstatements ; $i++)
                {
                        my %fields = ();
        
                        my $fieldlist = CGI::scrolling_list(-name=>"fieldlist",
                                                -values => \@values,
                                                -labels => \%labels,
                                                -size=> 1,
                                                -multiple=>0,
                                                -default=>$fieldlist[$i],
                                                -onChange => "sql_update()"
                                                );
        
                        $fields{'fieldlist'} = $fieldlist;
                        $fields{'first'} = 1 if($i == 0);
        
                        # Restores the and/or parameters (no need to test the 'and' for activation because it's the default value)
                        $fields{'or'} = 1 if($and_or[$i] eq "or");
        
                        #Restores the "not" parameters
                        $fields{'not'} = 1 if($excluding[$i]);
        
                        #Restores the operators (most common operators first);
                        if($operator[$i] eq "=") { $fields{'eq'} = 1; }
                        elsif($operator[$i] eq "contains") { $fields{'contains'} = 1; }
                        elsif($operator[$i] eq "start") { $fields{'start'} = 1; }
                        elsif($operator[$i] eq ">") { $fields{'gt'} = 1; }	#greater than
                        elsif($operator[$i] eq ">=") { $fields{'ge'} = 1; } #greater or equal
                        elsif($operator[$i] eq "<") { $fields{'lt'} = 1; } #lower than
                        elsif($operator[$i] eq "<=") { $fields{'le'} = 1; } #lower or equal
        
                        #Restores the value
                        $fields{'value'} = $value[$i];
        
                        push @statements, \%fields;
                }
                $nbstatements++;
        
                # La Nueva Linea
                my $fieldlist = CGI::scrolling_list(-name=>"marclist",
                                        -values => \@values,
                                        -labels => \%labels,
                                        -size=>1,
                                        -multiple=>0,
                                        -onChange => "sql_update()");
        
                push @statements, {"fieldlist" => $fieldlist };
        
                $t_params->{'statements'}= \@statements;
                $t_params->{'nbstatements'}= $nbstatements;
        
        }
        else {
                #POR DEFECTO 
        
                my $fieldlist = CGI::scrolling_list(-name=>"fieldlist",
                                                -values => \@values,
                                                -labels => \%labels,
                                                -size=>1,
                                                -multiple=>0,
                                                -onChange => "sql_update()",
                                                );
        
        
                # 3 Lineas por defecto
                push @statements, { "fieldlist" => $fieldlist, "first" => 1 };
                push @statements, { "fieldlist" => $fieldlist, "first" => 0 };
                push @statements, { "fieldlist" => $fieldlist, "first" => 0 };
        
                $t_params->{'statements'}= \@statements, "nbstatements" => 3;
        }
        C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}



