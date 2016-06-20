use strict;
use warnings;
use utf8;

use v5.020;
use List::Util qw(shuffle);
use Switch;

local $, = ' ';


package Enemy{
	use Moose;
	has 'name' => (is => 'rw', isa => 'Str');
	has 'power' => (is => 'rw', isa => 'Int');
	has 'health' => (is => 'rw', isa => 'Int');	
}

package Hero{
	use Moose;

	has 'name' => (is => 'rw', isa => 'Str');
	has 'health' => (is => 'rw', isa => 'Int');
	has 'start_health' => (is => 'rw', isa => 'Int');
	has 'weapon' => (is => 'rw', isa => 'Str');
	has 'weapon_power' => (is => 'rw', isa => 'Int');
}


my $hero = Hero->new(
	name => 'Bron',
	health => 50,
	start_health => 100,
	weapon => 'Nails',
	weapon_power => 10
	);

my $enemy = Enemy->new(
	name => 'Cat',
	health => 70,
	power => 40);

my $enemy2 = Enemy->new(
	name => 'Bear',
	health => 80,
	power => 50);

state @board;
state $level;
state @hero;
@hero = (0,0, $hero);

my @weapon0 = ('Axe', 30);
my @weapon1 = ('Bow', 40);
state @weapons;
@weapons = ('Axe', 30, 'Bow', 40);

our @enemies;
@enemies = ($enemy, $enemy2);

our %treasuries = (
	0 => \&recover,
	1 => \&take_new_weapon
	);

our %commands = (
	up => \&go_up,
	left => \&go_left,
	right => \&go_right,
	down => \&go_down,
	help => \&helper
	);


say "write 'exit' for end of the game";
say "Choose level:\neasy\nmedium\nhard\n";
my $i = 0;
while (<STDIN>) {
    chomp;

    next unless length;
    last if $_ =~ /exit/i;
    
    if ($i == 0)
    {
    	next unless $_ =~ /easy/i || $_ =~ /medium/i || $_ =~ /hard/i;
    	switch($_){
    		case 'easy' {$level = 1}
    		case 'medium' {$level = 2}
    		case 'hard' {$level = 3}
    	}
    	@board = generate_table();
    	print_board(@board);
    	$i += 1;
    }
    elsif($i > 1){
    	next unless defined $commands{$_};
	    $commands{$_}->();
	}
   	say "Enter command";
    $i += 1;
}

sub generate_table
{
	my @matrx = ('.', 'T', '.', 'X', 'X', 'X', '.', 'X', '.', 'T', '.', 'E', '.');
	# my @matrx = ('E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E', 'E');
	my @matrix;
	if ($level == 1){
		@matrx = shuffle @matrx;
		my @row0 = @matrx[11..12];
		unshift @row0, 'H';
		my @row1 = @matrx[0..2];
		my @row2 = @matrx[3..5];
		my @row3 = @matrx[6..8];
		my @row4 = @matrx[9..10];

		push @row4, 'F';

		push @matrix, (\@row0, \@row1, \@row2, \@row3, \@row4);
	}
	elsif($level == 2){
		push @matrx, ('E', 'T', 'X', 'X', 'X', '.', '.', '.', '.');
		@matrx = shuffle @matrx;
		my @row0 = @matrx[0..2];
		unshift @row0, 'H';
		my @row1 = @matrx[3..6];
		my @row2 = @matrx[7..10];
		my @row3 = @matrx[11..14];
		my @row4 = @matrx[15..18];
		my @row5 = @matrx[19..21];
		push @row5, 'F';
		push @matrix, (\@row0, \@row1, \@row2, \@row3, \@row4, \@row5);
	}
	elsif($level == 3){
		push @matrx, ('E', 'E', 'E', 'T', 'T', 'X', 'X', 'X', 'X', 'X', 'X', '.', '.', '.', '.', '.', '.', '.', '.', '.');
		@matrx = shuffle @matrx;
		my @row0 = @matrx[0..3];
		unshift @row0, 'H';
		my @row1 = @matrx[4..8];
		my @row2 = @matrx[9..13];
		my @row3 = @matrx[14..18];
		my @row4 = @matrx[19..23];
		my @row5 = @matrx[24..28];
		my @row6 = @matrx[29..32];
		push @row6, 'F';
		push @matrix, (\@row0, \@row1, \@row2, \@row3, \@row4, \@row5, \@row6);
	}
	return @matrix;
}

