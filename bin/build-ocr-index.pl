#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON;

my $JSON = JSON->new->utf8->pretty->canonical;

my $idx = {};

for my $json_path (<data/pdf/*/*.json>) {
    my ($uuid, $page_number) = $json_path =~ m{data/pdf/([^/]+)/page-([0-9]+)\.json};

    my $data = $JSON->decode("". io($json_path)->all);
    for my $box (@{ $data->{text_boxes} }) {
        my $text = $box->{text};

        # next unless $text =~ /\A\p{Letter}+\z/;
        next unless $text =~ /\A\p{Han}+\z/;

        my $t = $idx->{$text} ||= {};

        my $box_geometry = join ",", @{$box->{box}}{"left", "top", "right", "bottom"};
        push @{$t->{cutbox}}, "$uuid,$page_number,$box_geometry";
        $t->{frequency} += 1;
    }

    say "DONE $json_path";
}

io("var/ocr-index.json")->assert->print( $JSON->encode( $idx ) );
