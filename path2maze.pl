#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: path2maze.pl
#
#        USAGE: ./path2maze.pl  
#
#  DESCRIPTION: http://code.google.com/codejam/contest/32003/dashboard#s=p1
#       AUTHOR: CHEN JIA
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 2014/6/29 19:14:49
#     REVISION: ---
#===============================================================================

use Mazer;

#my $input = "input.txt";
my $input = "B-large-practice.in";
my $output = "output.txt";

open IN, '<', $input or die "Can't open file $input: $!";
open OUT, '>', $output or die "Can't open file $output: $!";

my $mazer = Mazer->new();

for my $tc_cnt (1..<IN>){
    my $line = <IN>;
    chomp($line);

    my ($enter2exit, $exit2enter) = split " ", $line;

    for my $act (split "", $enter2exit){
        $mazer->OnAction($act);
    };
    $mazer->AdjustMaxMin($mazer->x, $mazer->y);

    #turn around, re-enter the exit, explore again
    $mazer->z($mazer->GetNextZ($mazer->z, 'O'));
    for my $act (split "", $exit2enter){
        $mazer->OnAction($act);
    };

    #print the map, reset all for next case
    print OUT "Case #$tc_cnt:\n";
    for my $y (1..$mazer->max_y){
       for my $x ($mazer->min_x..$mazer->max_x){
           my $room = $x.'_'.$y;
           print OUT sprintf("%x", $mazer->map->{$room}) if exists $mazer->map->{$room};
       }
       print OUT "\n";
    }	
    
    $mazer->reset_mazer();
}

close(IN);
close(OUT);
