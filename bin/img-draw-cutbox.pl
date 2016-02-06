#!/usr/bin/env perl
use v5.18;
use IO::All;
use JSON::PP qw<decode_json>;
use Imager;
use Getopt::Std;

sub main {
    my %opts = @_;
    -f $opts{input} or die "Input $opts{input} is not a file.";
    -f $opts{box} or die "Box description $opts{box} is not a file.";
    
    my $box = decode_json(io($opts{input})->all);
}

my %opts;
getopts("i:o:b:", \%opts);
@opts{qw(input output box)} = @opts{qw(i o b)};
main(\%opts);

