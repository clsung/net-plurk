#!perl -T

use Test::More tests => 6;
use Env qw(PLURKAPIKEY PLURKUSER PLURKPASS);

BEGIN {
	use Net::Plurk;
        my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
        my $user = $PLURKUSER // 'nobody';
        my $pass = $PLURKPASS // 'nopass';
        my $p = Net::Plurk->new(api_key => $api_key);
        my $profile = $p->login(user => $user, pass => $pass );
        is($p->is_logged_in(), 1);
        my $json = $p->api( path => '/Polling/getUnreadCount');
        isa_ok ($json, HASH);
        cmp_ok( $json->{all}, '>=', 0);
        cmp_ok( $json->{my}, '>=', 0);
        cmp_ok( $json->{private}, '>=', 0);
        cmp_ok( $json->{responded}, '>=', 0);
}

diag( "Testing Net::Plurk Check user page" );
