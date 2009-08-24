package Net::Plurk::Page;
use Moose;

=head1 NAME

Net::Plurk::Page

=head1 SYNOPSIS

Parse Plurk page

=cut

has 'url' => ( is => 'ro', isa => 'Str');
has 'author' => ( is => 'rw', isa => 'Net::Plurk::User');
has 'title' => ( is => 'rw', isa => 'Str');
has 'messages' => ( is => 'rw', isa => 'ArrayRef[Net::Plurk::Message]', default => sub { [] } );
#has 'timestamp' => (is => 'rw', isa => 'DateTime', default => sub {DateTime->now});
has 'timestamp' => (is => 'rw', isa => 'Str');
has 'rawdata' => ( is => 'rw', isa => 'Str');

no Moose;
__PACKAGE__->meta->make_immutable;
1;
