package Net::Plurk;
use Moose;
use WWW::Mechanize;
use Net::Plurk::Parse;
use Net::Plurk::Page;

use namespace::autoclean;

has url => ( isa => 'Str', is => 'rw', default => 'http://plurk.com' );
has baseurl => ( isa => 'Str', is => 'ro', default => 'http://plurk.com' );
has mech => ( is => 'ro', default => sub {WWW::Mechanize->new} );
has parser => ( isa => 'Net::Plurk::Parse', is => 'ro', lazy_build => 1);
has pages => ( isa => 'HashRef[Str]', is => 'rw', default => sub { {} });
has users => ( isa => 'HashRef[Str]', is => 'rw', default => sub { {} });

our $user_pattern = 'plurk.com/user/';
=head1 NAME

Net::Plurk - The great new Net::Plurk!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

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

=head2 set

Set the attributes

=cut

sub set {
    my ($self, %args) = @_;
    $self->url($args{url}) if $args{url};
}

=head2 get

Get the request url 

=cut

sub get {
    my ($self, $url) = @_;
    $url = $self->url unless $url;
    $self->url($url) if ($url ne $self->url);
    $self->mech->get($self->url);
    return unless $self->mech->success;
    $self->parser->content($self->mech->content);
    my $page = $self->parser->parse();
    $self->pages->{$self->url} = $page;
    $self->users->{$page->author->username} = $page->author if $page->author;
    return $self->pages->{$self->url}->title;
}

=head2 goto

=cut

sub goto {
    my ($self, %args) = @_;
    $self->set(%args);
    return $self->get();
}

=head2 get_user

=cut

sub get_user {
    my ($self, $user, $renew) = @_;
    return $self->users->{$user} unless ($renew or !($self->users->{$user}));
    my $url = $self->baseurl."user/".$user;
    $self->get($url);
    return $self->users->{$user};
}

=head2 get_title

=cut

sub get_title {
    my ($self, $url) = @_;
    $url = $self->url unless $url;
    return $self->pages->{$url}->title;
}

=head2 get_karma

=cut

sub get_karma {
    my ($self, %args) = @_;
    return 0 unless $args{user};
    return $self->get_user($args{user},$args{renew})->karma;
}

=head2 _build_parser

=cut

sub _build_parser {
    my $self = shift;
    return Net::Plurk::Parse->new();
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
