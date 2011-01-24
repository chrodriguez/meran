package C4::AR::StatGraphs;

#
#Este modulo sera el encargado del manejo de estadisticas sobre los prestamos
#,reservas, devoluciones y todo tipo de consulta sobre el uso de la biblioteca
#
#

use strict;
require Exporter;
use C4::Date;
use Chart::Pie;
use Chart::HorizontalBars;
use Chart::LinesPoints;
use C4::AR::open_flash_chart;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		itemtypesPieSinFlash
		itemtypesHBarsSinFlash
		levelsPieSinFlash
		levelsHBarsSinFlash
		userCategPieSinFlash
		userCategHBarsSinFlash
		itemtypesPie
		itemtypesHBars
		levelsPie
		levelsHBars
		availLines
		userCategPie
		userCategHBars
	);


sub itemtypesPieSinFlash
{
 my ($branch,$cant,@results)=@_;

my $g = Chart::Pie->new(640,480);

my @descriptions;
my @values;
    for (my $i=0; $i < $cant ; $i++ ) {
                 push (@descriptions,$results[$i]->{'description'});
     		 push (@values,$results[$i]->{'cant'});
        };


$g->add_dataset (@descriptions);
$g->add_dataset (@values);

my %opt = ( 'title' =>'Tipos de documentos (Torta)',
'label_values' => 'both',
'legend' => 'none',
'text_space' => 20,
'png_border' => 1,
'graph_border' => 0,
'colors' => { 'x_label' => 'red',
'misc' => 'plum',
'background' => 'white'
}
);
$g->set (%opt);
my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
my $template=C4::AR::Preferencias->getValorPreferencia('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/itemtypepie$branch.png");
}

sub itemtypesHBarsSinFlash
{
my ($branch,$cant,@results)=@_;

my $g = Chart::HorizontalBars->new(640,480);

my @descriptions;
my @values;
    for (my $i=0; $i < $cant ; $i++ ) {
                 push (@descriptions,$results[$i]->{'description'});
                 push (@values,$results[$i]->{'cant'});
        };


$g->add_dataset (@descriptions);
$g->add_dataset (@values);

my %hash = ( 'title' => 'Tipos de documentos (Barras Horizontales)',
'grid_lines' => 'true',
'label_values' => 'both',
'text_space' => 10,
'png_border' => 1,
'graph_border' => 0,
'x_label' => 'Cantidad',
'y_label' => 'Tipos',
'include_zero' => 'true',
'x_ticks' => 'vertical',
'legend_labels' => ['Cantidad'],
'colors' => {
'misc' => 'plum',
'background' => 'white'
}

);

$g->set (%hash);

my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
my $template=C4::AR::Preferencias->getValorPreferencia('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/itemtypehbars$branch.png");
}



sub levelsPieSinFlash
{
 my ($branch,$cant,@results)=@_;

my $g = Chart::Pie->new(640,480);

my @descriptions;
my @values;
    for (my $i=0; $i < $cant ; $i++ ) {
                 push (@descriptions,$results[$i]->{'description'});
     		 push (@values,$results[$i]->{'cant'});
        };


$g->add_dataset (@descriptions);
$g->add_dataset (@values);

my %opt = ( 'title' =>'Nivel bibliografico (Torta)',
'label_values' => 'both',
'legend' => 'none',
'text_space' => 20,
'png_border' => 1,
'graph_border' => 0,
'colors' => { 'x_label' => 'red',
'misc' => 'plum',
'background' => 'white'
}
);
$g->set (%opt);

my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
my $template=C4::AR::Preferencias->getValorPreferencia('template');
$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/levelpie$branch.png");
}

sub levelsHBarsSinFlash
{
my ($branch,$cant,@results)=@_;

my $g = Chart::HorizontalBars->new(640,480);

my @descriptions;
my @values;
    for (my $i=0; $i < $cant ; $i++ ) {
                 push (@descriptions,$results[$i]->{'description'});
                 push (@values,$results[$i]->{'cant'});
        };


$g->add_dataset (@descriptions);
$g->add_dataset (@values);

my %hash = ( 'title' => 'Nivel bibliografico (Barras Horizontales)',
'grid_lines' => 'true',
'label_values' => 'both',
'text_space' => 10,
'png_border' => 1,
'graph_border' => 0,
'x_label' => 'Cantidad',
'y_label' => 'Niveles',
'include_zero' => 'true',
'x_ticks' => 'vertical',
'legend_labels' => ['Cantidad'],
'colors' => {
'misc' => 'plum',
'background' => 'white'
}

);

$g->set (%hash);
my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
my $template=C4::AR::Preferencias->getValorPreferencia('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/levelhbars$branch.png");
}

=item
sub getlabels
 { 
   my (@results)=@_;
   my @labels;
   my $p=0;	
   my $fyear;
   my $fmonth;
   my $lyear;
   my $lmonth;	
   my $cant=@results;

 if ($cant >= 1){$fyear  = $results[0]->{'year'};
		 $fmonth = $results[0]->{'mes'};
		if($cant>1){$lyear  = $results[$cant-1]->{'year'};
                 	    $lmonth = $results[$cant-1]->{'mes'};} 
		}

if ($fyear eq $lyear){  
	for(my $i=$fmonth;$i<=$lmonth;$i++) 
		{ 	my $aux;$aux=$i.'/'.$fyear;
			$labels[$p]=$aux;$p++;
			}  
	 }
	else {
	for(my $i=$fyear;$i<=$lyear;$i++)
    	{my $ini;
	 my $fin;
	 if ($i eq $fyear){$ini=$fmonth;$fin=12;}
		elsif($i eq $lyear){$ini=1;$fin=$lmonth;}
			else{$ini=1;$fin=12;}
	 for(my $j=$ini;$j<=$fin;$j++)
			{my $aux=$j.'/'.$i;
			$labels[$p]=$aux;$p++;
			}
	
		}
	  }

return ($p,@labels);
 }

sub availLines 
{
my ($branch,$cant,$ini,$fin,@results)=@_;
my $i=0;
my $year='';
my $month=''; 

my $g = Chart::LinesPoints->new(640,480);
my ($cantlabels,@labels)=getlabels(@results);

open L, ">>/tmp/mono";

my ($cantavails,@avails) =availArray();
my @data;

for (my $i=0;$i<$cantavails;$i++)
	{my $dataset;
	 my $avail='Perdido';
	for (my $j=0;$j<$cantlabels;$j++ ){ 
		my @dat;
	for (my $h=0;$h<@results;$h++){

 if((($results[$h]->{'mes'}.'/'.$results[$h]->{'year'}) eq ($labels[$j]))&&($results[$h]->{'avail'} eq $avail))
	{push (@dat, $results[$h]->{'cantidad'});} else {push (@dat,0);}
	printf L "%20s  \n",  $results[$h]->{'cantidad'};
	}
	$data[$i] =@dat;
		}


}
close L;
$g->add_dataset(@labels);
#for (my $i=0;$i<$cantlabels;$i++){$g->add_dataset($data[$i])}
$g->add_dataset($data[0]);

my %hash =(
'integer_ticks_only' => 'true',
'title' => '',
'legend_labels' => @avails,
'y_label' => 'position in the table',
'x_label' => 'day of play',
'grid_lines' => 'true'
);

$g->set ( %hash);
my $lang=C4::Context->preference('opaclanguages');
my $template=C4::Context->preference('template');
$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/avail$branch.png");
}
=cut

sub userCategPieSinFlash(){
	my ($branch,$cant,@results)=@_;
	my $g = Chart::Pie->new(700,500);

	my @categorias;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
                 push (@categorias,$results[$i]->{'categoria'});
     		 push (@values,$results[$i]->{'reales'});
        };

	$g->add_dataset (@categorias);
	$g->add_dataset (@values);

	my %opt = ( 'title' =>'Usuarios por categoria (Torta)',
		'label_values' => 'both',
		'legend' => 'none',
		'text_space' => 20,
		'png_border' => 1,
		'graph_border' => 0,
		'colors' => { 	'x_label' => 'red',
				'misc' => 'plum',
				'background' => 'white'
			},
		);
	$g->set (%opt);
	my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
	my $template=C4::AR::Preferencias->getValorPreferencia('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/usercategpie$branch.png");

}

sub userCategHBarsSinFlash(){
	my ($branch,$cant,@results)=@_;
	my $g = Chart::HorizontalBars->new(640,480);

	my @categorias;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
        	push (@categorias,$results[$i]->{'categoria'});
                push (@values,$results[$i]->{'cant'});
        };


	$g->add_dataset (@categorias);
	$g->add_dataset (@values);

	my %hash = ( 'title' => 'Usuarios por categoria (Barras Horizontales)',
		'grid_lines' => 'true',
		'label_values' => 'both',
		'text_space' => 10,
		'png_border' => 1,
		'graph_border' => 0,
		'x_label' => 'Cantidad',
		'y_label' => 'Tipos',
		'include_zero' => 'true',
		'x_ticks' => 'vertical',
		'legend_labels' => ['Cantidad'],
		'colors' => {
			'misc' => 'plum',
			'background' => 'white'
		}
		);

	$g->set (%hash);

	my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
	my $template=C4::AR::Preferencias->getValorPreferencia('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/usercateghbars$branch.png");
}


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!NUEVOS GRAFICOS CON FLASH!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#***********************Funciones genericas internas para crear los graficos*************************
sub inicializarGrafico(){
	my ($titulo)=@_;
	my $g = graph->new();
	$g->set_width(640);
	$g->set_height(480);
	$g->title( $titulo,'{font-size: 20px; color: #FF8040}' );
	return $g;
}

sub finalizarGrafico(){
	my ($g)=@_;
	my $lang=C4::AR::Preferencias->getValorPreferencia('opaclanguages');
	my $template=C4::AR::Preferencias->getValorPreferencia('template');
	$g->set_swf_path("/intranet-tmpl/$template/$lang/includes/open-flash-chart/");
	$g->set_js_path("/intranet-tmpl/$template/$lang/includes/open-flash-chart/");
	$g->set_output_type("js");
}
#***********************************FIN***************************

sub userCategHBars(){
	my ($branch,$cant,@results)=@_;
	my $g=&inicializarGrafico("Usuarios reales por categoria (Barras)");

	my @categorias;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
        	push(@categorias,C4::AR::Utilidades::noaccents($results[$i]->{'categoria'}));
                push(@values,$results[$i]->{'reales'});
        };
#para generar las barras.
	$g->bar_3D( 50, '0x0066CC', 'cantidad',10 );
	$g->set_data(\@values );
	$g->set_x_labels(\@categorias);
	$g->set_x_axis_3d(10);
	$g->set_y_min( 0 );
	$g->set_x_legend( 'Categorias de usuarios', 10, '#736AFF' );
	$g->set_y_legend( 'Cantidades', 10, '#736AFF' );
	&finalizarGrafico($g);
	return ($g->render());
}

sub userCategPie(){
	my ($branch,$cant,@results)=@_;
	my $g=&inicializarGrafico("Usuarios reales por categoria (Torta)");
	my @categorias;
	my @values;
	my @colores;
	my $num;
	my $cantUsr;
	my $porcUsr;
	my $varios="";
	my $totalUsr=0;
	my $totalVar=0;
	for (my $i=0; $i < $cant ; $i++ ) {
		$totalUsr+=$results[$i]->{'reales'};
	}
    	for (my $i=0; $i < $cant ; $i++ ) {
		$cantUsr=$results[$i]->{'reales'};
		#Para quedar acorde al pm (Si la cantidad es menor a 3% los suma en una misma porcion de la torta)
		$porcUsr=sprintf("%.1f", ($cantUsr/ $totalUsr) * 100.0);
		if($porcUsr >= 3){
			push(@categorias,C4::AR::Utilidades::noaccents($results[$i]->{'categoria'}));
     			push(@values,$cantUsr);
		}
		else{
			$totalVar+=$cantUsr;
		}
		$num=int(rand(499999))+500000;
		push(@colores,"#".$num);
        };
	if($totalVar > 0){
		push(@categorias,"Otros");
     		push(@values,$totalVar);
		
	}
#para generar la torta
	$g->pie(50,'0x0066CC','{font-size: 12px; color: #404040;');
	$g->pie_values(\@values,\@categorias);
	$g->pie_slice_colours(\@colores);
	$g->set_tool_tip("#val#%");

	&finalizarGrafico($g);
	return ($g->render());
}

sub itemtypesHBars(){
	my ($branch,$cant,@results)=@_;
	my $g = &inicializarGrafico("Tipo de documentos (Barras)");

	my @tiposDoc;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
        	push(@tiposDoc,C4::AR::Utilidades::noaccents($results[$i]->{'description'}));
                push(@values,$results[$i]->{'cant'});
        };
#para generar las barras.
	$g->bar_3D( 50, '0x0066CC', 'cantidad',10 );
	$g->set_data(\@values );
	$g->set_x_labels(\@tiposDoc);
	$g->set_x_axis_3d(10);
	$g->set_y_min( 0 );
	$g->set_x_legend( 'Tipo de documentos', 10, '#736AFF' );
	$g->set_y_legend( 'Cantidades', 10, '#736AFF' );

	&finalizarGrafico($g);
	return ($g->render());
}

sub itemtypesPie(){
	my ($branch,$cant,@results)=@_;
	my $g=&inicializarGrafico("Tipo de documentos (Torta)");

	my @tiposDoc;
	my @values;
	my @colores;
	my $num;
	my $cantItems;
	my $porcItems;
	my $varios="";
	my $totalItmes=0;
	my $totalVar=0;
	for (my $i=0; $i < $cant ; $i++ ) {
		$totalItmes+=$results[$i]->{'cant'};
	}
    	for (my $i=0; $i < $cant ; $i++ ) {
		$cantItems=$results[$i]->{'cant'};
		#Para quedar acorde al pm (Si la cantidad es menor a 3% los suma en una misma porcion de la torta)
		$porcItems=sprintf("%.1f", ($cantItems/ $totalItmes) * 100.0);
		if($porcItems >= 3){
			push(@tiposDoc,C4::AR::Utilidades::noaccents($results[$i]->{'description'}));
     			push(@values,$cantItems);
		}
		else{
			$totalVar+=$cantItems;
		}
		$num=int(rand(499999))+500000;
		push(@colores,"#".$num);
        };
	if($totalVar > 0){
		push(@tiposDoc,"Otros");
     		push(@values,$totalVar);
		
	}
#para generar la torta
	$g->pie(50,'0x0066CC','{font-size: 12px; color: #404040;');
	$g->pie_values(\@values,\@tiposDoc);
	$g->pie_slice_colours(\@colores);
	$g->set_tool_tip("#val#%");

	&finalizarGrafico($g);
	return ($g->render());
}

sub levelsHBars{
	my ($branch,$cant,$results)=@_;
	my $g = &inicializarGrafico("Niveles Bibliograficos (Barras)");

	my @descriptions;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
                 push (@descriptions,C4::AR::Utilidades::noaccents("mumancha")); #FIXME no toma la description
                 push (@values,$results->[$i]->agregacion_temp);
        };

#para generar las barras.
	$g->bar_3D( 50, '0x0066CC', 'cantidad',10 );
	$g->set_data(\@values );
	$g->set_x_labels(\@descriptions);
	$g->set_x_axis_3d(10);
	$g->set_y_min( 0 );
	$g->set_x_legend( 'Tipo de documentos', 10, '#736AFF' );
	$g->set_y_legend( 'Cantidades', 10, '#736AFF' );

	&finalizarGrafico($g);
	return ($g->render());
}

