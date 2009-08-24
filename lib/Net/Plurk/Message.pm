package Net::Plurk::Message;
use Moose;
use DataTime;

=head1 NAME

Net::Plurk::Message

=head1 SYNOPSIS

Plurk Message

=cut

has 'owner' => ( is => 'rw', isa => 'Str');
has 'message' => ( is => 'rw', isa => 'Str');
has 'timestamp' => (is => 'rw', isa => 'DateTime', default => sub {DateTime->now});

no Moose;
__PACKAGE__->meta->make_immutable;
1;
