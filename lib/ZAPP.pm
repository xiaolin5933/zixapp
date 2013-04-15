package ZAPP;
use strict;
use warnings;

use constant {
    DEBUG => $ENV{ZAPP_DEBUG} || 0,
};

BEGIN {
    require Data::Dump if DEBUG;
}

sub new {
}

sub _init {
}

1;

