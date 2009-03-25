package C4::AR::Debug;

use strict;

require Exporter;
# use C4::AR::Authldap;
# use C4::Membersldap;
use C4::Context;

use vars qw(@EXPORT @ISA);
@ISA = qw(Exporter);
@EXPORT = qw(
                &log      
);


sub log{
    my ($object, $data, $metodoLlamador) = @_;

    my $context = new C4::Context;

    if($context->config('debug')){
         open(Z, ">>/tmp/debug.txt");
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
		open(Z, ">>/tmp/debug.txt");
		print Z "\n";
		if($object){
			print Z "Object: ".$object->toString."=> ".$data."\n";
			print Z "\n";
		}
		close(Z);        
    }
}

=item
debug por linea
=cut
sub debug{
    my ($data) = @_;

    my $context = new C4::Context;

    if($context->config('debug')){
		open(Z, ">>/tmp/debug.txt");
		print Z "DEBUG=> ".$data."\n";
		close(Z);        
    }
}

sub _printHASH {
    my ($hash_ref) = @_;
print Z "\n";
print Z "   PRINT HASH: \n";
    if($hash_ref){
        while ( my ($key, $value) = each(%$hash_ref) ) {
                print Z "       key: $key => value: $value\n";
            }
    }
print Z "\n";
}


=pod

=back

=cut

1;

__END__
