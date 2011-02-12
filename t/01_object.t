use strict;
use warnings;

use Test::More 0.96;
use Gentoo::ChangeLog::Object;
use Gentoo::ChangeLog::Header;

use Gentoo::ChangeLog::Entry::Basic;

my $object = Gentoo::ChangeLog::Object->new( header => Gentoo::ChangeLog::Header->new('dev-perl/Example') );

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name  => 'Kent Fredric',
    author_email => 'kentnl@cpan.org',
    message      => 'Example',

    #        date_stamp => '01 Jan 2011',
  )
);

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name    => 'Kent Fredric',
    author_email   => 'kentnl@cpan.org',
    message        => 'Example',
    added_files    => [ map { $_ . '.ad' } qw( a b c d e f g h i j k l m n ) ],
    removed_files  => [ map { $_ . '.rm' } qw( a b c d e f g h i j k l m n ) ],
    modified_files => [ map { $_ . '.mod' } qw( a b c d e f g h i j k l m n ) ],
    date_stamp     => '02 Jan 2011',
  )
);

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name  => 'Kent Fredric',
    author_email => 'kentnl@cpan.org',
    message      => 'This is a long message ' x 20,
    date_stamp   => '03 Jan 2011',
  )
);
my $longmessage = <<'EOF';
This is my long message but it has pre-existing and strange formatting to see how
things handle it.

I expect to see:

    * Non-stupidly long lines treated with respect
    * Manual line-breaks preserved when its obvious they're manual
    * No stupid 1-word-but-not-at-tne-end lines.
    * Bulletpoint continuations that work, like this onezeseser buzisahde asd asd asd asd asd asd asd asd asd asd asd
      this one.
      Hello.
      I am an idiot.

      this is a continuation too.
    * Bullet.
    * Very long urls such as http://www.google.com/search?q=asdasd+ASDAAAAAAAAASDDSDSDSDSDSDSDSD+asd+asd+asd+asd3245 not broken.




Kthx =)
EOF

#use Text::Autoformat;
#
#diag( autoformat( $longmessage, { squeeze => 1, all => 1, widow => 0, justify => 'left', tabspace => 2 } ) );

$object->insert(
  Gentoo::ChangeLog::Entry::Basic->new(
    author_name  => 'Kent Fredric',
    author_email => 'kentnl@cpan.org',
    message      => $longmessage,
    date_stamp   => '04 Jan 2011',
  )
);

for ( @{ $object->header->copyright } ) {
  $_->update(1969);
}

my @lines = $object->arify;

is( $lines[0], '# ChangeLog for dev-perl/Example',                                      'Changelog header name is right' );
is( $lines[1], '# Copyright 1999-1969 Gentoo Foundation; Distributed under the GPL v2', "copyright is right" );
is( $lines[2], '# $' . 'Header' . ':' . ' ' . '$',                                      'CVS header is right' );
like( ( join "\n", @lines ), qr{http://[^\n]+3245}, "URL is unbroken" );
done_testing;

