use strict;
use warnings;

package Gentoo::ChangeLog::Header::Copyright;

# ABSTRACT: A "Copyright" element in a ChangeLog header.

{

=head1 SYNOPSIS

This object represents the "Copyright" part of a ChangeLogs header.


    my $object = Gentoo::Changelog->parse('/path/to/file');

    for( @{$object->header->copyright }){
        if ( $_->holder eq 'Gentoo Foundation' ){
            $_->update();
        }
    }
    $object->write( '/path/to/file');

Mostly you'll not need to interact with this element directly, but its here
for advanced users.

=cut

  use Moose;
  use MooseX::StrictConstructor;
  use MooseX::Types::Moose qw( :all );
  use Gentoo::ChangeLog::Types qw( :all );

  use Readonly;

  use namespace::clean -except => 'meta';

  Readonly my $DEFAULT_START_DATE   => 1999;
  Readonly my $EPOCH_OFFSET         => 1900;
  Readonly my $LOCALTIME_YEAR_FIELD => 5;

=attr start

Copyright statements in Gentoo are in 2 halves, left hand being the starting date
of the project, and the right half being the date of the last modification.

Generally, the left hand side is '1999', the date of the start of the Gentoo project,
under which all Ebuilds and Changelog files are implementations of a concept Copyrighted
to the Gentoo project.

=head3 Specification : Int, rw, default => 1999

=head3 Construction ( optional )

    my $object = ...->new( start => 2001 ... );

=head3 Reading

    my $copystart = $object->start();
    print "(C) $copystart - 2011\n";

=head3 Setting

    $object->start( 1999 );

=head3 Default

    1999

=head3 See Also

=over 4

=item L</stop> - The corresponding other half.

=back

=cut

  has 'start' => (
    isa     => Int,
    is      => 'rw',
    default => sub { $DEFAULT_START_DATE },
  );

=attr stop

See L</start>.

This is the right hand field of that copyright, intended to be updated every time a file bearing
this copyright is updated.

=head3 Specification : Int, rw, default => current year.

=head3 Construction ( optional )

    my $object = ...->new( stop => 2011 ... );

=head3 Reading

    my $copyend = $object->stop()
    print "(C) 1999 - $copyend\n";

=head3 Setting

    $object->stop( 2011 );

=head3 Default

The current Year. ( from 'localtime' )

=head3 See Also

=over 4

=item L</start> - The left hand half of this copyright.

=item L</update> - A more practical dwim interface to this field.

=back

=cut

  has 'stop' => (
    isa     => Int,
    is      => 'rw',
    default => sub { [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET },
  );

=attr holder

This field is for containing the Legal Copyright holder to be stored with this copyright entry.

=head3 Specification : Str, rw, default => Gentoo Foundation

=head3 Construction ( optional )

    my $object = ...->new( holder => 'Bob Smith', ... );

=head3 Reading

    my $holder = $object->holder()
    print "(C) 1999 - 2005 $holder\n";

=head3 Setting

    $object->holder('Example Company LLC');

=head3 See Also

=over 4

=item L</license> - The license specified by this Copyright holder.

=back

=cut

  has 'holder' => (
    isa     => NoPadStr,
    is      => 'rw',
    default => sub { 'Gentoo Foundation' },
  );

=attr license

This field is a short description of the license under which the file falls.

=head3 Specification : Str | Undef , rw, default => GPL2

=head3 Construction ( optional )

     my $object = ...->new( license => 'Distributed under ... ', ... );

=head3 Reading

    my $license = $object->license()
    print "(C) 1999 - 2005 Bob.org; $license\n";

=head3 Setting

    $object->license('This is unlicensed and you may not use it!');

=head3 Default

    Distributed under the GPL v2

=head3 See Also

=over 4

=item L</holder> - The holder of this license.

=back

=cut

  has 'license' => (
    isa     => Maybe[ NoPadStr ],
    is      => 'rw',
    default => sub { 'Distributed under the GPL v2' },
  );

=method update

This is a convenience method for updating the copyright on a changelog's copyright entry.

=head3 Specification : $object->update()

This form updates the copyright end date to reflect the current year of the local machine ( using localtime );

=head4 Example

    $object->update( 1969 );
    $object->update() # Copyright is no longer 1969, but instead something more recent like 2011

=head3 Specification : $object->update( $year )

This form updates the copyright end date to reflect the specified year.

Note we do no checks at present to make sure the end date is after the start date.

=head4 Example

    $object->updatet()
    $object->update( 1969 ) # Copyright end date is now 1969.

=cut

  sub update {
    my ( $self, $year ) = @_;
    $year ||= [localtime]->[$LOCALTIME_YEAR_FIELD] + $EPOCH_OFFSET;
    $self->stop($year);
    return $self;
  }

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
    my ($self) = @_;
    my $license = q{};
    $license = q{; } . $self->license if $self->license;
    return sprintf q{Copyright %s-%s %s%s}, $self->start, $self->stop, $self->holder, $license;
  }

  __PACKAGE__->meta->make_immutable;

  no Moose;
}

1;
