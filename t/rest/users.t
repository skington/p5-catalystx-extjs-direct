use Test::More  tests => 223;

use strict;
use warnings;

use HTTP::Request::Common;
use JSON;

use lib qw(t/lib);

use TestSchema;


use Test::WWW::Mechanize::Catalyst 'MyApp';

my $mech = Test::WWW::Mechanize::Catalyst->new();

my $schema = TestSchema->connect;

foreach my $i (1..200) {
    ok($schema->resultset('User')->create({name => sprintf('%04d', $i), password => 'password'.sprintf('%04d', 200-$i)}));   
}

$mech->add_header('Accept' => 'application/json');

$mech->get_ok('/users', undef, 'request list of users');

ok(my $json = JSON::decode_json($mech->content), 'response is JSON response');

is(@{$json->{rows}}, 200, '200 rows');

is($json->{results}, 200, '200 rows');

$mech->get_ok('/users?start=10', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is(@{$json->{rows}}, 190, '190 rows');

is($json->{results}, 200, '200 rows');

$mech->get_ok('/users?start=10&limit=20', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is(@{$json->{rows}}, 20, '20 rows');

is($json->{results}, 200, '200 rows');

$mech->get_ok('/users?start=10&limit=20&sort=name', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is(@{$json->{rows}}, 20, '20 rows');

is($json->{results}, 200, '200 rows');

is($json->{rows}->[0]->{name}, '0011', 'First row is user "0011"');

$mech->get_ok('/users?start=10&limit=20&sort=name&dir=desc', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{rows}->[0]->{name}, '0190', 'First row is user "0190"');

$mech->get_ok('/users?start=10&limit=20&sort=password&dir=asc', undef, 'request list of users');

ok($json = JSON::decode_json($mech->content), 'response is JSON response');

is($json->{rows}->[0]->{name}, '0190', 'First row is user "0190"');



