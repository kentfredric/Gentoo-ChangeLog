
use strict;
use warnings;

package Gentoo::ChangeLog::Parser::WithProblems;

# ABSTRACT: Parse and report possible errors in ChangeLogs

{
  use Moose;
  extends 'Gentoo::ChangeLog::Parser';
  use MooseX::Types::Moose qw( :all );

  has 'problems' => (
    isa => ArrayRef [ HashRef [Str] ],
    is => 'rw',
    default => sub { [] },
    traits  => [qw( Array )],
    handles => {
      '_problems_list'  => 'elements',
      '_append_problem' => 'push',
    }
  );
  has 'package_name' => ( isa => Str, is => 'rw', required => 1 );

  before '_append_changelog_for' => sub {
    my ( $self, @args ) = @_;
    if ( $args[0]->{'line_no'} != 0 ) {
      $self->_append_problem(
        {
          problem    => '"Changelog for" comment not on line 0',
          problem_at => $args[0]->{'line_no'}
        }
      );
    }
    if ( $args[0]->{for} ne $self->package_name ) {
      $self->_append_problem(
        {
          problem    => '"Changelog for" package name doesn\'t match package',
          expected   => $self->package_name,
          got        => $args[0]->{for},
          problem_at => $args[0]->{line_no},
        }
      );
    }
  };

  before '_append_copyright' => sub {
    my ( $self, @args ) = @_;

    if ( $args[0]->{'line_no'} != 1 ) {
      $self->_append_problem(
        {
          problem    => 'Copyright comment not on line 1',
          problem_at => $args[0]->{'line_no'}
        }
      );
    }
    if ( $args[0]->{'owner'} ne 'Gentoo Foundation' ) {
      $self->_append_problem(
        {
          problem    => 'Copyright is not to Gentoo Foundation',
          problem_at => $args[0]->{'line_no'},
          owner      => $args[0]->{'owner'},
        }
      );
    }
    if( $args[0]->{'license'} eq q{} ){
      $self->_append_problem(
        {
          problem    => 'License is empty',
          problem_at => $args[0]->{'line_no'},
        }
      );
    } elsif( $args[0]->{'license'} ne q{Distributed under the GPL v2} ){
      $self->_append_problem(
        {
          problem    => 'License is not the standard GPL v2 License',
          problem_at => $args[0]->{'line_no'},
          license => $args[0]->{'license'},
        }
      );
    }

  };

  before '_append_cvs_header' => sub {
    my ( $self, @args ) = @_;

    if ( $args[0]->{'line_no'} != 2 ) {
      $self->_append_problem(
        {
          problem    => 'CVS Header comment not on line 2',
          problem_at => $args[0]->{'line_no'}
        }
      );
    }
  };

  sub _extra_problems {
    my ($self) = @_;
    my @problems;

    if ( $self->_changelog_for_lines < 1 ) {
      push @problems, { problem => 'No "Changelog For" declaration' };
    }
    if ( $self->_changelog_for_lines > 1 ) {
      push @problems, { problem => 'Multiple "Changelog For" declarations' };
    }

    if ( $self->_copyright_lines < 1 ) {
      push @problems, { problem => 'No "Copyright" declaration' };
    }
    if ( $self->_copyright_lines > 1 ) {
      push @problems, { problem => 'Multiple "Copyright" declarations' };
    }

    if ( $self->_cvs_header_lines < 1 ) {
      push @problems, { problem => 'No CVS Header' };
    }
    if ( $self->_copyright_lines > 1 ) {
      push @problems, { problem => 'Multiple CVS headers declarations' };
    }

    return @problems;
  }

  around 'problems' => sub {
    my ( $orig, $self, @args ) = @_;
    my $output = [ @{ $self->$orig(@args) } ];
    push @$output, $self->_extra_problems;
    return $output;
  };
  around '_problems_list' => sub {
    my ( $orig, $self, @args ) = @_;
    my (@output) = ( $self->$orig(@args) );
    push @output, $self->_extra_problems;
    return @output;
  };

  __PACKAGE__->meta->make_immutable;
}

