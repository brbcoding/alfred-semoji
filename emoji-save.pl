#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8 decode_utf8);
use File::Spec;
use File::Path qw(make_path);

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

my $input = decode_utf8($ARGV[0] // '');

# Parse input: emoji|keyword1,keyword2,...
my ($emoji, $keywords_str) = split /\|/, $input, 2;
my @keywords = split /,/, ($keywords_str // '');

if (!$emoji || !@keywords) {
    print "Error: Missing emoji or keywords\n";
    exit 1;
}

# Config file setup
my $config_dir = File::Spec->catdir($ENV{HOME}, '.config', 'semoji');
my $config_file = File::Spec->catfile($config_dir, 'custom.json');

# Ensure config directory exists
make_path($config_dir) unless -d $config_dir;

# Load existing custom keywords
my %custom_keywords;
if (-f $config_file) {
    if (open my $fh, '<:utf8', $config_file) {
        local $/;
        my $json_text = <$fh>;
        close $fh;
        eval {
            my $existing = decode_json(encode_utf8($json_text));
            %custom_keywords = %$existing if ref($existing) eq 'HASH';
        };
    }
}

# Add new keywords (avoid duplicates)
my %existing_kw = map { lc($_) => 1 } @{$custom_keywords{$emoji} // []};
for my $kw (@keywords) {
    push @{$custom_keywords{$emoji}}, $kw unless $existing_kw{lc($kw)};
}

# Save config file
my $json = JSON::PP->new->utf8->pretty->canonical;
if (open my $fh, '>:raw', $config_file) {
    print $fh $json->encode(\%custom_keywords);
    close $fh;
    my $kw_str = join(", ", @keywords);
    print "Added '$kw_str' to $emoji\n";
} else {
    print "Error: Could not save config file\n";
    exit 1;
}
