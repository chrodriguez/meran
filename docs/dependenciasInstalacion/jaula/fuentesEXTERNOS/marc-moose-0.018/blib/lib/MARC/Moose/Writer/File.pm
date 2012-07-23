package MARC::Moose::Writer::File;
BEGIN {
  $MARC::Moose::Writer::File::VERSION = '0.018';
}
# ABSTRACT: File record writer

use namespace::autoclean;
use Moose;

use Carp;
use MARC::Moose::Record;

extends 'MARC::Moose::Writer';

has file => (
    is => 'rw',
    isa => 'Str',
    trigger => sub {
        my ($self, $file) = @_; 
        #croak "File already exists: " . $file  if -e $file;
        $self->{file} = $file;
        open my $fh, '>',$self->file
            or croak "Impossible to open file: " . $self->file;
        binmode $fh, $self->binmode;
        $self->fh($fh);
    }   
);

has fh => ( is => 'rw' );

has binmode => ( is => 'rw', isa => 'Str', default => '' );


override 'begin' => sub {
    my $self = shift;
    my $fh = $self->fh;
    print $fh $self->formater->begin();
};


override 'end' => sub {
    my $self = shift;
    my $fh = $self->fh;
    print $fh $self->formater->end();
};


override 'write' => sub {
    my ($self, $record) = @_;

    $self->count( $self->count + 1 );

    my $fh = $self->fh;
    print $fh $self->formater->format($record);
};

__PACKAGE__->meta->make_immutable;

1;



__END__
=pod

=head1 NAME

MARC::Moose::Writer::File - File record writer

=head1 VERSION

version 0.018

=head1 ATTRIBUTES

=head2 file

Name of the file into which writing L<MARC::Moose::Record> records using
I<write> method.  Before writing into the file, record is formatted using a
formater.

=head2 binmode

Binmode of the result file. Example:

 my $writer = MARC::Moose::Writer->new(
   binmode  => 'utf8',
   file     => 'output.iso2709',
   formater => MARC::Moose::Formater::Iso2709->new() );

=head1 SEE ALSO

=over 4

=item *

L<MARC::Moose>

=item *

L<MARC::Moose::Writer>

=back

=head1 AUTHOR

Frederic Demians <f.demians@tamil.fr>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Frederic Demians.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

