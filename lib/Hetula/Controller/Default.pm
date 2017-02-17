use 5.22.0;

package Hetula::Controller::Default;

use Mojo::Base 'Mojolicious::Controller';

use Carp;
use autodie;
$Carp::Verbose = 'true'; #die with stack trace

=head1 NAME

Hetula::Controller::Default

=cut

=head2 index

Render the main page

=cut

sub index {
  my $self = shift;
  $self->reply->static('help.txt');
}

1;
