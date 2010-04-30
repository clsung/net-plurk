#!perl -T
use utf8;

#use Test::More tests => 5;
use Test::More skip_all => "Not yet";

BEGIN {
	use Net::Plurk;
        my $p = Net::Plurk->new();
        $p->set(url => 'http://www.plurk.com/p/1obtmp' );
        $p->get();
        like($p->get_title(), qr'I Love You', 'P.S. I Love You');
        my @messages = @{$p->messages};
        cmp_ok($#messages, '>=', 5 , 'reply message >= 6');
        isa_ok($messages[0], 'Net::Plurk::Message' );
        is ($messages[0]->message, '(y)');
        is ($messages[2]->message, '好看');
}

diag( "Testing Net::Plurk Check single plurk message" );
