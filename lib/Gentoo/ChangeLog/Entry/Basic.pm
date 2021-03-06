
use strict;
use warnings;

package Gentoo::ChangeLog::Entry::Basic;

# ABSTRACT: A Basic Changelog Entry.

{
  use Moose;
  use MooseX::StrictConstructor;
  use MooseX::Types::Moose qw( :all );
  use Text::Wrap ();
  use Text::Autoformat qw( autoformat break_wrap );
  use Params::Util qw( _STRING );
  use POSIX qw( strftime );
  use namespace::clean -except => 'meta';

  has 'added_files'    => ( isa => ArrayRef [Str], is => 'rw', default => sub { [] } );
  has 'removed_files'  => ( isa => ArrayRef [Str], is => 'rw', default => sub { [] } );
  has 'modified_files' => ( isa => ArrayRef [Str], is => 'rw', default => sub { [] } );
  has 'date_stamp' => ( isa => Str, is => 'rw', default => sub { strftime( '%d %b %Y', gmtime ) } );
  has 'author_name'  => ( isa => Str, is => 'rw', required => 1 );
  has 'author_email' => ( isa => Str, is => 'rw', required => 1 );
  has 'message' => ( isa => ( Str | ArrayRef [Str] ), is => 'rw', required => 1 );
  has 'message_reformat' => ( isa => Bool, is => 'rw', default => 1 );
  with 'Gentoo::ChangeLog::Role::Entry';

  sub _trace {
    return warn shift . q{:} . shift . qq{\n};
  }

  sub wrapped_message {
    my $self = shift;
    my $data = q{};
    if ( _STRING( $self->message ) ) {
      $data = $self->message;
    }
    else {
      $data = join "\n", @{ $self->message };
    }
    my $fmt = autoformat( $data, { squeeze => 1, all => 1, widow => 0, justify => 'left', tabspace => 2, break => break_wrap } );
    my @outlines = split /\n/msx, $fmt;
    $_ =~ s{\s*$}{}gmsx for @outlines;
    return @outlines;
  }

  sub wrapped_heading {
    my $self = shift;
    my $heading = sprintf q{%s; %s <%s>}, $self->date_stamp, $self->author_name, $self->author_email;
    my @changedfiles;
    if ( $self->adds_files ) {
      push @changedfiles, map { q{+} . $_ } @{ $self->added_files };
    }
    if ( $self->removes_files ) {
      push @changedfiles, map { q{-} . $_ } @{ $self->removed_files };
    }
    if ( $self->modifies_files ) {
      push @changedfiles, map { q{} . $_ } @{ $self->modified_files };
    }
    if (@changedfiles) {
      $heading .= q{ } . join q{, }, @changedfiles;
    }
    $heading .= q{:};
    my @lines = split /\n/msx, Text::Wrap::wrap( q{}, q{}, $heading );
    $_ =~ s{\s*$}{}gmsx for @lines;
    return @lines;
  }

  sub lines {
    my $self = shift;
    return map { q{ } x 2 . $_ } $self->wrapped_heading, $self->wrapped_message;
  }
  __PACKAGE__->meta->make_immutable;
  no Moose;
}
1;
