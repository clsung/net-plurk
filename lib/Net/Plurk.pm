package Net::Plurk;
use feature ':5.10';
use Moose;
use URI;
use JSON::Any;
use AnyEvent::HTTP;
use Net::Plurk::UserProfile;
use DateTime;
use Data::Dumper;

use namespace::autoclean;

has api_key => ( isa => 'Str', is => 'rw');
has cookie => ( isa => 'HashRef', is => 'rw', default => sub{{}});
has api_user => ( isa => 'Net::Plurk::UserProfile', is => 'rw');
has api_errormsg => ( isa => 'Maybe[Str]', is => 'rw');
has publicProfiles => ( isa => 'HashRef', is => 'rw', default => sub {{}});
#has plurks => ( isa => 'ArrayRef[Net::Plurk::Plurk]', is => 'rw', default => sub {[]});
#has plurk_users => ( isa => 'HashRef[Net::Plurk::User]', is => 'rw', default => sub {{}});
has plurks => ( isa => 'ArrayRef', is => 'rw', default => sub {[]});
has plurk_users => ( isa => 'HashRef', is => 'rw', default => sub {{}});
has lastPollingTime => (isa => 'DateTime', is => 'rw',
        # default is 5 mins ago
        default => sub {DateTime->from_epoch( epoch => time() - 5 * 60 );}
    );
has events => ( isa => 'HashRef[CodeRef]', is => 'rw', default => sub {{}});
has unreadCount => ( isa => 'Int', is => 'ro' );
has unreadAll => ( isa => 'Int', is => 'ro' );
has unreadMy => ( isa => 'Int', is => 'ro' );
has unreadPrivate => ( isa => 'Int', is => 'ro' );
has unreadResponded => ( isa => 'Int', is => 'ro' );
has json_parser => (isa => 'JSON::Any', is => 'ro', default => sub {JSON::Any->new()});

=head1 NAME

Net::Plurk - The great new Net::Plurk!

=head1 VERSION

Version 0.06

=cut

our $VERSION = '0.06';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Plurk;
    my $api_key = $PLURKAPIKEY // "dKkIdUCoHo7vUDPjd3zE0bRvdm5a9sQi";
    my $user = $PLURKUSER // 'nobody';
    my $pass = $PLURKPASS // 'nopass';
    my $p = Net::Plurk->new(api_key => $api_key);
    my $profile = $p->login(user => $user, pass => $pass );
    $p->add_events(
        on_new_plurk => sub {
            my $plurk = shift;
            use Data::Dumper; warn Dumper $plurk;
        },
        on_private_plurk => sub {
            my $plurk = shift;
            # blah
        },
        );
    $p->listen;
    my $json = $p->api( path => '/api');
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 api

Everything from here

=cut

sub api {
    my ($self, %args) = @_;
    my ($data, $header);
    my $w = AE::cv;
    my $u = URI->new("http://www.plurk.com/");
    $u->path("/API".$args{path});
    $u->scheme("https") if index($args{path}, "/Users") == 0;
    delete $args{path};
    $args{api_key} = $self->api_key unless $args{api_key};
    $u->query_form(%args);
    http_get ($u, 
        cookie_jar => $self->cookie,
        sub {
            ($data, $header) = @_;
            $self->api_errormsg(undef); # clear errormsg
            $data = $self->json_parser->from_json($data);
            $self->api_errormsg($data->{error_text}) if $header->{Status} eq '400';
            $w->send;
        }
    );
    $w->recv;
    return wantarray ? ($data, $header) : $data;
}

=head2 is_logged_in

Check if logged in, we use /API/Blocks/get to check
the return JSON contains 'error_text' => 'Requires login'

=cut

sub is_logged_in {
    my $self = shift;
    return 0 unless $self->cookie;
    my $json_data = $self->api(
        path => '/Blocks/get',
    );
    return 0 if /error_text/ ~~ %{$json_data};
    return 1;
}

=head2 login

Get the request url and return Net::Plurk::User 

=cut

