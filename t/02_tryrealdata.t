use strict;
use warnings;

use Test::More 0.96;
use utf8;
use Gentoo::ChangeLog::Object;
use Gentoo::ChangeLog::Entry::Basic;

my $object = Gentoo::ChangeLog::Object->new(
  changelog_for      => 'dev-lang/perl',
  copyright_ending   => '2011',
  copyright_starting => '1999',
  header_string      => '/var/cvsroot/gentoo-x86/dev-lang/perl/ChangeLog,v 1.359 2011/01/22 11:19:07 armin76 Exp'
);

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name  => 'Torsten Veller',
    author_email => 'tove@gentoo.org',
    added_files  => [qw( perl-5.10.1.ebuild )],
    message      => 'Version bump',
    date_stamp   => '27 Sep 2009',
  )
);

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name  => 'Torsten Veller',
    author_email => 'tove@gentoo.org',

    #        added_files => [qw( perl-5.10.1.ebuild )],
    modified_files => [qw( perl-5.8.8-r5.ebuild perl-5.8.8-r6.ebuild perl-5.10.1.ebuild )],
    message        => "Bump perl-5.10.1 patchset.\n"
      . "Fix asm/page.h failure. Thanks to Alon Bar-Lev and Diego Pettenò.\n"
      . "(#259923, #286656, #249827, #265268)\n",
    date_stamp => '27 Sep 2009',
    )

);
diag( $object->stringify );

