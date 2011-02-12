use strict;
use warnings;

use Test::More 0.96;

use_ok('Gentoo::ChangeLog::Header');
use_ok('Gentoo::ChangeLog::Header::For');
use_ok('Gentoo::ChangeLog::Header::Copyright');



my $header = new_ok( 'Gentoo::ChangeLog::Header' => [  'my/package' ] , 'create an instance' );
my $year = [localtime]->[5] + 1900;
my $dollar = q{$};
my $hstring = 'Header: ';


is( $header->to_string() ."\n" , <<"EOF", 'header works' );
# ChangeLog for my/package
# Copyright 1999-${year} Gentoo Foundation; Distributed under the GPL v2
# ${dollar}${hstring}${dollar}
EOF

push @{ $header->copyright }, Gentoo::ChangeLog::Header::Copyright->new( holder => 'Kent Fredric' );

is( $header->to_string() ."\n" , <<"EOF", 'header works' );
# ChangeLog for my/package
# Copyright 1999-${year} Gentoo Foundation; Distributed under the GPL v2
# Copyright 1999-${year} Kent Fredric; Distributed under the GPL v2
# ${dollar}${hstring}${dollar}
EOF

push @{ $header->copyright }, Gentoo::ChangeLog::Header::Copyright->new( holder => 'Kent Fredric' , start => 2005 );

is( $header->to_string() ."\n" , <<"EOF", 'header works' );
# ChangeLog for my/package
# Copyright 1999-${year} Gentoo Foundation; Distributed under the GPL v2
# Copyright 1999-${year} Kent Fredric; Distributed under the GPL v2
# Copyright 2005-${year} Kent Fredric; Distributed under the GPL v2
# ${dollar}${hstring}${dollar}
EOF

push @{ $header->comments }, 'This is a test ChangeLog that is for testing', 'really. Its serious.';

is( $header->to_string() ."\n" , <<"EOF", 'header works' );
# ChangeLog for my/package
# Copyright 1999-${year} Gentoo Foundation; Distributed under the GPL v2
# Copyright 1999-${year} Kent Fredric; Distributed under the GPL v2
# Copyright 2005-${year} Kent Fredric; Distributed under the GPL v2
# ${dollar}${hstring}${dollar}
# This is a test ChangeLog that is for testing
# really. Its serious.
EOF

done_testing;

