#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON;

my $JSON = JSON->new->utf8->pretty->canonical;

my $idx = {};

my $i=0;
for my $json_path (<data/pdf/*/*.json>) {
    my ($uuid, $page_number) = $json_path =~ m{data/pdf/([^/]+)/page-([0-9]+)\.json};

    my $data = $JSON->decode("". io($json_path)->all);
    for my $box (@{ $data->{text_boxes} }) {
        my $t = $idx->{$box->{text}} ||= {};
        my $box_geometry = join ",", @{$box->{box}}{"left", "top", "right", "bottom"};
        push @{$t->{cutbox}}, "$uuid,$page_number,$box_geometry";
    }

    say "DONE $json_path";
}

io("var/ocr-index.json")->assert->print( $JSON->encode( $idx ) );
