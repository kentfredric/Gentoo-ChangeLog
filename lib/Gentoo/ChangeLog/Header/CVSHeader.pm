
use strict;
use warnings;

package Gentoo::ChangeLog::Header::CVSHeader;

# ABSTRACT: A header line containing a CVS directive.

{
  use Moose;
  use MooseX::Types::Moose qw( :all );
  use Gentoo::ChangeLog::Types qw( :all );

=attr name

=head3 Specification : Str, rw, default => 'Header'

=cut

  has 'name' => (
    isa     => NoPadStr,
    is      => 'rw',
    default => sub { 'Header' },
  );

  #
  # ***** EDITOR NOTE *****
  # The Z<> stuff in here and not using indentations is to prevent disaster should somebody
  # accidentally check this file verbatim into CVS.
  #

=attr value

As a legacy to the CVS system, all ChangeLog files have a CVS header line like:

C<< $Z<>HeaderZ<>:Z<> /var/cvsroot/gentoo-x86/dev-lang/perl/ChangeLog,v 1.359 2011/01/22 11:19:07 armin76 Exp Z<>$Z<> >>

Its quite safe to leave this value as the default ( empty ) so it emits:

C<< Z<>$Z<>Header: Z<>$Z<> >>

And CVS will populate it the right way.

This field is mostly to preserve this field from parsed ChangeLog files so emitted files
can retain whatever the previous value of this field was.

=head3 Specification : Str, rw, default => ''

=head3 Construction ( optional )

    my $object = ...->new( value => "OHAICVS" );

=head3 Reading

    my $header = $object->value();

=head3 Setting

    $object->value("/var/cvsroot/fake/etc etc etc");

=cut

  has 'value' => (
    isa     => NoPadStr,
    is      => 'rw',
    default => sub { q{} },
  );

  sub to_string {
    my ($self) = @_;
    my $dollar = q{$};

    # this is a bit messy to obfuscate the header string from CVS and friends.
    if ( $self->value ) {
      return sprintf q{%s%s: %s %s}, $dollar, $self->name, $self->value, $dollar;
    }
    else {
      return sprintf q{%s%s: %s}, $dollar, $self->name, $dollar;
    }
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;

}

1;
