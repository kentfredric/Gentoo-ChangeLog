use strict;
use warnings;

package Gentoo::ChangeLog::Object;

# ABSTRACT: An Abstract representation of a Gentoo format ChangeLog.

use Moose;
use MooseX::Types::Moose qw( :all );
use Gentoo::ChangeLog::Types qw( :all );
use namespace::clean -except => 'meta';
use Readonly;

Readonly my $DEFAULT_START_DATE   => 1999;
Readonly my $EPOCH_OFFSET         => 1900;
Readonly my $LOCALTIME_YEAR_FIELD => 5;
Readonly my $EMPTY_STRING         => q{};

=head1 SYNOPSIS

This object represents an abstract structured copy of the ChangeLog.

    my $object = Gentoo::Changelog->parse('/path/to/file');
    $object->update_copyright();
    $object->insert( $new_change_event );
    $object->write( '/path/to/file');

=cut

=attr changelog_for

What this current changelog is intended to index. Usually contains the ebuild C< cat/package > part.

=head3 Specification : Str, rw, required

=head3 Construction

    my $object = ...->new( changelog_for => 'dev-lang/perl' , ... );

=head3 Reading

    my $for = $object->changelog_for();

=head3 Setting

    $object->changelog_for("sys-devel/gcc");

=cut

has 'changelog_for'      => ( isa => Str, is => rw => required => 1 );

=attr copyright_starting

Copyright statements in Gentoo are in 2 halves, left hand being the starting date
of the project, and the right half being the date of the last modification.

Generally, the left hand side is '1999', the date of the start of the Gentoo project,
under which all Ebuilds and Changelog files are implementations of a concept Copyrighted
to the Gentoo project.

=head3 Specification : Int, rw, default => 1999

=head3 Construction ( optional )

    my $object = ...->new( copyright_starting => 2001 ... );

=head3 Reading

    my $copystart = $object->copyright_starting();
    print "(C) $copystart - 2011\n";

=head3 Setting

    $object->copyright_starting( 1999 );

=head3 See Also

=over 4

=item L</copyright_ending> - The corresponding other half.

=back

=cut

has 'copyright_starting' => ( isa => Int, is => rw => default  => $DEFAULT_START_DATE );

=attr copyright_ending

See L</copyright_starting>.

This is the right hand field of that copyright, intended to be updated every time a file bearing
this copyright is updated.

=head3 Specification : Int, rw, default => current year.

=head3 Construction ( optional )

    my $object = ...->new( copyright_ending => 2011 ... );

=head3 Reading

    my $copyend = $object->copyright_ending()
    print "(C) 1999 - $copyend\n";

=head3 Setting

    $object->copyright_ending( 2011 );

=head3 See Also

=over 4

=item L</copyright_starting> - The left hand half of this copyright.

=item L</update_copyright> - A more practical dwim interface to this field.

=back

=cut

has 'copyright_ending'   => ( isa => Int, is => rw => default  => sub { [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET } );

#
# ***** EDITOR NOTE *****
# The Z<> stuff in here and not using indentations is to prevent disaster should somebody
# accidentally check this file verbatim into CVS.
#
=attr header_string

As a legacy to the CVS system, all ChangeLog files have a CVS header line like:

C<< $Z<>HeaderZ<>:Z<> /var/cvsroot/gentoo-x86/dev-lang/perl/ChangeLog,v 1.359 2011/01/22 11:19:07 armin76 Exp Z<>$Z<> >>

Its quite safe to leave this value as the default ( empty ) so it emits:

C<< Z<>$Z<>Header: Z<>$Z<> >>

And CVS will populate it the right way.

This field is mostly to preserve this field from parsed ChangeLog files so emitted files
can retain whatever the previous value of this field was.

=head3 Specification : Str, rw, default => ''

=head3 Construction ( optional )

    my $object = ...->new( header_string => "OHAICVS" );

=head3 Reading

    my $header = $object->header_string();

=head3 Setting

    $object->header_string("/var/cvsroot/fake/etc etc etc");

=cut

has 'header_string'      => ( isa => Str, is => rw => default  => $EMPTY_STRING );

=attr entries

The entries attribute is the heart and soul of this Module, and it contains a list,
timewise, of all the changelog entries.

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

=method update_copyright

This is a convenience method for updating the copyright on a changelog.

=head3 Specification : $object->update_copyright()

This form updates the copyright end date to reflect the current year of the local machine ( using gmtime );

=head4 Example

    $object->update_copyright( 1969 );
    $object->update_copyright() # Copyright is no longer 1969, but instead something more recent like 2011

=head3 Specification : $object->update_copyright( $year )

This form updates the copyright end date to reflect the specified year.

Note we do no checks at present to make sure the end date is after the start date.

=head4 Example

    $object->update_copyright()
    $object->update_copyright(1969) # Copyright end date is now 1969.

=cut

sub update_copyright {
  my ( $self, $year ) = @_;
  if ( not defined $year ) {
    $year = [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET;
  }
  return $self->changelog_ending($year);
}

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
  push @out, sprintf q{# ChangeLog for %s}, $self->changelog_for;
  push @out, sprintf q{# Copyright %s-%s Gentoo Foundation; Distributed under the GPL v2}, $self->copyright_starting,
    $self->copyright_ending;
  push @out, sprintf q{# %sHeader: %s %s}, q{$}, $self->header_string, q{$};
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
