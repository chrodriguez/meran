package MARC::Moose::Formater::Legacy;
{
  $MARC::Moose::Formater::Legacy::VERSION = '0.026';
}
# ABSTRACT: Record formater into the legacy MARC::Record object

use Moose;

extends 'MARC::Moose::Formater';

use MARC::Moose::Field::Control;
use MARC::Moose::Field::Std;
use MARC::Record;


override 'format' => sub {
    my ($self, $record) = @_;

    my $marc = MARC::Record->new;
    $marc->leader( $record->leader );
    for my $field ( @{$record->fields} ) {
        my $nfield;
        if ( $field->tag < 10 ) {
            my $value = $field->value;
            utf8::decode($value);
            $nfield =  MARC::Field->new( $field->tag, $field->value );
        }
        else {
            my @sf;
            for (@{$field->subf}) {
                my ($letter, $value) = @$_;
                utf8::decode($value);
                push @sf, $letter, $value;
            }
            $nfield = MARC::Field->new( $field->tag, $field->ind1, $field->ind2, @sf );
        }
        $marc->append_fields($nfield);
    }
    return $marc;
};

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Formater::Legacy - Record formater into the legacy MARC::Record object

=head1 VERSION

version 0.026

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

