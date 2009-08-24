package Net::Plurk::Parse;
use Moose;
use Moose::Util::TypeConstraints;
use HTML::TreeBuilder::XPath;
use Net::Plurk::Page;
use Net::Plurk::Message;
use Net::Plurk::User;
use JSON::Any;

=head1 NAME

Net::Plurk::Parse

=head1 SYNOPSIS

Parse Plurk page

=cut

has 'treeparser' => (
    is      => 'ro',
    isa     => 'HTML::TreeBuilder::XPath',
    default => sub { HTML::TreeBuilder::XPath->new }
);

has 'parsed' => ( is => 'rw', isa => 'Bool', default => 0 );
has 'content' => ( is => 'rw', isa => 'Str' );
enum 'PageType' => qw (user message main none);
has 'pagetype' => ( is => 'rw', isa => 'PageType', default => 'none' );

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    $self->parse();
}

=head2 parse

=cut

sub parse {
    my $self = shift;
    if ( $self->content ) {
        $self->parsed(0);
        $self->treeparser->parse_content( $self->content ) and $self->parsed(1);
        return undef unless $self->parsed;
        my $page = Net::Plurk::Page->new(
            rawdata => $self->content,
            url     => $self->get_static_page_url
        );
        $page->title( $self->get_title );
        if ( my ($capture) = $self->content =~ m/^var GLOBAL = (.+)$/m ) {
            my $j = JSON::Any->new;
            $capture =~ s/new Date\(([^)]+)\)/$1/g;
            my $json  = $j->decode($capture);
            my $puser = $json->{page_user};
            if ( $self->pagetype eq 'user' ) {
                my $user =
                  Net::Plurk::User->new( username => $puser->{nick_name} );
                $user->karma( $puser->{karma} );
                $user->fans( $puser->{num_of_fans} );
                $user->friends( $puser->{num_of_friends} );
                $page->author($user);


            }
        }
        if ( $self->pagetype eq 'message' ) {
            my @nodes =
                $self->treeparser->findnodes('//ul[@class="responses"]/*/div[@class="message "]');
            $page->messages([]) if @nodes;
            for my $node (@nodes) {
                my ($uname, $nick, $message, $timestamp);
                $uname = $node->findnodes('./a[@class="user"]')->[0]->attr('href');
                $uname =~ s#.*/##;
                $nick  = $node->findvalue('./a[@class="user"]');
                $message = $node->findvalue('./span[@class="plurk_content"]');
                $timestamp = $node->findvalue('./span[@class="time"]');
                push @{$page->messages}, Net::Plurk::Message->new (
                    username => $uname, nick => $nick, message => $message, 
                    timestamp => $timestamp );
            }
        }

        return $page;
    }
}

=head2 get_static_page_url

=cut

sub get_static_page_url {
    my $self = shift;
    $self->parse if ( !$self->parsed and $self->content );
    my @nodes =
      $self->treeparser->findnodes('//link[@type="application/atom+xml"]');
    if (@nodes) {
        my $xmlFile = $nodes[0]->attr('href');
        if ( $xmlFile =~ m{^/p/} ) {
            $self->pagetype('message');
        }
        else {
            $self->pagetype('user');
        }
        $xmlFile =~ s/\.xml$//;
        return 'http://www.plurk.com' . $xmlFile;
    }
    $self->pagetype('main');
    return 'http://www.plurk.com/main';

}

=head2 get_title

=cut

sub get_title {
    my $self = shift;
    $self->parse if ( !$self->parsed and $self->content );
    return $self->treeparser->findvalue('//title');
}

=head2 get_page_timestamp

=cut

sub get_page_timestamp {
    my $self = shift;
    $self->parse if ( !$self->parsed and $self->content );
    return $self->treeparser->findvalue('//meta[@content]');
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
