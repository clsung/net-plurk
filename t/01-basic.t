#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'Net::Plurk' );
        my $p = Net::Plurk->new();
        like($p->get(), qr'Plurk is a social journal for your life', 'default get homepage');
}

diag( "Testing Net::Plurk Basic Usage" );
