#
#===============================================================================
#
use strict;
use warnings;

use Test::More 0.96;

my $year = [localtime]->[5] + 1900;

use_ok('Gentoo::ChangeLog::Header::Copyright');

my $header = new_ok( 'Gentoo::ChangeLog::Header::Copyright' => [], 'create an instance' );

is( $header->to_string(), 'Copyright 1999-' . $year . ' Gentoo Foundation; Distributed under the GPL v2', 'header works' );

$header->update(1999);

is( $header->to_string(), 'Copyright 1999-1999 Gentoo Foundation; Distributed under the GPL v2', 'header updates' );

$header->update();

is(
  $header->to_string(),
  'Copyright 1999-' . $year . ' Gentoo Foundation; Distributed under the GPL v2',
  'header updates automatically'
);

$header = new_ok( 'Gentoo::ChangeLog::Header::Copyright' => [ start => 2005 ], 'create an instance' );

is( $header->to_string(), 'Copyright 2005-' . $year . ' Gentoo Foundation; Distributed under the GPL v2', 'header start' );

$header = new_ok( 'Gentoo::ChangeLog::Header::Copyright' => [ start => 2005, holder => 'Kent Fredric' ], 'create an instance' );

is( $header->to_string(), 'Copyright 2005-' . $year . ' Kent Fredric; Distributed under the GPL v2', 'header holder' );

$header = new_ok(
  'Gentoo::ChangeLog::Header::Copyright' => [ start => 2005, holder => 'Kent Fredric', license => 'GPLV3' ],
  'create an instance'
);

is( $header->to_string(), 'Copyright 2005-' . $year . ' Kent Fredric; GPLV3', 'header license' );

$header = new_ok(
  'Gentoo::ChangeLog::Header::Copyright' => [ start => 2005, holder => 'Kent Fredric', license => '' ],
  'create an instance'
);

is( $header->to_string(), 'Copyright 2005-' . $year . ' Kent Fredric', 'empty license' );

$header = new_ok(
  'Gentoo::ChangeLog::Header::Copyright' => [ start => 2005, holder => 'Kent Fredric', license => undef ],
  'create an instance'
);

is( $header->to_string(), 'Copyright 2005-' . $year . ' Kent Fredric', 'empty license' );

done_testing;

