use strict;
use warnings;

package Gentoo::ChangeLog::Header;

{
  use Moose;
  use MooseX::StrictConstructor;

  use Gentoo::ChangeLog::Header::For;
  use Gentoo::ChangeLog::Header::Copyright;
  use Gentoo::ChangeLog::Header::CVSHeader;

  use Moose::Util::TypeConstraints qw( class_type );
  use MooseX::Types::Moose qw( ArrayRef Str );
  use Gentoo::ChangeLog::Types qw( :all );

  has 'changelog_for' => (
    isa      => ChangeLogHeaderFor,
    is       => 'rw',
    required => 1,
  );

  has 'copyright' => (
    isa => ArrayRef[ ChangeLogHeaderCopyright ],
    is => 'rw',
    default => sub {
      [ Gentoo::ChangeLog::Header::Copyright->new() ];
    },
  );

  has 'cvs_headers' => (
    isa => ArrayRef [ ChangeLogHeaderCVSHeader ],
    is => 'rw',
    default => sub {
      [ Gentoo::ChangeLog::Header::CVSHeader->new() ];
    },
  );

  has 'comments' => (
    isa => ArrayRef [NoPadStr],
    is => 'rw',
    default => sub { [] }
  );

  around BUILDARGS => sub {
    if ( @_ == 3 && !ref $_[2] ) {
      my ( $orig, $class, $value ) = @_;
      return $class->$orig( changelog_for => Gentoo::ChangeLog::Header::For->new( package => $value ) );
    }
    else {
      my ( $orig, $class ) = ( (shift), (shift) );
      return $class->$orig(@_);
    }
  };

  sub to_string_list {
    my $self = shift;
    my @lines;

    push @lines, $self->changelog_for->to_string;
    push @lines, $_->to_string for @{ $self->copyright };
    push @lines, $_->to_string for @{ $self->cvs_headers };
    push @lines, $_ for @{ $self->comments };

    return map {
      $_ =~ s/s\*$//;
      $_
    } map { "# " . $_ } @lines;

  }

  sub to_string {
    my $self = shift;
    return join qq{\n}, $self->to_string_list;
  }

  __PACKAGE__->meta->make_immutable;

  no Moose;
}
1;