sub levelsPie{
	my ($branch,$cant,$results)=@_;
	my $g = &inicializarGrafico("Niveles Bibliograficos (Torta)");

	my @descriptions;
	my @values;
	my @colores;
	my $num;
	my $cantlevels;
	my $porclevels;
	my $varios="";
	my $totallevels=0;
	my $totalVar=0;
	for (my $i=0; $i < $cant ; $i++ ) {
		$totallevels+=$results->[$i]->agregacion_temp;
	}
    	for (my $i=0; $i < $cant ; $i++ ) {
		$cantlevels=$results->[$i]->agregacion_temp;
		#Para quedar acorde al pm (Si la cantidad es menor a 3% los suma en una misma porcion de la torta)
		$porclevels=sprintf("%.1f", ($cantlevels/ $totallevels) * 100.0);
		if($porclevels >= 3){
			push(@descriptions,C4::AR::Utilidades::noaccents("mumancha"));
     			push(@values,$cantlevels);
		}
		else{
			$totalVar+=$cantlevels;
		}
		$num=int(rand(499999))+500000;
		push(@colores,"#".$num);
        };
	if($totalVar > 0){
		push(@descriptions,"Otros");
     		push(@values,$totalVar);
		
	}
#para generar la torta
	$g->pie(50,'0x0066CC','{font-size: 12px; color: #404040;');
	$g->pie_values(\@values,\@descriptions);
	$g->pie_slice_colours(\@colores);
	$g->set_tool_tip("#val#%");

	&finalizarGrafico($g);
	return ($g->render());
}

1;

