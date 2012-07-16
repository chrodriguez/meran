package MARC::Moose::Reader::String;
BEGIN {
  $MARC::Moose::Reader::String::VERSION = '0.018';
}
# ABSTRACT: A reader from a string

use namespace::autoclean;
use Moose;

use Carp;
use MARC::Moose::Record;

extends 'MARC::Moose::Reader';

has string => ( is => 'rw', isa => 'Str' );


__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

MARC::Moose::Reader::String - A reader from a string

=head1 VERSION

version 0.018

=head1 ATTRIBUTES

=head2 string

The string containing the set of records to parser.

=head1 SEE ALSO

=over 4

=item *

L<MARC::Moose>

=item *

L<MARC::Moose::Reader>

=item *

L<MARC::Moose::Reader::String::Iso2709>

=back

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

