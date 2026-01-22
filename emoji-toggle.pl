#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8);
use File::Spec;
use File::Path qw(make_path);

my $action = $ARGV[0] // '';

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

if ($action eq 'toggle_unicode') {
    # Toggle the setting
    $settings{unicode_enabled} = $settings{unicode_enabled} ? 0 : 1;

    # Ensure config directory exists
    make_path($config_dir) unless -d $config_dir;

    # Save settings
    if (open my $fh, '>:utf8', $settings_file) {
        print $fh JSON::PP->new->pretty->canonical->encode(\%settings);
        close $fh;
    }

    my $status = $settings{unicode_enabled} ? "enabled" : "disabled";
    print "Unicode search $status";
}
