package C4::AR::StatGraphs;

#
#Este modulo sera el encargado del manejo de estadisticas sobre los prestamos
#,reservas, devoluciones y todo tipo de consulta sobre el uso de la biblioteca
#
#

use strict;
require Exporter;

use C4::Context;
use C4::Date;
use C4::Search;
use Chart::Pie;
use Chart::HorizontalBars;
use Chart::LinesPoints;

use vars qw(@EXPORT @ISA);
@ISA=qw(Exporter);
@EXPORT=qw(
		&itemtypesPie 
		&itemtypesHBars 
		&levelsPie 
		&levelsHBars 
		&availLines
		&userCategPie
		&userCategHBars
	);

sub itemtypesPie
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
my $lang=C4::Context->preference('opaclanguages');
my $template=C4::Context->preference('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/itemtypepie$branch.png");
}

sub itemtypesHBars 
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

my $lang=C4::Context->preference('opaclanguages');
my $template=C4::Context->preference('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/itemtypehbars$branch.png");
}



sub levelsPie
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

my $lang=C4::Context->preference('opaclanguages');
my $template=C4::Context->preference('template');
$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/levelpie$branch.png");
}

sub levelsHBars 
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
my $lang=C4::Context->preference('opaclanguages');
my $template=C4::Context->preference('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/levelhbars$branch.png");
}

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
my @labels;
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


sub userCategPie(){
	my ($branch,$cant,@results)=@_;
	my $g = Chart::Pie->new(700,500);

	my @categorias;
	my @values;
    	for (my $i=0; $i < $cant ; $i++ ) {
                 push (@categorias,$results[$i]->{'categoria'});
     		 push (@values,$results[$i]->{'cant'});
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
	my $lang=C4::Context->preference('opaclanguages');
	my $template=C4::Context->preference('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/usercategpie$branch.png");

}

sub userCategHBars(){
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

	my $lang=C4::Context->preference('opaclanguages');
	my $template=C4::Context->preference('template');

$g->png ("/usr/local/koha/intranet/htdocs/intranet-tmpl/$template/$lang/images/stats/usercateghbars$branch.png");
}


