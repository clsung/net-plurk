package Net::Plurk::ME;
use URI;
use Moose;
use Moose::Util::TypeConstraints;

=head1 NAME

Net::Plurk::ME 

=head1 SYNOPSIS

Foobar

=cut

has 'username' => ( is => 'rw', isa => 'Str' );
has 'password' => ( is => 'rw', isa => 'Str' );
has 'myself'   => ( is => 'rw', isa => 'Net::Plurk::User' );
has 'homepage' => (
    is      => 'rw',
    isa     => 'URI',
    default => sub { URI->new( baseurl . $self->username ) }
);

sub credential {
    my ( $self, $username, $password ) = @_;

    $self->username($u);
    $self->password($p);

    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
