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
        my $profile = $p->login(user => $user, pass => $pass );
        isa_ok ($profile, Net::Plurk::UserProfile);
        is(1, $p->is_logged_in());
        isa_ok ($profile->user_info, Net::Plurk::User);
}

diag( "Testing Net::Plurk Check user page" );
