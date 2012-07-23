package MARC::Moose::Reader::File::Isis;
BEGIN {
  $MARC::Moose::Reader::File::Isis::VERSION = '0.018';
}
# ABSTRACT: A file reader for ISIS (DOS) encoded records

use namespace::autoclean;
use Moose;

use Carp;
use MARC::Moose::Record;
use MARC::Moose::Parser::Isis;

extends 'MARC::Moose::Reader::File';


has parser => ( 
    is => 'rw', 
    isa => 'MARC::Moose::Parser',
    default => sub { MARC::Moose::Parser::Isis->new() },
);


override 'read' => sub {
    my $self = shift;

    $self->SUPER::read();

    my $fh = $self->fh;
    my $raw;
    while ( <$fh> ) {
        s/\x0a|\x0d//g;
        $raw .= $_;
        last if /\x1d/; # End of record separator
    }
    return 0 unless $raw;

    return $self->parser->parse( $raw );
};

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

MARC::Moose::Reader::File::Isis - A file reader for ISIS (DOS) encoded records

=head1 VERSION

version 0.018

=head1 METHODS

=head2 read

Read next available L<MARC::Moose::Record> from reader file using
L<MARC::Moose::Parser::Isis> parser.

=head1 SEE ALSO

=over 4

=item *

L<MARC::Moose>

=item *

L<MARC::Moose::Reader::File>

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

