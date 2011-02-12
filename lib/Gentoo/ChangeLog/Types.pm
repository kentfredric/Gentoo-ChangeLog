
use strict;
use warnings;

package Gentoo::ChangeLog::Types;

# ABSTRACT: General Types for Gentoo Changelogs.

{

  use MooseX::Types -declare => [qw[ ChangeLogEntry ChangeLogHeader ]];
  use MooseX::Types::Moose qw( Object );
  use Gentoo::ChangeLog::Role::Entry;

  role_type ChangeLogEntry,{ role => 'Gentoo::ChangeLog::Role::Entry' };

  class_type ChangeLogHeader, { class => 'Gentoo::ChangeLog::Header' };
}
1;

