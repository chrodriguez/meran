package MARC::Moose::Reader;
{
  $MARC::Moose::Reader::VERSION = '0.026';
}
# ABSTRACT: Base class for a reader returning MARC::Moose records

use Moose::Role;

with 'MooseX::RW::Reader';




has parser => (
    is => 'rw', isa => 'MARC::Moose::Parser',
);


1;


__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Reader - Base class for a reader returning MARC::Moose records

=head1 VERSION

version 0.026

=head1 ATTRIBUTES

=head2 parser

L<MARC::Moose::Parser> parser used to parse record that have been read.

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

