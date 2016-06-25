package PPP::Enemy;
use Moose;
has 'name' => (is => 'rw', isa => 'Str');
has 'power' => (is => 'rw', isa => 'Int');
has 'health' => (is => 'rw', isa => 'Int');

1;