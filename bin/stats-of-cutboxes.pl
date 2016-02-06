#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON;

my $JSON = JSON->new->utf8->pretty->canonical;

my $aggr_by_text = {};

my $i=0;
for my $json_path (<data/pdf/*/*.json>) {
    my $data = $JSON->decode("". io($json_path)->all);
    for my $box (@{ $data->{text_boxes} }) {
        my $aggr = $aggr_by_text->{$box->{text}} ||= {};
        my $width  = $box->{box}{right} - $box->{box}{left};
        my $height = $box->{box}{bottom} - $box->{box}{top};
        my $wph = int(10*$width/$height)/10;
        
        $aggr->{frequency}++;
        $aggr->{histogram_wph}{$wph}++;
        $aggr->{histogram_wxh}{"${width}x${height}"}++;
        $aggr->{histogram_width}{$width}++;
        $aggr->{histogram_height}{$height}++;
    }
    say "DONE $json_path";
}

my $aggr2 = {};
for my $t (keys %$aggr_by_text) {
    my $chars = $aggr_by_text->{$t}{chars} = length($t);
    $aggr2->{histogram_chars}{$chars}++;
    $aggr2->{histogram_frequency}{ $aggr_by_text->{$t}{frequency} }++;

    for my $wph (keys %{ $aggr_by_text->{$t}{histogram_wph} }) {
        $aggr2->{histogram_wph}{$wph} += $aggr_by_text->{$t}{histogram_wph}{$wph};
    }
}

my $stats = {
    text => $aggr2,
    box  => $aggr_by_text,
};
io("var/stats-of-cutboxes.json")->assert->print( $JSON->encode( $stats ) );
