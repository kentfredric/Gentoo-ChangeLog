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

  has 'changelog_for' => (
    isa      => class_type('Gentoo::ChangeLog::Header::For'),
    is       => 'rw',
    required => 1,
  );

  has 'copyright' => (
    isa => ArrayRef [ class_type('Gentoo::ChangeLog::Header::Copyright') ],
    is => 'rw',
    default => sub {
      [ Gentoo::ChangeLog::Header::Copyright->new() ];
    },
  );

  has 'cvs_headers' => (
    isa => ArrayRef [ class_type('Gentoo::ChangeLog::Header::CVSHeader') ],
    is => 'rw',
    default => sub {
      [ Gentoo::ChangeLog::Header::CVSHeader->new() ];
    },
  );

  has 'comments' => (
    isa => ArrayRef [Str],
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

  sub to_string {
    my $self = shift;
    my @lines;

    push @lines, split /\n/, $self->changelog_for->to_string;
    push @lines, split /\n/, $_->to_string for @{ $self->copyright };
    push @lines, split /\n/, $_->to_string for @{ $self->cvs_headers };
    push @lines, split /\n/, $_ for @{ $self->comments };
    # trim tailing whitespace
    my $output = ( join "\n", map { '# ' . $_ }  @lines ) . "\n";
    $output =~ s/\s*$//mg;
    return $output;
  }

  __PACKAGE__->meta->make_immutable;

  no Moose;
}
1;
