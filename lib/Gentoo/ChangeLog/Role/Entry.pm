#

use strict;
use warnings;

package Gentoo::ChangeLog::Role::Entry;

# ABSTRACT: The Specification for Conforming Entry types.

{
  use Moose::Role;
  use namespace::clean -except => 'meta';

  requires qw(
    lines
    added_files
    removed_files
    modified_files
    date_stamp
    author_name
    author_email
    message
  );

  {
    ## no critic ( Subroutines::RequireArgUnpacking , Subroutines::RequireFinalReturn )
    sub adds_files { 0 < @{ $_[0]->added_files } }
  }

  {
    ## no critic ( Subroutines::RequireArgUnpacking , Subroutines::RequireFinalReturn )
    sub removes_files { 0 < @{ $_[0]->removed_files } }
  }

  {
    ## no critic ( Subroutines::RequireArgUnpacking , Subroutines::RequireFinalReturn )
    sub modifies_files { 0 < @{ $_[0]->modified_files } }
  }

  sub stringify {
    return join qq{\n}, shift->lines;
  }

  no Moose::Role;
}

1;
