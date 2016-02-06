#!/usr/bin/env perl

=head1 Description

run like

    $0 ../bulletin.cec.gov.tw/Console/Command/data

=head1 Dependencies

poppler

- pdftotext
- pdfimages

=cut

use v5.18;
use strict;
use warnings;

use IO::All;
use Text::CSV_XS;

my $csv = Text::CSV_XS->new ({ binary => 1, auto_diag => 1 });

my ($data_dir) = @ARGV;

my $log_non_pdf = io("data/non-pdf-file.txt")->assert;
my $log_text_pdf = io("data/text-pdf-file.txt")->assert;
my $log_notext_pdf = io("data/notext-pdf-file.txt")->assert;
my $log_notext_noimage_pdf = io("data/notext-noimage-file.txt")->assert;

for my $work (["bulletin.csv", "pdf"], ["bulletin_103.csv", "pdf_103"]) {
    my $csv_io = io->catfile($data_dir, $work->[0])->utf8;
    while (my $row = $csv->getline($csv_io)) {
        my $uuid = $row->[3] || $row->[2];
        my $pdf_file = io->catfile($data_dir, $work->[1], "${uuid}.pdf")->canonpath;
        if (`file $pdf_file` =~ /: PDF document,/) {
            my $text = `pdftotext $pdf_file - 2>/dev/null`;
            $text =~ s/\s//gs;
            if (length($text) == 0) {
                my $image_list_output = `pdfimages -list $pdf_file 2>/dev/null`;
                my @lines = split(/\n/, $image_list_output);
                if (@lines <= 2) {
                    $log_notext_noimage_pdf->println("$pdf_file");
                } else {
                    $log_notext_pdf->println("$pdf_file");
                }
            } else {
                $log_text_pdf->println("$pdf_file");
            }
        } else {
            $log_non_pdf->println("$pdf_file");
        }
    }
}
