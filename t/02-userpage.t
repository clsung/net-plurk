#!perl -T

use Test::More tests => 2;

BEGIN {
	use Net::Plurk;
        my $p = Net::Plurk->new();
        $p->set(url => 'http://www.plurk.com/user/clsung' );
        $p->get();
        like($p->get_title(), qr'Cheng-Lung Sung', 'get my page?');
        cmp_ok($p->get_karma(user => 'clsung'), '>=', 80 , 'my karma should >= 80');
}

diag( "Testing Net::Plurk Check user page" );
