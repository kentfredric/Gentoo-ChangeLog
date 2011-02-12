
use strict;
use warnings;

package Gentoo::ChangeLog::Header::CVSHeader;

{
  use Moose;

  has 'name' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub { 'Header' }
  );
  has 'value' => (
    isa     => 'Str',
    is      => 'rw',
    default => sub { q{} }
  );

  sub to_string {
    my ($self) = @_;
    # this is a bit messy to obfuscate the header string from CVS and friends.
    if ( $self->value ) {
      return sprintf q{%s%s: %s %s}, '$', $self->name, $self->value, '$';
    }
    else {
      return sprintf q{%s%s: %s}, '$', $self->name, '$';
    }
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;

}

1;
