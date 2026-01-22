#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8);
use File::Spec;
use File::Path qw(make_path);

binmode STDOUT, ':raw';

my $config_dir = File::Spec->catdir($ENV{HOME}, '.config', 'semoji');
my $settings_file = File::Spec->catfile($config_dir, 'settings.json');

# Load current settings
my %settings = (unicode_enabled => 0);
if (-f $settings_file) {
    if (open my $fh, '<:utf8', $settings_file) {
        local $/;
        my $json_text = <$fh>;
        close $fh;
        eval {
            my $data = decode_json(encode_utf8($json_text));
            %settings = (%settings, %$data) if ref($data) eq 'HASH';
        };
    }
}

my $unicode_enabled = $settings{unicode_enabled} ? 1 : 0;
my $unicode_status = $unicode_enabled ? "ON" : "OFF";
my $unicode_icon = $unicode_enabled ? "✓" : "○";
my $toggle_action = $unicode_enabled ? "Disable" : "Enable";

my @items = (
    {
        uid => 'unicode_toggle',
        title => "$unicode_icon  Unicode Search: $unicode_status",
        subtitle => "$toggle_action unicode character search (arrows, math, greek, currency)",
        arg => "toggle_unicode",
        valid => JSON::PP::true,
    },
);

my $output = { items => \@items };
print encode_json($output) . "\n";
