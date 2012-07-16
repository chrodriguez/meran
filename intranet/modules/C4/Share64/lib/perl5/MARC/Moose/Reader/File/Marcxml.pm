package MARC::Moose::Reader::File::Marcxml;
BEGIN {
  $MARC::Moose::Reader::File::Marcxml::VERSION = '0.018';
}
# ABSTRACT: File reader for MARCXML file

use namespace::autoclean;
use Moose;

use Carp;
use MARC::Moose::Record;
use MARC::Moose::Parser::Marcxml;

extends 'MARC::Moose::Reader::File';


has parser => ( 
    is => 'rw', 
    isa => 'MARC::Moose::Parser',
    default => sub { MARC::Moose::Parser::Marcxml->new() },
);


override 'read' => sub {
    my $self = shift;

    $self->SUPER::read();

    my $fh = $self->{fh};

    return if eof($fh);

    local $/ = "</record>"; # End of record
    my $raw = <$fh>;
    
    # Skip <collection if present
    $raw =~ s/<(\/*)collection.*>//;

    # End of file
    return unless $raw =~ /<record>/;

    return $self->parser->parse( $raw );
};

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

MARC::Moose::Reader::File::Marcxml - File reader for MARCXML file

=head1 VERSION

version 0.018

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

