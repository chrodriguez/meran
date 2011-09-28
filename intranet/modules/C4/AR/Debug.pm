package C4::AR::Debug;

use strict;

require Exporter;
# use C4::AR::Authldap;
# use C4::Membersldap;
use C4::Context;
#use Log::Log4perl qw(:easy);

use vars qw(@EXPORT @ISA);
@ISA = qw(Exporter);
@EXPORT = qw(
                &log      
);


sub log{
    my ($object, $data, $metodoLlamador) = @_;

    my $context = new C4::Context;

    if($context->config('debug')){
        my $debug_file = $context->config('debug_file') || "/usr/local/koha/logs/debug.txt";
        open(Z, ">>".$debug_file);
        print Z "\n";
        print Z "Object: ".$object->toString."=> ".$metodoLlamador."\n";
        ## FIXME falta ver si se le pasa un arreglo en vez de una HASH
        _printHASH($data);
        print Z "\n";
        close(Z);
    }
}


=item
debug por linea
=cut
sub debugObject{
    my ($object, $data) = @_;

    my $context = new C4::Context;

    if($context->config('debug')){
        my $debug_file = $context->config('debug_file') || "/usr/local/koha/logs/debug.txt";
        open(Z, ">>".$debug_file);
		print Z "\n";
		if($object){
			print Z "Object: ".$object->toString."=> ".$data."\n";
			print Z "\n";
		}
		close(Z);        
    }
}


sub debug_date_time{
    debug(_str_debug_date_time());
}

=head2
    sub _str_debug_date_time
    
    genera el string con la fecha y hora
=cut
sub _str_debug_date_time{

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    #     dia-mes-año    
    return $mday."-".($mon+1)."-".($year+1900)." ".$hour.":".$min.":".$sec;
}


#debug por linea
sub _write_debug{
    my ($data) = @_;

    my $context = new C4::Context;

    my $debug_file = $context->config('debug_file') || "/usr/local/koha/logs/debug.txt";
    open(Z, ">>".$debug_file);
    my $type = C4::AR::Auth::getSessionType();
    
	print Z "DEBUG -- $type --("._str_debug_date_time().") => ".$data."\n";
	close(Z);        
}

#debug por linea
sub debug{
    my ($data) = @_;

    my $context = new C4::Context;

    my $enabled = $context->config('debug');

    ($enabled && _write_debug($data));
}

sub getLogger{
    my $context = new C4::Context;

    my $file = $context->config('debug');
    my $config_file = $context->config('config_log4') || '/etc/meran/log4perl.conf' ;
    
    my $logger = Log::Log4perl->get_logger('all');
    
    Log::Log4perl::init_and_watch($config_file,10);
    
    return ($logger);
  
  
}
=item
sub debug{
    my ($data,$level) = @_;

    my $logger = getLogger();
    
    $level = $level || 1;

	# 1 = DEBUG
	# 2 = INFO
	# 3 = WARN
	# 4 = ERROR
	# 5 = FATAL
    use Switch;
    
    switch($level) {
		  case 1 {$logger->debug($data);}
		  case 2 {$logger->info($data);}
          case 3 {$logger->warn($data);}
          case 4 {$logger->error($data);}
          case 5 {$logger->fatal($data);}
          else   {$logger->debug($data);}
    }   
    
}
=cut

sub _printHASH {
    my ($hash_ref) = @_;

    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("PRINT HASH: \n");
    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
				C4::AR::Debug::debug("		key: $key => value: $value\n");
		}
    }

    C4::AR::Debug::debug("\n");
}


=item sub printSession

    imprime los datos de la sesion
    Parametros:
    $session: sesion de la cual se sacan los datos a imprimir
    $desde: desde donde se llama esta funcion

=cut
sub printSession {
    my ($session, $desde) = @_;

# TODO hace mas generico, falta data de la session
    C4::AR::Debug::debug("\n");
    C4::AR::Debug::debug("*******************************************SESSION******************************************************");
    C4::AR::Debug::debug("Desde:                        ".$desde);
    C4::AR::Debug::debug("session->userid:              ".$session->param('userid'));
    C4::AR::Debug::debug("session->loggedinusername:    ".$session->param('loggedinusername'));
    C4::AR::Debug::debug("session->borrowernumber:      ".$session->param('borrowernumber'));
    C4::AR::Debug::debug("session->password:            ".$session->param('password'));
    C4::AR::Debug::debug("session->nroRandom:           ".$session->param('nroRandom'));
    C4::AR::Debug::debug("session->sessionID:           ".$session->param('sessionID'));
    C4::AR::Debug::debug("session->lang:                ".$session->param('lang'));
    C4::AR::Debug::debug("session->type:                ".$session->param('type'));
    C4::AR::Debug::debug("session->flagsrequired:       ".$session->param('flagsrequired'));
    C4::AR::Debug::debug("session->REQUEST_URI:         ".$session->param('REQUEST_URI'));
    C4::AR::Debug::debug("session->browser:             ".$session->param('browser'));
    C4::AR::Debug::debug("*****************************************END**SESSION****************************************************");
    C4::AR::Debug::debug("\n");
}
=pod

=back

=cut

1;

__END__