sub login {
    my ($self, %args) = @_;
    $args{no_data} //= 0;
    my $json_data = $self->api(
        path => '/Users/login',
        username => $args{user},
        password => $args{pass},
#        no_data => $args{no_data} if $args{no_data},
    );
    $self->api_user(Net::Plurk::UserProfile->new($json_data));
    return $self->api_user;
}

=head2 logout

Just logout, should alway return 1

=cut

sub logout {
    my ($self, %args) = @_;
    my $json_data = $self->api(
        path => '/Users/logout',
    );
    return $json_data->{'success_text'} eq 'ok'; 
}

=head2 _get_unique_id

given nick_name, return unique_id

=cut 

sub _get_unique_id {
    my ($self, $nick_name) = @_;
    # check if we have it in cache, since we only want to retreive unique id
    $self->get_public_profile($nick_name) unless $self->publicProfiles->{ $nick_name };
    return $self->publicProfiles->{$nick_name}->{user_info}->id;
}

=head2 get_public_profile

call /Profile/getPublicProfile

=cut

sub get_public_profile {
    my ($self, $user) = @_;
    my $json_data = $self->api(
        path => '/Profile/getPublicProfile',
        user_id => $user,
    );
    $self->publicProfiles->{ $user } = Net::Plurk::PublicUserProfile->new($json_data);
    return $self->publicProfiles->{ $user };
}

=head2 get_new_plurks

call /Polling/getPlurks
arguments =>
    offset: Return plurks newer than offset, formatted as 2009-6-20T21:55:34. 

=cut

sub get_new_plurks {
    my ($self, %args) = @_;
    $args{offset} //= $self->lastPollingTime;
    $args{limit} //= 50; # default is 50
    $args{offset} = $args{offset}->strftime("%Y-%m-%dT%H:%M:%S");
    my $json_data = $self->api(
        path => '/Polling/getPlurks',
        offset => $args{offset},
        limit => $args{limit},
    );
    $self->plurk_users($json_data->{plurk_users});
    $self->plurks($json_data->{plurks});
    $self->lastPollingTime(DateTime->now);
    return $self->plurks;
}

=head2 karma

    return logined user's karma, or specify user => 'who'

=cut

sub karma {
    my ($self, %args) = @_;
    return $self->get_public_profile($args{user})->user_info->karma if $args{user};
    return 0 unless $self->is_logged_in();
    return $self->api_user->user_info->karma;
}

=head2 follow

    return 1 if followed someone, 0 otherwise (see api_errormsg)

=cut

sub follow {
    my ($self, $user_id) = @_;

    # if input user nick_name instead of unique id
    $user_id = $self->_get_unique_id($user_id) if $user_id !~ m/^\d+$/;

    my $json_data = $self->api(
        path => '/FriendsFans/setFollowing',
        user_id => $user_id,
        follow => 'true',
    );
    return 0 if $self->api_errormsg;
    return 1;
}

=head2 unfollow

    return 1 if unfollowed someone, 0 otherwise (see api_errormsg)

=cut

sub unfollow {
    my ($self, $user_id) = @_;

    # if input user nick_name instead of unique id
    $user_id = $self->_get_unique_id($user_id) if $user_id !~ m/^\d+$/;

    my $json_data = $self->api(
        path => '/FriendsFans/setFollowing',
        user_id => $user_id,
        follow => 'false',
    );
    return 0 if $self->api_errormsg;
    return 1;
}

=head2 add_plurk

    add_plurk (qualifier, content, %opt)
    %opt: limited_to, no_comment, lang

=cut

sub add_plurk {
    my ($self, $content, $qualifier, %opt) = @_;
    $qualifier //= 'says';
    my $json_data = $self->api(
        path => '/Timeline/plurkAdd',
        qualifier => $qualifier,
        content => $content,
        %opt,
    );
    return Net::Plurk::Plurk->new($json_data) if !$self->api_errormsg;
    return ;
}

=head1 AUTHOR

Cheng-Lung Sung, C<< <clsung at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-net-plurk at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Net-Plurk>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Net::Plurk


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Net-Plurk>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Net-Plurk>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Net-Plurk>

=item * Search CPAN

L<http://search.cpan.org/dist/Net-Plurk/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009~2010 Cheng-Lung Sung, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of Net::Plurk
