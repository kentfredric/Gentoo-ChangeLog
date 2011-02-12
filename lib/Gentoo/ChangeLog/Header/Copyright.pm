use strict;
use warnings;

package Gentoo::ChangeLog::Header::Copyright;

{
  use Moose;

  use Readonly;

  use namespace::clean -except => 'meta';

  Readonly my $DEFAULT_START_DATE   => 1999;
  Readonly my $EPOCH_OFFSET         => 1900;
  Readonly my $LOCALTIME_YEAR_FIELD => 5;

  has 'start' => (
    isa     => 'Int',
    is      => 'rw',
    default => sub { $DEFAULT_START_DATE }
  );

  has 'stop' => (
    isa     => 'Int',
    is      => 'rw',
    default => sub { [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET }
  );

  has 'holder' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub { 'Gentoo Foundation' }
  );

  has 'license' => (
    isa     => 'Maybe[Str]',
    is      => 'rw',
    default => sub { 'Distributed under the GPL v2' }
  );

  sub update {
    my ( $self, $year ) = @_;
    $year ||= [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET;
    $self->stop($year);
  }

  sub to_string {
    my ($self) = @_;
    my $license = '';
    $license = '; ' . $self->license if $self->license;
    return sprintf q{Copyright %s-%s %s%s}, $self->start, $self->stop, $self->holder, $license;
  }
  __PACKAGE__->meta->make_immutable;

  no Moose;
}

1;
