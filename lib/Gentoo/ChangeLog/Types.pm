
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

=type ChangeLogEntry

=cut

  role_type ChangeLogEntry, { role => 'Gentoo::ChangeLog::Role::Entry' };

=type ChangeLogHeader

=cut

  class_type ChangeLogHeader, { class => 'Gentoo::ChangeLog::Header' };

=type ChangeLogHeaderFor

=cut

  class_type ChangeLogHeaderFor, { class => 'Gentoo::ChangeLog::Header::For' };

=type ChangeLogHeaderCopyright

=cut

  class_type ChangeLogHeaderCopyright, { class => 'Gentoo::ChangeLog::Header::Copyright' };

=type ChangeLogHeaderCVSHeader

=cut

  class_type ChangeLogHeaderCVSHeader, { class => 'Gentoo::ChangeLog::Header::CVSHeader' };

=type OneLineStr

=cut

  subtype OneLineStr, as Str, where { $_ !~ /[\n\r]/ }, message { q{OneLineStr contains Line Feed Mechanisms} };

=type NoPadStr

=cut

  subtype NoPadStr, as OneLineStr, where {
    $_ !~ /^\s+/m && $_ !~ /\s+$/m;
  }, message { q{NoPadStr says you may not have any leading or tailing whitespace} };

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

