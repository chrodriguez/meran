package MARC::Moose::Reader::File::Iso2709;
{
  $MARC::Moose::Reader::File::Iso2709::VERSION = '0.026';
}
# ABSTRACT: File reader for MARC::Moose record from ISO2709 file

use Moose;
use 5.010;
use utf8;
use Carp;
use MARC::Moose::Record;
use MARC::Moose::Parser::Iso2709;

with 'MARC::Moose::Reader::File';


has '+parser' => ( default => sub { MARC::Moose::Parser::Iso2709->new() } );


sub read {
    my $self = shift;

    $self->count( $self->count + 1);

    my $fh = $self->{fh};

    return if eof($fh);

    local $/ = "\x1D"; # End of record
    my $raw = <$fh>;

    # remove illegal garbage that sometimes occurs between records
    $raw =~ s/^[ \x00\x0a\x0d\x1a]+//;

    return $self->parser->parse( $raw );
}


__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Reader::File::Iso2709 - File reader for MARC::Moose record from ISO2709 file

=head1 VERSION

version 0.026

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

