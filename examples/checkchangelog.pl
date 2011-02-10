#!/usr/bin/perl

use strict;
use warnings;

use Gentoo::Overlay;
use Gentoo::ChangeLog::Parser::WithProblems;

use File::Slurp qw( slurp );

my $overlay = Gentoo::Overlay->new( path => '/var/paludis/repositories/perl-git' );
#my $overlay = Gentoo::Overlay->new( path => '/usr/portage' );

my %categories = $overlay->categories();
$|++;

my $amt = scalar keys %categories;
my $px  = 0;

use Data::Dump qw( dump );

for my $c ( sort keys %categories ) {
  my $category = $categories{$c};

  my %packages = $category->packages();

  my $py = scalar keys %packages;

  #    print "\n\e[33m$c ( $px / $amt : $py )\n";
  $px++;

  for my $p ( sort keys %packages ) {

    my $path = $packages{$p}->path;
    my $pre  = $packages{$p}->pretty_name;

    if ( !-e "$path/ChangeLog" ) {
      print "$pre does not have a ChangeLog!\n";
      next;

    }
    my @lines = slurp("$path/ChangeLog");
    chomp for @lines;
    $pre =~ s/::.*$//;

    my $parser = Gentoo::ChangeLog::Parser::WithProblems->new(
        package_name => $pre,
    );

   $parser->parse_lines(@lines);
   if( $parser->_problems_list ){
        dump { $pre => $parser->problems };
#        dump $parser;
    } else {
        #print "[PASS] $pre\n";
    }
    next;

=begin comment
    my $rec = {
      for  => $pre,
      data => $parser,
    };

    $pre =~ s/::.*$//;

    if ( $parser->_comment_lines > 0 ) {
#      push @{$rec->{problems} } , 'has_comments';
    }
    if ( $parser->_copyright_lines != 1 ) {
      push @{$rec->{problems} }, '!=1 copright';
      print "$pre : Multiple copyrigthts
    }
    if ( $parser->_changelog_for_lines != 1 ) {

      for ( $parser->_changelog_for_lines ){
          next if $_->{line_no} == 0;
          print "$pre redundant 'ChangeLog for ' at line " . $_->{line_no} . "\n";
      }
      push @{$rec->{problems} }, '!=1 Changelog for';
    }
    for my $recitem ( $parser->_changelog_for_lines ) {
      next if $recitem->{line_no} != 0;
      my $for = $recitem->{for};

      if ( $pre !~ /^\Q$for\E/ ) {

        print "$pre incorrect 'ChangeLog for ' at line 0 $for instead of $pre\n";
        push @{$rec->{problems}},  'changelog != package',
      }
    }

    if( exists $rec->{problems} ){
        #  dump $rec;
    }

    next;

=end

=cut

  }

}
