use strict;
use warnings;

package Gentoo::ChangeLog::Object;

# ABSTRACT: An Abstract representation of a Gentoo format ChangeLog.

use Moose;
use MooseX::StrictConstructor;
use MooseX::Types::Moose qw( :all );
use Gentoo::ChangeLog::Types qw( :all );

use Gentoo::ChangeLog::Header;
use namespace::clean -except => 'meta';
use Readonly;

Readonly my $EMPTY_STRING         => q{};

=head1 SYNOPSIS

This object represents an abstract structured copy of the ChangeLog.

    my $object = Gentoo::Changelog->parse('/path/to/file');
    $object->update_copyright();
    $object->insert( $new_change_event );
    $object->write( '/path/to/file');

=cut


has 'header' => (
    isa => ChangeLogHeader,
    is => 'rw',
    required => 1,
);


=attr entries

The entries attribute is the heart and soul of this Module, and it contains a list,
time-wise, of all the changelog entries.

An entry can be any valid L<< C<ChangeLogEntry>|Gentoo::ChangeLog::Types/ChangeLogEntry >>;

=head3 Specification : ArrayRef [ ChangeLogEntry ] , rw, default => []

=head3 Construction ( optional )

    my $object = ....->new( entries => [ $entry, $entry, ... ] ... );

=head3 Reading

=head4 As an Array Reference

   my $list = $object->entries();
   print Dumper( $list->[0] );

=head4 As a List

    my @list = $object->entries_list();
    for( @list ){
        ...
    }

=head3 Setting

=head4 Wholesale replacement.

    $object->entries( [ $entry, $entry , $entry ] );

=head4 Inserting a new entry

New entries by default are prepended to the list, as they are to appear at the top
of the changelog, which contains the most recent entries.

    $object->insert( $entry );


=head3 See also:

=over 4

=item L<< C<ChangeLogEntry>|Gentoo::ChangeLog::Types/ChangeLogEntry >> - The ChangeLogEntry type

=item L<< C<::Role::Entry>|Gentoo::ChangeLog::Role::Entry >> - The ChangeLog Entry Role that all entries must 'do'.

=item L<< C<::Entry::Basic>|Gentoo::Changelog::Entry::Basic >> - A Basic Entry type.

=back


=cut

has 'entries' => (
  isa => ArrayRef [ChangeLogEntry],
  is      => rw => default => sub { [] },
  traits  => [qw( Array )],
  handles => {
    'entries_list' => 'elements',
    'insert'       => 'unshift',
  },
);

=method arify

This method returns a list of lines representing a ChangeLog file.

=head3 Specification : $object->arify()

    my @lines = $object->arify();

=head3 See Also

=over 4

=item L</stringify> - The same as this, but returns one big string.

=back

=cut

sub arify {
  my $self = shift;
  my @out;
  push @out, $self->header->to_string_list;

  for my $entry ( $self->entries_list ) {
    push @out, $EMPTY_STRING;
    push @out, $entry->lines();
  }
  return @out;
}

=method stringify

This method returns a single large string representing the whole ChangeLog file.

=head3 Specification : $object->stringify();

    $fh->print( $object->stringify() )

=head3 See Also

=over 4

=item L</arify> - The same as this, but as an array of lines

=back

=cut

sub stringify {
  return join qq{\n}, shift->arify;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
