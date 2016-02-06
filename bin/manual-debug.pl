#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON;

binmode STDOUT, ":utf8";

my @texts;
my $JSON = JSON->new->utf8->pretty->canonical;
my $io_frequency = io("var/ocr-high-frequency.json")->assert;
my $idx = $JSON->decode(scalar io("var/ocr-index.json")->all);

if ( $io_frequency->exists ) {
    my $o = $JSON->decode(scalar $io_frequency->all);
    @texts = @{ $o->{'high-frequency'} };
} else {
    # keep the top 50%, expect them to be mostly correct.
    @texts = sort { $idx->{$b}{frequency} <=> $idx->{$a}{frequency} } keys %$idx;
    @texts = @texts[ 0 .. ($#texts/2) ];

    $io_frequency->print( $JSON->encode({ "high-frequency" => [ map { +{ text => $_, frequency => $idx->{$_}{frequency} } } @texts ] }));
}

@texts = @texts[0..99];
my $i = 0;
for (@texts) {
    $i++;
    my $io = io("var/top-text/top-${i}/box-images.txt")->assert;

    my $t = $_->{text};
    my $f = $_->{frequency};
    say "$t => $f";
    my $boxes = $idx->{$t}{cutbox};
    for my $box_spec (@$boxes) {
        my ($uuid, $page_number, $left, $top, $right, $bottom) = split(/,/, $box_spec);
        my $box_image_path = "$ENV{PWD}/tesseract/$uuid/box/${page_number}/box-$left,$top,$right,${bottom}.png";
        if (-f $box_image_path) {
            $io->append("$box_image_path\n");
        }
    }
}
