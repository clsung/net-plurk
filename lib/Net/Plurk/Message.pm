package Net::Plurk::Message;
use Moose;

=head1 NAME

Net::Plurk::Message

=head1 SYNOPSIS

Plurk Message

=cut

has 'username' => ( is => 'ro', isa => 'Str');
has 'nick' => ( is => 'ro', isa => 'Str');
has 'message' => ( is => 'ro', isa => 'Str');
has 'timestamp' => (is => 'ro', isa => 'Str');

no Moose;
__PACKAGE__->meta->make_immutable;
1;
