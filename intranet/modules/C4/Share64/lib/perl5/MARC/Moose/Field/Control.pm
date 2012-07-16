package MARC::Moose::Field::Control;
BEGIN {
  $MARC::Moose::Field::Control::VERSION = '0.018';
}
# ABSTRACT: Control Marc field (tag < 010)

use namespace::autoclean;
use Moose;

extends 'MARC::Moose::Field';

has value => ( is => 'rw', isa => 'Str' );

override 'as_formatted' => sub {
    my $self = shift;

    join ' ', ( $self->tag, $self->value );
};

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

MARC::Moose::Field::Control - Control Marc field (tag < 010)

=head1 VERSION

version 0.018

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

