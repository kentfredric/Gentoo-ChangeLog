#
#===============================================================================
#
use strict;
use warnings;

use Test::More 0.96;

use_ok('Gentoo::ChangeLog::Header::For');

my $header = new_ok( 'Gentoo::ChangeLog::Header::For' => [ package => 'my/package' ] , 'create an instance' );

is( $header->to_string(),
    'ChangeLog for my/package', 'header works' );


done_testing;

