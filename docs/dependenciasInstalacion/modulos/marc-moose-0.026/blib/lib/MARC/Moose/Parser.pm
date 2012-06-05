package MARC::Moose::Parser;
{
  $MARC::Moose::Parser::VERSION = '0.026';
}
# ABSTRACT: A record parser base class

use Moose;
use 5.010;
use utf8;

# FIXME Experimental. Not used yet.
#has converter => (
#    is      => 'rw',
#    isa     => 'Text::IconvPtr',
#    default => sub { Text::Iconv->new( "cp857", "utf8" ) }
#);



sub begin {
    return "";
}



sub end {
    return "";
}



sub parse {
return MARC::Moose::Record->new();
};

__PACKAGE__->meta->make_immutable;

1;




__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Parser - A record parser base class

=head1 VERSION

version 0.026

=head1 METHODS

=head2 begin

=head2 end

=head2 parse

Return a MARC::Moose::Record object build from a parsed string

=head1 SEE ALSO

=over 4

=item *

L<MARC::Moose>

=item *

L<MARC::Moose::Parser::Isis.pm

=item *

L<MARC::Moose::Parser::Iso2709.pm

=item *

L<MARC::Moose::Parser::Legacy.pm

=item *

L<MARC::Moose::Parser::Marcxml.pm

=item *

L<MARC::Moose::Parser::MarcxmlSax.pm

=item *

L<MARC::Moose::Parser::MarcxmlSaxSimple.pm

=item *

L<MARC::Moose::Parser::Yaml.pm

=back

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

