package C4::AR::ImportacionXML;

=head
    Este modulo sera el encargado de realizar importaciones apartir de un XML
=cut

use strict;
require Exporter;
use C4::Context;
use C4::AR::XMLDBI;
use C4::Context;
use C4::AR::Utilidades ();
use XML::Checker::Parser;

use vars qw(@EXPORT_OK @ISA);
@ISA        = qw(Exporter);
@EXPORT_OK  = qw(
        importarVisualizacion
);


=item
    Realiza la importacion de una visualizacion OPAC o INTRA
=cut
sub importarVisualizacion{

    my ($params,$postdata)  = @_;

    my $msg_object          = C4::AR::Mensajes::create();


    ######################## escribimos el archivo en /tmp ####################


    my @whiteList   = qw(
                            xml
                        );

    my $path    = "/tmp/output.xml";
    
    eval {
        # doesn't work
        # open(F, ">$path") or die "Cant write to $path. Reason: $!";
        #     print F $postdata;
        # close(F);

        # con BINMODE UN XML !!!! WTF !!!
        open ( WRITEIT, ">$path" ) or die "$!"; 
        binmode WRITEIT; 
        while ( <$postdata> ) { 
            print WRITEIT; 
        }
        close(WRITEIT);
    };

    if ($@) {
        C4::AR::Debug::debug("se murio escribiendo el archivo");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML03', 'intra'} ) ;
    
        return ($msg_object);
    }


    ############################# validacion con DTD ########################

    # TODO!!

    # my $parser = new XML::Checker::Parser( SkipExternalDTD => 1 );

    # # FIXME
    # XML::Checker::Parser::set_sgml_search_path('C4::Context->config("opachtdocs").'visualizacion.dtd');
        
    # eval {

    #      $parser->parsefile($path);
    # };

    # if ($@) {

    #     # no es valido el xml
    #     C4::AR::Debug::debug("se murio porque no es valido el XML");
    #     $msg_object->{'error'} = 1;
    #     C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML01', 'intra'} ) ;

    #     return ($msg_object);
    # }


    ############################# importacion en la base ########################

    # perl xml2sql.pl -sn econo -uid root -pwd dev -table cat_visualizacion_opac -input output.xml -v -driver mysql -x

    my $context = new C4::Context;

    my $user    = $context->config('userINTRA');
    my $pass    = $context->config('passINTRA');
    my $db      = $context->config('database');
    my $table   = 'cat_visualizacion_opac';

    my $xmldb   = XMLDBI->new('mysql', $db  . ';host=localhost', $user, $pass, 'cat_visualizacion_opac', $db);

    #por ahora se borra siempre antes
    $xmldb->execute("DELETE FROM $table");

    eval {

        open(FILE, $path) or die $!;
        my $file = join "", <FILE>;


        $xmldb->parsestring($file);
    };

    if($@){
        # no pudo insertarlo o algun error 
        C4::AR::Debug::debug("se murio insertandolo en la base");
        $msg_object->{'error'} = 1;
        C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML02', 'intra'} ) ;

        return ($msg_object);
    }

    $msg_object->{'error'} = 0;
    
    C4::AR::Mensajes::add($msg_object, {'codMsg'=> 'IXML00', 'intra'} ) ;

    return ($msg_object);
}

END { }       # module clean-up code here (global destructor)

1;
__END__