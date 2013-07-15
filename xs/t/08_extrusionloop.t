#!/usr/bin/perl

use strict;
use warnings;

use Slic3r::XS;
use Test::More tests => 7;

my $square = [
    [100, 100],
    [200, 100],
    [200, 200],
    [100, 200],
];

my $loop = Slic3r::ExtrusionLoop->new(
    polygon  => Slic3r::Polygon->new(@$square),
    role     => Slic3r::ExtrusionPath::EXTR_ROLE_EXTERNAL_PERIMETER,
);
isa_ok $loop->as_polygon, 'Slic3r::Polygon', 'loop polygon';
is_deeply $loop->as_polygon->pp, $square, 'polygon points roundtrip';

$loop = $loop->clone;

is $loop->role, Slic3r::ExtrusionPath::EXTR_ROLE_EXTERNAL_PERIMETER, 'role';
$loop->role(Slic3r::ExtrusionPath::EXTR_ROLE_FILL);
is $loop->role, Slic3r::ExtrusionPath::EXTR_ROLE_FILL, 'modify role';

{
    my $path = $loop->split_at_first_point;
    is_deeply $path->as_polyline->pp, $square, 'split_at_first_point';
    is $path->role, $loop->role, 'role preserved after split';
    
    is_deeply $loop->split_at_index(2)->as_polyline->pp, [ @$square[2,3,0,1] ], 'split_at_index';
}

__END__