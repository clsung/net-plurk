#!perl -T

use Test::More tests => 2;
use Env qw(PLURKAPIKEY PLURKUSER PLURKPASS);

BEGIN {
	use Net::Plurk;
	use Net::Plurk::UserProfile;
	use Net::Plurk::User;
        my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
        my $user = $PLURKUSER // 'nobody';
        my $pass = $PLURKPASS // 'nopass';
        my $p = Net::Plurk->new(api_key => $api_key);
        $p->login(user => $user, pass => $pass );
        is($p->is_logged_in(), 1);
        is($p->follow('clsung'), 1);
}

diag( "Testing Net::Plurk Check user page" );
