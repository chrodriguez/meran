package MARC::Moose::Parser::Yaml;
{
  $MARC::Moose::Parser::Yaml::VERSION = '0.026';
}
# ABSTRACT: Parser for YAML records

use Moose;

extends 'MARC::Moose::Parser';

use YAML::Syck;

$YAML::Syck::ImplicitUnicode = 1;

# FIXME Experimental. Not used yet.
#has converter => (
#    is      => 'rw',
#    isa     => 'Text::IconvPtr',
#    default => sub { Text::Iconv->new( "cp857", "utf8" ) }
#);



override 'parse' => sub {
    my ($self, $raw) = @_;

    #print "\nRAW: $raw\n";
    return unless $raw;
    return Load( $raw );
};

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Parser::Yaml - Parser for YAML records

=head1 VERSION

version 0.026

=head1 SEE ALSO
=for :list
* L<MARC::Moose>
* L<MARC::Moose::Parser>

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

