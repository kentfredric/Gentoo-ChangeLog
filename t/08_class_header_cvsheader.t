use strict;
use warnings;

use Test::More 0.96;

use_ok('Gentoo::ChangeLog::Header::CVSHeader');

my $header = new_ok( 'Gentoo::ChangeLog::Header::CVSHeader' => [], 'create an instance' );

is( $header->to_string(), q{$} . ucfirst(q{header: }) . q{$}, 'header works' );

$header = new_ok( 'Gentoo::ChangeLog::Header::CVSHeader' => [ name => 'Id' ], 'create an instance' );

is( $header->to_string(), q{$} . ucfirst(q{id: }) . q{$}, 'header works' );

$header = new_ok( 'Gentoo::ChangeLog::Header::CVSHeader' => [ name => 'Id', value => 'Foobarbaz' ], 'create an instance' );

is( $header->to_string(), q{$} . ucfirst(q{id: Foobarbaz }) . q{$}, 'header works' );

done_testing;