sub helper{
	my $info;
	say $info;
}

sub print_board{
	my @table = @_;
	my $j = 0;
	while ( $j < 0+@table){
		foreach my $element ( @{ $table[$j] } ) {
		    print $element, " ";
		}
		print "\n";
	$j += 1;
	}
}

sub go_left{
	if($hero[1] > 0 && $board[$hero[0]][$hero[1] -1] ne 'X'){
		take_treasury($hero[0],$hero[1] - 1);
		if (battle($hero[0], $hero[1] - 1) == 0){
			say "You lost the game";
			die;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0]][$hero[1] - 1] = 'H';
		@hero[1] = $hero[1] - 1;
	print_board(@board);
	}
	else {
		say "This move is not possible.\nTry again.";
	}
}

sub go_right{
	my $end_of_board;
	switch($level){
		case 1 { $end_of_board = 3}
		case 2 { $end_of_board = 4}
		case 3 { $end_of_board = 5}
	}
	if($hero[1] < $end_of_board && $board[$hero[0]][$hero[1] +1] ne 'X'){
		take_treasury($hero[0],$hero[1] + 1);
		if (battle($hero[0], $hero[1] + 1) == 0){
			say "You lost the game";
			die;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0]][$hero[1] +1] = 'H';
		@hero[1] = $hero[1] + 1;
		print_board(@board);
	}
	else {
		say "This move is not possible.\nTry again.";
	}

}

sub go_up{
	if($hero[0] > 0 && $board[$hero[0] - 1][$hero[1]] ne 'X'){
		take_treasury($hero[0] - 1,$hero[1]);
		if (battle($hero[0] - 1, $hero[1]) == 0){
			say "You lost the game";
			die;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0] - 1][$hero[1]] = 'H';
		@hero[0] = $hero[0] - 1;
		print_board(@board);
	}
	else{
		say "This move is not possible.\nTry again.";
	}
	
}

sub go_down{
	my $end_of_board;
	switch($level){
		case 1 { $end_of_board = 4}
		case 2 { $end_of_board = 5}
		case 3 { $end_of_board = 6}
	}
	if($hero[0] < $end_of_board && $board[$hero[0] + 1][$hero[1]] ne 'X'){
		take_treasury($hero[0] + 1, $hero[1]);
		if (battle($hero[0] + 1, $hero[1]) == 0){
			say "You lost the game";
			die;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0] + 1][$hero[1]] = 'H';
		@hero[0] = $hero[0] + 1;
	print_board(@board);
	}
	else{
		say "This move is not possible.\nTry again.\n";
	}
}

sub battle{
	my @coord = @_;
	if($board[$coord[0]][$coord[1]] eq 'E')
	{
		$enemy = shift @enemies;
		say "Your enemy is ". $enemy->name . " its health is: " . $enemy->health . "and its power is : " . $enemy->power;
		while($enemy->health > 0 && $hero->health > 0)
		{
			say "Your health is: " . $hero->health;
			say "Your enemy health is: " . $enemy->health;
			$enemy->health($enemy->health - $hero->weapon_power);
			$hero->health($hero->health - $enemy->power);
		}
		if($enemy->health <= 0 && $hero->health > 0){
			say "You killed ". $enemy->name;
			return 1;
		}
		elsif($enemy->health > 0 && $hero->health <= 0){
			say "You were killed by " . $enemy->name;
			return 0;
		}
		else{
			say "You were killed by " . $enemy->name;
			return 0;
		}
	}
	return 1;
}

sub take_treasury{
	my @coord = @_;
	if($board[$coord[0]][$coord[1]] eq 'T')
	{
		my $random = int(rand(2));
	    $treasuries{$random}->();
	}	
}

sub recover{
	if ($hero->health < $hero->start_health){
		if($hero->health + 20 > $hero->start_health){
			$hero->health($hero->start_health);
		}
		else{
			$hero->health($hero->health + 20);
		}
		say "Now your health is ".$hero->health;
	} 
}

sub take_new_weapon{
	my $new_weapon_name = shift @weapons;
	my $new_weapon_power = shift @weapons;
	$hero->weapon($new_weapon_name);
	$hero->weapon_power($new_weapon_power);
	say "You take ".$hero->weapon." with power ".$hero->weapon_power;
}