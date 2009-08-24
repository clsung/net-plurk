package Net::Plurk::User;
use Moose;

=head1 NAME

Net::Plurk::User 

=head1 SYNOPSIS

Foobar

=cut

#subtype 'Karma' => as class_type ('Float');

#coerce 'Karma'
#    => from 'Int'
#        => via (
has 'username' => (is => 'ro', isa => 'Str');
has 'karma' => (is => 'rw', isa => 'Str', default => "-1");
has 'fans' => (is => 'rw', isa => 'Int');
has 'friends' => (is => 'rw', isa => 'Int');

no Moose;
__PACKAGE__->meta->make_immutable;
1;
