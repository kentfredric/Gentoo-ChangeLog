
use strict;
use warnings;

package Gentoo::ChangeLog::Types;

# ABSTRACT: General Types for Gentoo Changelogs.

{

  use MooseX::Types -declare => [qw[ ChangeLogEntry ]];
  use MooseX::Types::Moose qw( Object );
  use Gentoo::ChangeLog::Role::Entry;

  subtype ChangeLogEntry, as Object, where { $_->DOES('Gentoo::ChangeLog::Role::Entry') };

}
1;

