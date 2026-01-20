#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8 decode_utf8);
use File::Spec;
use File::Path qw(make_path);

binmode STDIN, ':utf8';
binmode STDOUT, ':raw';

my $input = join(' ', @ARGV) // '';
$input =~ s/^\s+|\s+$//g;

# Parse input: first word is emoji search, rest are keywords to add
my @parts = split /\s+/, $input;
my $search = lc(shift @parts // '');
my @new_keywords = @parts;

# Config file setup
my $config_dir = File::Spec->catdir($ENV{HOME}, '.config', 'semoji');
my $config_file = File::Spec->catfile($config_dir, 'custom.json');

# Emoji database (subset for searching)
my @emojis = (
    ['😀', 'Grinning Face', ['happy', 'smile', 'joy']],
    ['😂', 'Face with Tears of Joy', ['laugh', 'funny', 'lol']],
    ['😊', 'Smiling Face with Smiling Eyes', ['happy', 'blush']],
    ['😍', 'Smiling Face with Heart-Eyes', ['love', 'crush']],
    ['🥰', 'Smiling Face with Hearts', ['love', 'affection']],
    ['😎', 'Smiling Face with Sunglasses', ['cool', 'awesome']],
    ['🤔', 'Thinking Face', ['think', 'hmm', 'wonder']],
    ['😢', 'Crying Face', ['cry', 'sad', 'tear']],
    ['😭', 'Loudly Crying Face', ['cry', 'sobbing', 'sad']],
    ['😡', 'Pouting Face', ['angry', 'mad', 'furious']],
    ['🥳', 'Partying Face', ['party', 'celebrate']],
    ['👍', 'Thumbs Up', ['good', 'yes', 'ok', 'like']],
    ['👎', 'Thumbs Down', ['bad', 'no', 'dislike']],
    ['👋', 'Waving Hand', ['wave', 'hello', 'hi', 'bye']],
    ['🙏', 'Folded Hands', ['pray', 'please', 'thank']],
    ['💪', 'Flexed Biceps', ['strong', 'muscle', 'power']],
    ['❤️', 'Red Heart', ['love', 'heart', 'romance']],
    ['💔', 'Broken Heart', ['heartbreak', 'sad']],
    ['🔥', 'Fire', ['fire', 'hot', 'lit', 'awesome']],
    ['✨', 'Sparkles', ['sparkle', 'shine', 'magic']],
    ['🎉', 'Party Popper', ['party', 'celebrate', 'congrats']],
    ['💯', 'Hundred Points', ['100', 'perfect', 'score']],
    ['⭐', 'Star', ['star', 'favorite', 'rating']],
    ['🚀', 'Rocket', ['rocket', 'launch', 'fast', 'startup']],
    ['💻', 'Laptop', ['laptop', 'computer', 'coding']],
    ['📱', 'Mobile Phone', ['phone', 'mobile', 'cell']],
    ['☕', 'Hot Beverage', ['coffee', 'tea', 'morning']],
    ['🍕', 'Pizza', ['pizza', 'food']],
    ['🍺', 'Beer Mug', ['beer', 'drink', 'alcohol']],
    ['🐶', 'Dog Face', ['dog', 'puppy', 'pet']],
    ['🐱', 'Cat Face', ['cat', 'kitty', 'pet']],
);

# Load existing custom keywords
my %custom_keywords;
if (-f $config_file) {
    if (open my $fh, '<:utf8', $config_file) {
        local $/;
        my $json_text = <$fh>;
        close $fh;
        eval {
            my $data = decode_json(encode_utf8($json_text));
            %custom_keywords = %$data if ref($data) eq 'HASH';
        };
    }
}

my @items;

if ($search eq '') {
    push @items, {
        title => "Add custom keyword to emoji",
        subtitle => "Type: <emoji-search> <keyword> (e.g., 'fire awesome')",
        valid => JSON::PP::false,
        icon => { path => "icon.png" }
    };
} else {
    # Find matching emojis
    my @matches;
    for my $e (@emojis) {
        my $name_lower = lc($e->[1]);
        my $matches = 0;

        # Check if emoji itself matches (for direct paste)
        $matches = 1 if $e->[0] eq $search;

        # Check name
        $matches = 1 if index($name_lower, $search) >= 0;

        # Check keywords
        for my $kw (@{$e->[2]}) {
            $matches = 1 if index(lc($kw), $search) >= 0;
        }

        push @matches, $e if $matches;
    }

    if (@matches == 0) {
        push @items, {
            title => "No emoji found for '$search'",
            subtitle => "Try a different search term",
            valid => JSON::PP::false
        };
    } elsif (@new_keywords == 0) {
        # Show matches, prompt for keyword
        for my $e (@matches[0..min(9, $#matches)]) {
            my $existing = $custom_keywords{$e->[0]} // [];
            my $custom_str = @$existing ? " [custom: " . join(", ", @$existing) . "]" : "";
            push @items, {
                title => "$e->[0]  $e->[1]",
                subtitle => "Add keyword after emoji search (e.g., '$search mykeyword')$custom_str",
                valid => JSON::PP::false,
                icon => { path => "icon.png" }
            };
        }
    } else {
        # Show what will be added
        for my $e (@matches[0..min(4, $#matches)]) {
            my $keywords_str = join(", ", @new_keywords);
            my $existing = $custom_keywords{$e->[0]} // [];
            my @all_new = (@$existing, @new_keywords);

            # Use a simple delimiter format to avoid nested JSON encoding issues
            my $arg_str = $e->[0] . "|" . join(",", @new_keywords);
            push @items, {
                uid => $e->[0],
                title => "$e->[0]  Add: $keywords_str",
                subtitle => "Press ↩ to add keyword(s) to $e->[1]",
                arg => $arg_str,
                valid => JSON::PP::true,
                icon => { path => "icon.png" }
            };
        }
    }
}

my $output = { items => \@items };
print encode_json($output) . "\n";

sub min { $_[0] < $_[1] ? $_[0] : $_[1] }
