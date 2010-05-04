#!perl -T

use Test::More tests => 3;
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
        is(1, $p->is_logged_in());
        cmp_ok ($p->karma(), '>', 0, 'Check self karma');
        cmp_ok ($p->karma(user => 'cwyuni'), '>', 80, 'Check cwyuni karma');
}

diag( "Testing Net::Plurk Check user karma" );
