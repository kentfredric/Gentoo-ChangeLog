
use strict;
use warnings;

package Gentoo::ChangeLog::Header::For;

{
  use Moose;

  has 'package' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
  );

  sub to_string {
    my ($self) = shift;
    return 'ChangeLog for ' . $self->package;
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;
}

1;

