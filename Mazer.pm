package Mazer;
use 5.18.1;
use Moose;

has 'x' => (is => 'rw', 
            isa => 'Int',
            trigger => \&OnMoveX,
            default => 0);
has 'y' => (is => 'rw', 
            isa => 'Int',			
            trigger => \&OnMoveY,
            default => 0);

#z is the direction mazer facing at, default to south
has 'z' => (is => 'rw',
            isa => 'Str',
            default => 'S');

has ['max_x','max_y','min_x'] => (is => 'rw', 
                                  isa => 'Int',
                                  default => 0);

#the map, key is x_y, value is the bitmask of 'EWSN'
has 'map' => (is => 'rw',
              isa => 'HashRef[Int]',
              default => sub {{}});
		   
sub reset_mazer {
    my $self = shift;
    $self->x(0);
    $self->y(0);
    $self->z('S');
    $self->max_x(0);
    $self->min_x(0);	
    $self->max_y(1);
    %{$self->map} = ();
}
               
sub set_maze {
    my ($self, $in_x, $in_y, $dir) = @_;

    my $room = $in_x.'_'.$in_y;
    if (not exists $self->map->{$room}){
        #assume all directions are not movable
        $self->map->{$room} = 0;
    }
    my $index = index 'NSWE', $dir;
    $self->map->{$room} |= (1 << $index);
}

sub OnMoveX {
    my ($self, $new_x, $old_x) = @_;
    
    return unless @_ > 2;

    if($new_x > $old_x){
        $self->set_maze($new_x, $self->y, 'W');
        $self->set_maze($old_x, $self->y, 'E');
        $self->max_x($new_x) if $new_x > $self->max_x;
    }
    else{
        $self->set_maze($new_x, $self->y, 'E');
        $self->set_maze($old_x, $self->y, 'W');
        $self->min_x($new_x) if $new_x < $self->min_x;
    }
}

sub OnMoveY {
    my ($self, $new_y, $old_y) = @_;
    
    return unless @_ > 2;

    if($new_y > $old_y){
        $self->set_maze($self->x, $new_y, 'N');
        $self->set_maze($self->x, $old_y, 'S');
        $self->max_y($new_y) if $new_y > $self->max_y;
    }
    else{
        $self->set_maze($self->x, $new_y, 'S');
        $self->set_maze($self->x, $old_y, 'N');
    }
}

no warnings 'experimental::smartmatch';
sub OnAction {
    my ($self, $action) = @_;
    for($action){
        when (/W/){
            $self->y($self->y - 1) if $self->z eq 'N';
            $self->y($self->y + 1) if $self->z eq 'S';
            $self->x($self->x - 1) if $self->z eq 'W';
            $self->x($self->x + 1) if $self->z eq 'E';
        };
        when (/L|R/){
            $self->z($self->GetNextZ($self->z, $action));
        };
        default { die "die on unexepcted action: $action"; };
    }
}

sub GetNextZ {
    my ($self, $in, $turn) = @_;
    my $dir_order = $turn eq 'L' ? 'WSEN' : 'WNES';
    my $step = $turn eq 'O' ? 2 : 1;

    return substr($dir_order, (index($dir_order, $in) + $step) % 4, 1);
}

sub AdjustMaxMin {
    my ($self, $exit_x, $exit_y) = @_;

    if($self->min_x eq $exit_x && $self->z eq 'W'){
       $self->min_x($self->min_x + 1);
    }
    elsif($self->max_x eq $exit_x && $self->z eq 'E'){
       $self->max_x($self->max_x - 1);	
    }
    elsif($self->max_y eq $exit_y && $self->z eq 'S'){
       $self->max_y($self->max_y - 1);	
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
