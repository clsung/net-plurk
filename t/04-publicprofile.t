#!perl -T

use Test::More tests => 3;
use Env qw(PLURKAPIKEY);

BEGIN {
	use Net::Plurk;
	use Net::Plurk::UserProfile;
	use Net::Plurk::User;
        my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
        my $p = Net::Plurk->new(api_key => $api_key);
        $p->logout();
        is(0, $p->is_logged_in());
        my $profile = $p->get_public_profile ( 'clsung' );
        isa_ok ($profile, Net::Plurk::PublicUserProfile);
        isa_ok ($profile->user_info, Net::Plurk::User);
}

diag( "Testing Get Public User Profile" );
