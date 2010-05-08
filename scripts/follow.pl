#!perl
use strict;
use Net::Plurk;
use Env;
my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
my $user = $PLURKUSER // 'nobody';
my $pass = $PLURKPASS // 'nopass';
my $p = Net::Plurk->new(api_key => $api_key);
$p->login(user => $user, pass => $pass );
my $profile = $p->get_public_profile ( 'clsung' );
my $user_info = $profile->{user_info};
warn $p->follow($user_info->id);
warn $p->api_errormsg if $p->api_errormsg;
