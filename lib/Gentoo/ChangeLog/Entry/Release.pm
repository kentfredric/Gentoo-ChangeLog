
use strict;
use warnings;

package Gentoo::ChangeLog::Entry::Release;

# ABSTRACT: A Release entry.

{
    use Moose;
    extends 'Gentoo::ChangeLog::Entry::Basic';

    around 'lines' => sub {
        my ( $orig, $self ) = ( shift(@_), shift(@_) );
        my @out = $self->$orig( @_ );
        my @prepends;


        for my $file ( grep { /.ebuild/ } @{ $self->added_files } ) {
            $file =~ s/\.ebuild$//;
            push @prepends, sprintf "* %s (%s)", $file , $self->date_stamp ;
        }
        push @prepends, "", @out;
        return @prepends;
    };
}

1;
