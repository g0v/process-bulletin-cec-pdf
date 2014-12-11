#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON;

my $JSON = JSON->new->utf8->pretty->canonical;
my $idx = $JSON->decode(scalar io("var/ocr-index.json")->all);


# keep the top 50%, expect them to be mostly correct.
my @texts = sort { $idx->{$b}{frequency} <=> $idx->{$a}{frequency} } keys %$idx;
@texts = @texts[ 0 .. ($#texts/2) ];

io("var/ocr-high-frequency.json")->assert->print( $JSON->encode({
    "high-frequency" => [ map { +{ text => $_, frequency => $idx->{$_}{frequency} } } @texts ]
}));

