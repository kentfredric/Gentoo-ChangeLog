
use strict;
use warnings;

package Gentoo::ChangeLog::Types;

# ABSTRACT: General Types for Gentoo Changelogs.

{

  use MooseX::Types -declare => [
    'ChangeLogEntry',     'ChangeLogHeader',          'OneLineStr', 'NoPadStr',
    'ChangeLogHeaderFor', 'ChangeLogHeaderCopyright', 'ChangeLogHeaderCVSHeader'
  ];
  use MooseX::Types::Moose qw( Object Str );
  use Gentoo::ChangeLog::Role::Entry;

  role_type ChangeLogEntry, { role => 'Gentoo::ChangeLog::Role::Entry' };

  class_type ChangeLogHeader, { class => 'Gentoo::ChangeLog::Header' };

  class_type ChangeLogHeaderFor, { class => 'Gentoo::ChangeLog::Header::For' };

  class_type ChangeLogHeaderCopyright, { class => 'Gentoo::ChangeLog::Header::Copyright' };

  class_type ChangeLogHeaderCVSHeader, { class => 'Gentoo::ChangeLog::Header::CVSHeader' };

  subtype OneLineStr, as Str, where { $_ !~ /[\n\r]/ }, message { "OneLineStr contains Line Feed Mechanisms" };

  subtype NoPadStr, as OneLineStr, where {
    $_ !~ /^\s+/m && $_ !~ /\s+$/m;
  }, message { "NoPadStr says you may not have any leading or tailing whitespace" };

  coerce NoPadStr, from Str, via {
    $_ =~ s/[\r\n]/ /mg;
    $_ =~ s/^\s+//gm;
    $_ =~ s/\s+$//gm;
    $_;
  };

  coerce OneLineStr, from Str, via {
    $_ =~ s/[\r\n]/ /mg;
    $_;
  };

}
1;

