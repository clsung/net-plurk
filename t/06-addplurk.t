#!perl -T
use utf8;
use Test::More;
use Env qw(PLURKAPIKEY PLURKUSER PLURKPASS);

BEGIN {
	use Net::Plurk;
	use Net::Plurk::Plurk;
        use List::Util 'shuffle';
        my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
        my $user = $PLURKUSER // 'nobody';
        my $pass = $PLURKPASS // 'nopass';
        my @langs = shuffle ('en','pt_BR','cn','ca','el','dk','de','es','sv','nb','hi','ro','hr','fr','ru','it','ja','he','hu','ne','th','ta_fp','in','pl','ar','fi','tr_ch','tr','ga','sk','uk','fa');
        my $p = Net::Plurk->new(api_key => $api_key);
        $p->login(user => $user, pass => $pass );
        is(1, $p->is_logged_in());
        my $plurk_msg =  eval {
            use HTTP::Lite;
            use JSON::Any;
            $http = new HTTP::Lite;
            $http->request("http://more.handlino.com/sentences.json");
            my $j = JSON::Any->new();
            $json = $j->from_json( $http->body());
            $json->{sentences}[0];
        } || "Hello World!!!";
        my $plurk = $p->add_plurk($plurk_msg, "says", lang => $langs[0]);
        if (defined $plurk) {
            isa_ok ($plurk, Net::Plurk::Plurk);
            is($plurk->content, $plurk_msg);
        } else {
            is($p->api_errormsg, 'anti-flood-same-content');
            diag("The same content flooding"); 
        }
        done_testing();
}

diag( "Testing Net::Plurk add new plurk" );
