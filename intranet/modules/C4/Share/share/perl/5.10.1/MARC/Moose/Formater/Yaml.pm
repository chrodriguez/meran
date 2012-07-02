package MARC::Moose::Formater::Yaml;
{
  $MARC::Moose::Formater::Yaml::VERSION = '0.026';
}
# ABSTRACT: Marc record formater into YAML representation

use Moose;

extends 'MARC::Moose::Formater';

use MARC::Moose::Field::Control;
use MARC::Moose::Field::Std;
use YAML::Syck;

$YAML::Syck::ImplicitUnicode = 1;


override 'format' => sub {
    my ($self, $record) = @_;

    return Dump($record);
};

__PACKAGE__->meta->make_immutable;

1;

__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Formater::Yaml - Marc record formater into YAML representation

=head1 VERSION

version 0.026

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

