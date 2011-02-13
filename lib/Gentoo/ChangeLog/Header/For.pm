
use strict;
use warnings;

package Gentoo::ChangeLog::Header::For;

# ABSTRACT: A Gentoo-Standard 'ChangeLog For' record.

{
  use Moose;
  use MooseX::Types::Moose qw( :all );
  use Gentoo::ChangeLog::Types qw( :all );

=attr package

What this current changelog is intended to index. Usually contains the ebuild C< cat/package > part.

=head3 Specification : Str, rw, required

=head3 Construction

    my $object = ...->new( package => 'dev-lang/perl' , ... );

=head3 Reading

    my $for = $object->package();

=head3 Setting

    $object->package("sys-devel/gcc");

=cut

  has 'package' => (
    isa      => NoPadStr,
    is       => 'rw',
    required => 1,
  );


=method to_string

This produces a full copyright header line in the Gentoo Perscribed form.

In the event L</license> is empty, the delimiting '; ' that seperates license and holder
will be omitted.

=head3 Specification : $result = $object->to_string()

=head3 Example

    my $object = ....->new( start => 1992 , stop => 1993, holder => "KENT", license => "ANY LICENSE" );
    print $object->to_string();

    # prints 'Copyright 1992-1993 KENT; ANY LICENSE'

=cut

  sub to_string {
    my ($self) = shift;
    return 'ChangeLog for ' . $self->package;
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;
}

1;

