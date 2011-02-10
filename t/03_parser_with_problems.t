
use strict;
use warnings;

use Test::More 0.96;

use Path::Class qw( file );
use FindBin;

my $corpus = file($FindBin::Bin)->parent->subdir("corpus");
my $parse  = $corpus->subdir('parse');

use Gentoo::ChangeLog::Parser::WithProblems;

my %testmap = (
  '01_basic'               => [],
  '02_no_changelog_for'    => [ { problem => "No \"Changelog For\" declaration" } ],
  '03_no_copyright'        => [ { problem => "No \"Copyright\" declaration" } ],
  '04_wrong_changelog_for' => [
    {
      problem    => "\"Changelog for\" package name doesn\'t match package",
      problem_at => 0,
      got        => 'dev-example/meta-example',
      expected   => 'dev-example/example',
    }
  ],
  '05_wrong_copyright' => [
    {
      'problem'    => 'Copyright is not to Gentoo Foundation',
      'problem_at' => 1,
      'owner'      => 'Kent Fredric',
    }
  ],
  '06_no_cvs_header'            => [ { problem => 'No CVS Header' } ],
  '07_wrong_line_changelog_for' => [ { problem => '"Changelog for" comment not on line 0', problem_at => 4 } ],
  '08_duplicate_changelog_for' => [
    {
      'problem'    => '"Changelog for" comment not on line 0',
      'problem_at' => 3,
    },
    { 'problem' => "Multiple \"Changelog For\" declarations", },
  ],
);

for my $file ( sort keys %testmap ) {

  my @content = $parse->file($file)->slurp( chomp => 1 );

  my $instance = Gentoo::ChangeLog::Parser::WithProblems->new( package_name => 'dev-example/example', );

  $instance->parse_lines(@content);

  is_deeply( $instance->problems, $testmap{$file}, "source file $file has expected problems" ) or do {
    note explain {
      instance => $instance,
      problems => $instance->problems,
      expected => $testmap{$file}
    };
  };
}

done_testing;

