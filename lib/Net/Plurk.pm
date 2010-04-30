package Net::Plurk;
use feature ':5.10';
use Moose;
use URI;
use JSON::Any;
use AnyEvent::HTTP;
use Net::Plurk::UserProfile;
use Data::Dumper;

use namespace::autoclean;

has api_key => ( isa => 'Str', is => 'rw');
has cookie => ( isa => 'HashRef', is => 'rw', default => sub{{}});
has api_user => ( isa => 'Net::Plurk::UserProfile', is => 'rw');
has publicProfiles => ( isa => 'HashRef', is => 'rw', default => sub {{}});
has unreadCount => ( isa => 'Int', is => 'ro' );
has unreadAll => ( isa => 'Int', is => 'ro' );
has unreadMy => ( isa => 'Int', is => 'ro' );
has unreadPrivate => ( isa => 'Int', is => 'ro' );
has unreadResponded => ( isa => 'Int', is => 'ro' );
has json_parser => (isa => 'JSON::Any', is => 'ro', default => sub {JSON::Any->new()});

=head1 NAME

Net::Plurk - The great new Net::Plurk!

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Net::Plurk;

    my $foo = Net::Plurk->new( username => 'foo', password => 'bar');
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
            $data = $self->json_parser->from_json($data);
            $w->send;
        }
    );
    $w->recv;
    return wantarray ? ($data, $header) : $data;
}

=head2 is_logged_in

Check if logged in

=cut

sub is_logged_in {
    my $self = shift;
    return 1 if $self->cookie;
    return 0;
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

=head2 karma

=cut

sub karma {
    my ($self, %args) = @_;
    return $self->get_public_profile($args{user})->user_info->karma if $args{user};
    return 0 unless $self->is_logged_in();
    return $self->api_user->user_info->karma;
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

Copyright 2009 Cheng-Lung Sung, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1; # End of Net::Plurk
