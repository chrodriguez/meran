package MARC::Moose::Reader::File;
{
  $MARC::Moose::Reader::File::VERSION = '0.026';
}
# ABSTRACT: A Moose::Role MARC::Moose::Record reader from a file

use Moose::Role;

with 'MARC::Moose::Reader',
     'MooseX::RW::Reader::File';


1;


__END__
=pod

=encoding UTF-8

=head1 NAME

MARC::Moose::Reader::File - A Moose::Role MARC::Moose::Record reader from a file

=head1 VERSION

version 0.026

=head1 SEE ALSO

=over 4

=item *

L<MARC::Moose>

=item *

L<MARC::Moose::Reader>

=back

=head1 AUTHOR

Frédéric Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Frédéric Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

