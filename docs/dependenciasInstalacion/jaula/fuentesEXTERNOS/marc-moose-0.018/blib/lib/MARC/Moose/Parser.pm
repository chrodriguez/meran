package MARC::Moose::Parser;
BEGIN {
  $MARC::Moose::Parser::VERSION = '0.018';
}
# ABSTRACT: A record parser base class

use namespace::autoclean;
use Moose;


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

=head1 NAME

MARC::Moose::Parser - A record parser base class

=head1 VERSION

version 0.018

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

L<MARC::Moose::Parser::Iso2709>

=item *

L<MARC::Moose::Parser::MARC::Moosexml>

=item *

L<MARC::Moose::Parser::Isis>

=back

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

