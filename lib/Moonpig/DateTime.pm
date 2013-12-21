package Moonpig::DateTime;

use base 'DateTime::Moonpig';

sub TO_JSON { $_[0]->st }
sub STICK_PACK { $_[0]->st }

1;
