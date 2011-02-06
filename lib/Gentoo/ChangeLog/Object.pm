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

has 'changelog_for'      => ( isa => Str, is => rw => required => 1 );
has 'copyright_starting' => ( isa => Int, is => rw => default  => $DEFAULT_START_DATE );
has 'copyright_ending'   => ( isa => Int, is => rw => default  => sub { [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET } );
has 'header_string'      => ( isa => Str, is => rw => default  => $EMPTY_STRING );

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

    $object->update_copyright(); # set to the current year
    $object->update_copyright(1995); # set to an arbitrary year

=cut

sub update_copyright {
  my ( $self, $year ) = @_;
  if ( not defined $year ) {
    $year = [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET;
  }
  return $self->changelog_ending($year);
}

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

sub stringify {
  return join qq{\n}, shift->arify;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;
