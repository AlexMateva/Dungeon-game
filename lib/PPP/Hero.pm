package PPP::Hero;
use Moose;

has 'name' => (is => 'rw', isa => 'Str');
has 'health' => (is => 'rw', isa => 'Int');
has 'start_health' => (is => 'rw', isa => 'Int');
has 'weapon' => (is => 'rw', isa => 'Str');
has 'weapon_power' => (is => 'rw', isa => 'Int');

1;