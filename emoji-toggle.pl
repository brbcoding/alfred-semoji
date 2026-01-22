#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8);
use File::Spec;
use File::Path qw(make_path);

binmode STDOUT, ':raw';

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

# Get current state (handle JSON::PP::Boolean objects)
my $current = $settings{unicode_enabled};
my $is_enabled = ref($current) ? $$current : ($current ? 1 : 0);

if ($action eq 'status') {
    # Return Alfred JSON showing current status
    my $status = $is_enabled ? "ON" : "OFF";
    my $icon = $is_enabled ? "✓" : "○";
    my $toggle_action = $is_enabled ? "Disable" : "Enable";

    my @items = ({
        uid => 'unicode_toggle',
        title => "$icon  Unicode Search: $status",
        subtitle => "Press Enter to $toggle_action",
        arg => "toggle",
        valid => JSON::PP::true,
    });

    print encode_json({ items => \@items }) . "\n";
}
elsif ($action eq 'toggle_unicode') {
    # Toggle the setting
    $settings{unicode_enabled} = $is_enabled ? JSON::PP::false : JSON::PP::true;

    # Ensure config directory exists
    make_path($config_dir) unless -d $config_dir;

    # Save settings
    if (open my $fh, '>:utf8', $settings_file) {
        print $fh JSON::PP->new->pretty->canonical->encode(\%settings);
        close $fh;
    }

    my $new_enabled = ref($settings{unicode_enabled}) ? ${$settings{unicode_enabled}} : $settings{unicode_enabled};
    my $status = $new_enabled ? "enabled" : "disabled";
    print "Unicode search $status";
}
