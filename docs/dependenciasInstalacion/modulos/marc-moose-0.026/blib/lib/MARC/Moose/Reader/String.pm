package MARC::Moose::Reader::String;
{
  $MARC::Moose::Reader::String::VERSION = '0.026';
}
# ABSTRACT: A Moose::Role reader from a string

use Moose::Role;

with 'MARC::Moose::Reader';

has string => ( is => 'rw', isa => 'Str' );


1;


__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Reader::String - A Moose::Role reader from a string

=head1 VERSION

version 0.026

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

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

