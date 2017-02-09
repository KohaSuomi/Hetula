use 5.22.0;

package t::lib::Auth;

=head2 doPasswordLogin

Logs in and sets the session cookie to Test::Mojo->ua

=cut

sub doPasswordLogin {
  my ($t) = @_;

  my $tx = $t->ua->post('/api/v1/auth' => {Accept => '*/*'} => json => {username => 'admin', password => '1234'});
  my $cookies = $tx->res->cookies;
  my $sessionCookie = $cookies->[0];
  $t->ua->cookie_jar->add($sessionCookie);
  return $t;
}

1;
