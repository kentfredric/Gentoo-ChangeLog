#!/usr/bin/perl

use strict;
use warnings;

use Gentoo::Overlay 0.03;
use Gentoo::ChangeLog::Parser::WithProblems;
use Moose::Autobox;
use Data::Dump qw( dump );
use File::Slurp qw( slurp );

my @overlays = qw(
  /var/paludis/repositories/perl-git
  /usr/portage
);

for my $overlay_path (@overlays) {
  Gentoo::Overlay->new( path => $overlay_path )->iterate(
    packages => sub {
      my ( $self, $config ) = @_;

      my $spec = $config->{category_name} . '/' . $config->{package_name};

      my $path = $config->{package}->path;

      my $prefix = sprintf "%4s/%4s %4s/%4s", $config->{category_num} + 1,
        $config->{num_categories}, $config->{package_num} + 1, $config->{num_packages};

      if ( !-e "$path/ChangeLog" ) {
        print "$prefix $spec does not have a ChangeLog!\n";
        return;
      }
      my @lines = slurp("$path/ChangeLog");
      chomp for @lines;

      my $parser = Gentoo::ChangeLog::Parser::WithProblems->new( package_name => $spec, );

      $parser->parse_lines(@lines);
      if ( $parser->_problems_list ) {
        dump { $spec => $parser->problems };

        #        dump $parser;
      }
      else {

        #print "[PASS] $pre\n";
      }

      #print "$prefix $spec\n";
    }
  );
}

