use strict;
use warnings;

package Gentoo::ChangeLog::Parser;

# ABSTRACT: Linewise Parser for ChangeLogs
{
  use Moose;
  use MooseX::StrictConstructor;
  use MooseX::Types::Moose qw( :all );
  use namespace::clean -except => 'meta';

  sub _pushable {
    return (
      isa => ArrayRef [ HashRef [Str] ],
      is => 'rw',
      default => sub { [] },
      traits  => [qw( Array )],
      handles => {
        $_[0] => 'elements',
        $_[1] => 'push',
      }
    );

  }
  has 'changelog_for' => ( _pushable( '_changelog_for_lines', '_append_changelog_for' ) );
  has 'copyright'     => ( _pushable( '_copyright_lines',     '_append_copyright' ) );
  has 'cvs_header'    => ( _pushable( '_cvs_header_lines',    '_append_cvs_header' ) );
  has 'comment'       => ( _pushable( '_comment_lines',       '_append_comment' ) );
  has 'unknown'       => ( _pushable( '_unknown_lines',       '_append_unknown' ) );
  has 'releases'      => ( _pushable( '_releases_lines',      '_append_release' ) );

  has 'location' => ( isa => Str, is => 'rw', default => sub { 'pre-file' } );
  has 'last_release' => ( isa => HashRef [Str], is => 'rw', default => sub { {} } );

  before _append_release => sub {
    my ( $self, $hash ) = @_;
    $self->last_release($hash);
  };

  sub extract_changelog_for {
    my ( $self, $line, $lineno ) = @_;
    if ( $line =~ /^\s*#\s*ChangeLog\s+for\s+([^\s]+)\s*$/i ) {
      $self->_append_changelog_for(
        {
          line     => $line,
          line_no  => $lineno,
          for      => "$1",
          location => $self->location,
        }
      );
      return 1;
    }
    return 0;
  }

  sub extract_copyright {
    my ( $self, $line, $lineno ) = @_;
    if ( $line =~ /^\s*#\s*Copyright\s+(\d\d\d\d)-(\d\d\d\d)\s+([^;]+)(;\s*(.*)|)$/ ) {
      $self->_append_copyright(
        {
          line     => $line,
          line_no  => $lineno,
          start    => "$1",
          stop     => "$2",
          owner    => "$3",
          license  => $5 ? "$5" : "",
          location => $self->location,
        }
      );
      return 1;
    }
    return;
  }

  sub extract_header {
    my ( $self, $line, $lineno ) = @_;
    if ( $line =~ /^\s*#\s*\$Header:\s+\$\s*$/ ) {
      $self->_append_cvs_header(
        {
          line     => $line,
          line_no  => $lineno,
          content  => "",
          location => $self->location,
        }
      );
      return 1;
    }
    if ( $line =~ /^\s*#\s*\$Header:\s+([^\s].*)\s+\$\s*$/ ) {
      $self->_append_cvs_header(
        {
          line     => $line,
          line_no  => $lineno,
          content  => "$1",
          location => $self->location,
        }
      );
      return 1;
    }
    return;
  }

  sub extract_comment {
    my ( $self, $line, $lineno ) = @_;
    if ( $line !~ /^\s{0,1}#\s*(.*$)/ ) {
      return;
    }
    if ( $self->is_location('pre-file') ) {
      $self->location('header');
    }
    my $comment = "$1";
    return 1 if $self->extract_changelog_for( $line, $lineno );
    return 1 if $self->extract_copyright( $line, $lineno );
    return 1 if $self->extract_header( $line, $lineno );
    $self->_append_comment(
      {
        line     => $line,
        line_no  => $lineno,
        comment  => $comment,
        location => $self->location,
      }
    );
    return 1;
  }

  sub extract_release {
    my ( $self, $line, $lineno ) = @_;
    if ( $line !~ /^\s{0,1}\*\s{0,1}(.*$)/ ) {
      return;
    }
    my $release_message = "$1";
    my $release_of;
    my $release_stamp;
    if ( $release_message =~ /^(\S+)(\s+(.*$)|)$/ ) {
      $release_of = "$1";
      $release_stamp = $3 ? "$3" : "";
    }
    $self->_append_release(
      {
        line        => $line,
        line_no     => $lineno,
        released    => $release_of,
        released_at => $release_stamp,
        location    => $self->location,
      }
    );
    $self->location('pre-release');
    return 1;

  }

  sub empty_line {
    my ( $self, $line, $lineno ) = @_;
    return 1 if $line =~ /^\s*/;
    return;
  }

  sub _location_valid {
    my ($location) = shift;
    my (%locations) = map { $_ => 1 } qw(
      header body pre-release change-header entry pre-file
    );
    if ( not exists $locations{$location} ) {
      die "bad location $location";
    }
    return $location;
  }

  sub is_location {
    my ( $self, $location ) = @_;
    return _location_valid( $self->location ) eq _location_valid($location);
  }

  sub extact_change_header {
    my ( $self, $line, $lineno ) = @_;
    return if ( $line !~ /^(  |\t)(.*$)/ );
    return if not $2;
    my $content = "$2";
    return;

    #      return if not $content =~ /^\d{1,2}\s+[A-Z][a-z]{2}\s+\d{4}/;

  }

  sub parse_lines {

    my ( $self, @lines ) = @_;
    for my $lineno ( 0 .. $#lines ) {
      next if $self->extract_comment( $lines[$lineno], $lineno );
      $self->location('body') if $self->is_location( header => );
      next if $self->extract_release( $lines[$lineno], $lineno );
      next if $self->is_location('pre-release') and $self->empty_line( $lines[$lineno], $lineno );

      next;
      next
        if not $self->is_location('change-header')
          and not $self->is_location('entry')
          and $self->extract_change_header( $lines[$lineno], $lineno );

      next
        if $self->is_location('change-header')
          and $self->extract_more_change_header( $lines[$lineno], $lineno );

      #      $self->_append_unknown(
      #        {
      #          line     => $lines[$lineno],
      #          line_no  => $lineno,
      #          location => $self->location,
      #        }
      #      );
    }
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;
}

1;

