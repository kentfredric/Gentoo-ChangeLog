use strict;
use warnings;

use Test::More 0.96;
use utf8;
use Gentoo::ChangeLog::Object;
use Gentoo::ChangeLog::Header;
use Gentoo::ChangeLog::Entry::Basic;

my $object = Gentoo::ChangeLog::Object->new(
  header => Gentoo::ChangeLog::Header->new(
    changelog_for => Gentoo::ChangeLog::Header::For->new( package => 'dev-lang/perl' ),
    copyright   => [ Gentoo::ChangeLog::Header::Copyright->new( start => 1999, stop => 2011 ) ],
    cvs_headers => [
      Gentoo::ChangeLog::Header::CVSHeader->new(
        value => '/var/cvsroot/gentoo-x86/dev-lang/perl/ChangeLog,v 1.359 2011/01/22 11:19:07 armin76 Exp'
      ),
    ],
  )
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

pass("Basic useage works");
done_testing;
