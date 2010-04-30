#!perl -T

use Test::More tests => 3;

BEGIN {
	use Net::Plurk;
	use Net::Plurk::UserProfile;
	use Net::Plurk::User;
        my $api_key = "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
        $api_key = "zSMyCLZGexhtwivAfd0ta4t4rlzhtGGl";
        my $p = Net::Plurk->new(api_key => $api_key);
        #my $profile = $p->login(user => 'nobody', pass => 'nobody' );
        my $profile = $p->login(user => 'clsung', pass => '10524' );
        isa_ok ($profile, Net::Plurk::UserProfile);
        is(1, $p->is_logged_in());
        isa_ok ($profile->user_info, Net::Plurk::User);
}

diag( "Testing Net::Plurk Check user page" );
