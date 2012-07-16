package MARC::Moose::Formater;
BEGIN {
  $MARC::Moose::Formater::VERSION = '0.018';
}
# ABSTRACT: Base class to format Marc record

use namespace::autoclean;
use Moose;


# FIXME Experimental. Not used yet.
#has converter => (
#    is      => 'rw',
#    isa     => 'Text::IconvPtr',
#    default => sub { Text::Iconv->new( "cp857", "utf8" ) }
#);


sub begin { }

sub end { }


sub format {
    my ($self, $record) = @_;
    return "Marc Record";
};

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=head1 NAME

MARC::Moose::Formater - Base class to format Marc record

=head1 VERSION

version 0.018

=head1 DESCRIPTION

A Marc formater is used by any writer to transform a Marc record into something
undestandable by human (text readable format) or by machine (standartized format
like ISO2709 or MARCXML).

A formater surclass this base class 3 methods to format a set of Marc records.

=head1 METHODS

=head2 begin

Prior to formating a set of records one by one calling I<format> method, a
writer may need an header which is returned by this method.

=head2 end

A the end of formating a set of records, it may be required by a writer to
finished its stream of date by a footer.

=head2 format

Returns a string containing a representation of a Marc record.

  # $formater type is Marc::Formater subclass
  # $record type Marc::Record or any subclass
  my $formatted_string = $formater->format( $record );

=head1 SEE ALSO

=over 4



=back

* L<MARC::Moose>
* L<MARC::Moose::Formater::Iso2709>
* L<MARC::Moose::Formater::Marcxml>
* L<MARC::Moose::Formater::Text>
* L<MARC::Moose::Formater::Yaml>

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

