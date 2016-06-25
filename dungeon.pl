#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use v5.020;

use List::Util qw(shuffle);
use Switch;

use FindBin;
use lib "$FindBin::Bin/lib";

use PPP::Hero;
use PPP::Enemy;


local $, = ' ';


my $hero = PPP::Hero->new(
	name => 'Bron',
	health => 50,
	start_health => 100,
	weapon => 'Nails',
	weapon_power => 10
);

my $enemy = PPP::Enemy->new(
	name => 'Cat',
	health => 70,
	power => 10
);

my $enemy2 = PPP::Enemy->new(
	name => 'Bear',
	health => 80,
	power => 50
);

our %treasuries = (
	0 => \&health,
	1 => \&take_new_weapon
);

our %commands = (
	up => \&go_up,
	left => \&go_left,
	right => \&go_right,
	down => \&go_down,
	help => \&helper,
	info => \&info
);

my @board;
my $level;
my @hero;
my @weapons;
my @enemies;

@hero = (0,0, $hero);
@weapons = ('Axe', 30, 'Bow', 40);
@enemies = ($enemy, $enemy2);






sub generate_table
{
	my @matrx = ('.', 'T', '.', '.', 'X', 'X', '.', 'X', '.', 'T', '.', 'E', '.');
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
		push @matrx, ('E', 'T', '.', 'X', 'X', '.', '.', '.', '.');
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
		push @matrx, ('E', 'E', 'E', 'T', 'T', 'X', '.', 'X', '.', 'X', 'X', '.', '.', '.', '.', '.', '.', '.', '.', '.');
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
	say "'exit' - end of game\nIf the move is possible you can use 'up', 'down', 'right' or 'left' to move in one of this directions.";
	say "Type 'info' for more information about you.";
}

sub print_board{
	my @table = @_;
	my $j = 0;
	print "\n";
	while ( $j < 0+@table){
		foreach my $element ( @{ $table[$j] } ) {
		    print $element, " ";
		}
		print "\n";
	$j += 1;
	}
	say "\n";
}

sub go_left{
	if($hero[1] > 0 && $board[$hero[0]][$hero[1] -1] ne 'X'){
		take_treasury($hero[0],$hero[1] - 1);
		won_game($hero[0] + 1, $hero[1] - 1);
		if (battle($hero[0], $hero[1] - 1) == 0){
			say "You lost the game";
			exit;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0]][$hero[1] - 1] = 'H';
		@hero[1] = $hero[1] - 1;
		recover();
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
		won_game($hero[0], $hero[1] + 1);
		if (battle($hero[0], $hero[1] + 1) == 0){
			say "You lost the game";
			exit;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0]][$hero[1] +1] = 'H';
		@hero[1] = $hero[1] + 1;
		recover();
		print_board(@board);
	}
	else {
		say "This move is not possible.\nTry again.";
	}

}

sub go_up{
	if($hero[0] > 0 && $board[$hero[0] - 1][$hero[1]] ne 'X'){
		take_treasury($hero[0] - 1,$hero[1]);
		won_game($hero[0] - 1, $hero[1]);
		if (battle($hero[0] - 1, $hero[1]) == 0){
			say "You lost the game";
			exit;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0] - 1][$hero[1]] = 'H';
		@hero[0] = $hero[0] - 1;
		recover();
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
		won_game($hero[0] + 1, $hero[1]);
		if (battle($hero[0] + 1, $hero[1]) == 0){
			say "You lost the game";
			exit;
		}
		$board[$hero[0]][$hero[1]] = '.';
		$board[$hero[0] + 1][$hero[1]] = 'H';
		@hero[0] = $hero[0] + 1;
		recover();
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
		say "Your enemy is ". $enemy->name . " its health is: " . $enemy->health . " and its power is : " . $enemy->power;
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
		my $recovery = 5;
		if($hero->health + $recovery > $hero->start_health){
			$hero->health($hero->start_health);
		}
		else{
			$hero->health($hero->health + $recovery);
		}
		say "Now your health is ".$hero->health;
	} 
}

sub health{
	if ($hero->health < $hero->start_health){
		my $recovery = 20;
		if($hero->health + $recovery > $hero->start_health){
			$hero->health($hero->start_health);
		}
		else{
			$hero->health($hero->health + $recovery);
		}
	} 
}

sub take_new_weapon{
	my $new_weapon_name = shift @weapons;
	my $new_weapon_power = shift @weapons;
	$hero->weapon($new_weapon_name);
	$hero->weapon_power($new_weapon_power);
	say "You take ".$hero->weapon." with power ".$hero->weapon_power;
}

sub won_game{
	my @coord = @_;
	if($board[$coord[0]][$coord[1]] eq 'F')
	{
		say "You entered this stage!!";
		exit;
	}
}

sub info{
	say "You are ".$hero->name;
	say "Your weapon is ".$hero->weapon." with power ".$hero->weapon_power; 	
	say "Now your health is ".$hero->health;
}

sub the_game{
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
	    	say "You are ".$hero->name.".";
	    	say "Try to kill as many as possible enemies.\n";
	    	say "Type 'help' for more information about commands.";
	    }
	    elsif($i > 1){
	    	next unless defined $commands{$_};
		    $commands{$_}->();
		}
	   	say "Enter command";
	    $i += 1;
	}
}
the_game();