use strict;
use warnings;

package Gentoo::ChangeLog::Parser;

# ABSTRACT: Linewise Parser for ChangeLogs
{
  use Moose;
  use MooseX::StrictConstructor;
  use MooseX::Types::Moose qw( :all );
  use namespace::clean -except => 'meta';

  #  has '_state' => (
  #    isa     => Object,
  #    is      => 'rw',
  #    default => sub {
  #      Gentoo::ChangeLog::Parser::State->new();
  #    }
  #  );

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
  has 'changelog_for'     => ( _pushable( '_changelog_for_lines',    '_append_changelog_for' ) );
  has 'copyright'         => ( _pushable( '_copyright_lines',        '_append_copyright' ) );
  has 'cvs_header'        => ( _pushable( '_cvs_header_lines',       '_append_cvs_header' ) );
  has 'comment'           => ( _pushable( '_comment_lines',          '_append_comment' ) );

  sub extract_changelog_for {
    my ( $self, $line, $lineno ) = @_;
    if ( $line =~ /^\s*#\s*ChangeLog\s+for\s+([^\s]+)\s*$/i ) {
      $self->_append_changelog_for(
        {
          line    => $line,
          line_no => $lineno,
          for     => "$1",
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
          line    => $line,
          line_no => $lineno,
          start   => "$1",
          stop    => "$2",
          owner   => "$3",
          license => $5 ? "$5" : "",
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
          line    => $line,
          line_no => $lineno,
          content => "",
        }
      );
      return 1;
    }
    if ( $line =~ /^\s*#\s*\$Header:\s+([^\s].*)\s+\$\s*$/ ) {
      $self->_append_cvs_header(
        {
          line    => $line,
          line_no => $lineno,
          content => "$1",
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
    my $comment = "$1";
    return 1 if $self->extract_changelog_for( $line, $lineno );
    return 1 if $self->extract_copyright( $line, $lineno );
    return 1 if $self->extract_header( $line, $lineno );
    $self->_append_comment(
      {
        line    => $line,
        line_no => $lineno,
        comment => $comment
      }
    );
  }

  sub parse_lines {

    my ( $self, @lines ) = @_;
    for my $lineno ( 0 .. $#lines ) {
      $self->extract_comment( $lines[$lineno], $lineno );
    }
  }

  __PACKAGE__->meta->make_immutable;
  no Moose;
}

1;

#package Gentoo::ChangeLog::Parser::State;

#use Moose;

