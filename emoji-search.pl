#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use JSON::PP;
use Encode qw(encode_utf8);
use File::Spec;

binmode STDOUT, ':raw';

my $query = lc(join(' ', @ARGV) // '');
$query =~ s/^\s+|\s+$//g;

# Load custom keywords from config file
my $config_dir = File::Spec->catdir($ENV{HOME}, '.config', 'semoji');
my $config_file = File::Spec->catfile($config_dir, 'custom.json');
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

my @emojis = (
    # Smileys & Emotion
    ['😀', 'Grinning Face', ['happy', 'smile', 'joy', 'cheerful', 'glad', 'pleased', 'delighted']],
    ['😃', 'Grinning Face with Big Eyes', ['happy', 'smile', 'joy', 'excited', 'eager']],
    ['😄', 'Grinning Face with Smiling Eyes', ['happy', 'smile', 'joy', 'laugh', 'pleased']],
    ['😁', 'Beaming Face', ['happy', 'smile', 'grin', 'excited', 'cheerful']],
    ['😅', 'Grinning Face with Sweat', ['nervous', 'awkward', 'relief', 'phew', 'sweat']],
    ['😂', 'Face with Tears of Joy', ['laugh', 'funny', 'hilarious', 'lol', 'lmao', 'crying laughing', 'haha']],
    ['🤣', 'Rolling on the Floor Laughing', ['laugh', 'funny', 'hilarious', 'rofl', 'lmao']],
    ['😊', 'Smiling Face with Smiling Eyes', ['happy', 'blush', 'pleased', 'content', 'warm']],
    ['😇', 'Smiling Face with Halo', ['angel', 'innocent', 'blessed', 'holy', 'good']],
    ['🙂', 'Slightly Smiling Face', ['okay', 'fine', 'subtle', 'mild', 'pleasant']],
    ['🙃', 'Upside-Down Face', ['sarcasm', 'silly', 'irony', 'goofy', 'playful']],
    ['😉', 'Winking Face', ['wink', 'flirt', 'joke', 'playful', 'hint']],
    ['😌', 'Relieved Face', ['relieved', 'peaceful', 'calm', 'content', 'relaxed']],
    ['😍', 'Smiling Face with Heart-Eyes', ['love', 'crush', 'adore', 'infatuation', 'heart eyes']],
    ['🥰', 'Smiling Face with Hearts', ['love', 'affection', 'adore', 'grateful', 'blessed']],
    ['😘', 'Face Blowing a Kiss', ['kiss', 'love', 'flirt', 'romantic', 'mwah']],
    ['😗', 'Kissing Face', ['kiss', 'whistle', 'smooch']],
    ['😙', 'Kissing Face with Smiling Eyes', ['kiss', 'affection', 'happy kiss']],
    ['😚', 'Kissing Face with Closed Eyes', ['kiss', 'love', 'affection', 'peck']],
    ['😋', 'Face Savoring Food', ['yummy', 'delicious', 'tasty', 'food', 'hungry']],
    ['😛', 'Face with Tongue', ['tongue', 'playful', 'silly', 'tease', 'bleh']],
    ['😜', 'Winking Face with Tongue', ['tongue', 'wink', 'playful', 'silly', 'crazy']],
    ['🤪', 'Zany Face', ['crazy', 'wild', 'goofy', 'silly', 'wacky']],
    ['😝', 'Squinting Face with Tongue', ['tongue', 'playful', 'silly', 'gross', 'eww']],
    ['🤑', 'Money-Mouth Face', ['money', 'rich', 'dollar', 'wealth', 'greedy', 'cash']],
    ['🤗', 'Hugging Face', ['hug', 'embrace', 'warm', 'friendly', 'welcoming']],
    ['🤭', 'Face with Hand Over Mouth', ['oops', 'giggle', 'shy', 'secret', 'tee-hee']],
    ['🤫', 'Shushing Face', ['quiet', 'shush', 'secret', 'silence', 'hush']],
    ['🤔', 'Thinking Face', ['think', 'hmm', 'wonder', 'consider', 'ponder', 'curious']],
    ['🤐', 'Zipper-Mouth Face', ['secret', 'quiet', 'mute', 'lips sealed', 'confidential']],
    ['🤨', 'Face with Raised Eyebrow', ['skeptical', 'suspicious', 'doubt', 'really', 'hmm']],
    ['😐', 'Neutral Face', ['neutral', 'meh', 'indifferent', 'blank', 'expressionless']],
    ['😑', 'Expressionless Face', ['blank', 'meh', 'unimpressed', 'deadpan']],
    ['😶', 'Face Without Mouth', ['speechless', 'silent', 'mute', 'no comment']],
    ['😏', 'Smirking Face', ['smirk', 'smug', 'flirt', 'suggestive', 'sly']],
    ['😒', 'Unamused Face', ['unamused', 'annoyed', 'bored', 'meh', 'whatever']],
    ['🙄', 'Face with Rolling Eyes', ['eye roll', 'annoyed', 'frustrated', 'whatever', 'duh']],
    ['😬', 'Grimacing Face', ['awkward', 'nervous', 'tense', 'cringe', 'yikes']],
    ['😮‍💨', 'Face Exhaling', ['sigh', 'relief', 'exhale', 'tired', 'phew']],
    ['🤥', 'Lying Face', ['lie', 'pinocchio', 'dishonest', 'fib']],
    ['😔', 'Pensive Face', ['sad', 'pensive', 'disappointed', 'reflective']],
    ['😪', 'Sleepy Face', ['sleepy', 'tired', 'drowsy', 'exhausted']],
    ['🤤', 'Drooling Face', ['drool', 'hungry', 'desire', 'want', 'yummy']],
    ['😴', 'Sleeping Face', ['sleep', 'tired', 'zzz', 'nap', 'rest', 'snore']],
    ['😷', 'Face with Medical Mask', ['sick', 'mask', 'ill', 'covid', 'medical', 'health']],
    ['🤒', 'Face with Thermometer', ['sick', 'fever', 'ill', 'temperature', 'unwell']],
    ['🤕', 'Face with Head-Bandage', ['hurt', 'injured', 'bandage', 'pain', 'accident']],
    ['🤢', 'Nauseated Face', ['sick', 'nausea', 'gross', 'disgusted', 'queasy', 'vomit']],
    ['🤮', 'Face Vomiting', ['vomit', 'sick', 'puke', 'gross', 'disgusting']],
    ['🤧', 'Sneezing Face', ['sneeze', 'sick', 'cold', 'allergies', 'achoo']],
    ['🥵', 'Hot Face', ['hot', 'heat', 'sweating', 'warm', 'temperature']],
    ['🥶', 'Cold Face', ['cold', 'freezing', 'frozen', 'ice', 'chilly']],
    ['🥴', 'Woozy Face', ['drunk', 'dizzy', 'woozy', 'tipsy', 'intoxicated']],
    ['😵', 'Face with Crossed-Out Eyes', ['dizzy', 'dead', 'shocked', 'overwhelmed']],
    ['😵‍💫', 'Face with Spiral Eyes', ['dizzy', 'hypnotized', 'disoriented', 'confused']],
    ['🤯', 'Exploding Head', ['mind blown', 'shocked', 'amazed', 'wow', 'unbelievable']],
    ['🤠', 'Cowboy Hat Face', ['cowboy', 'western', 'yeehaw', 'country', 'hat']],
    ['🥳', 'Partying Face', ['party', 'celebrate', 'birthday', 'fun', 'festive', 'congratulations']],
    ['🥸', 'Disguised Face', ['disguise', 'incognito', 'hidden', 'spy', 'glasses']],
    ['😎', 'Smiling Face with Sunglasses', ['cool', 'sunglasses', 'awesome', 'confident', 'chill']],
    ['🤓', 'Nerd Face', ['nerd', 'geek', 'smart', 'glasses', 'studious']],
    ['🧐', 'Face with Monocle', ['fancy', 'curious', 'investigate', 'inspect', 'hmm']],
    ['😕', 'Confused Face', ['confused', 'puzzled', 'unsure', 'uncertain']],
    ['😟', 'Worried Face', ['worried', 'concerned', 'anxious', 'nervous']],
    ['🙁', 'Slightly Frowning Face', ['sad', 'frown', 'disappointed', 'unhappy']],
    ['☹️', 'Frowning Face', ['sad', 'frown', 'unhappy', 'disappointed']],
    ['😮', 'Face with Open Mouth', ['surprised', 'wow', 'shocked', 'amazed']],
    ['😯', 'Hushed Face', ['surprised', 'stunned', 'speechless', 'wow']],
    ['😲', 'Astonished Face', ['astonished', 'shocked', 'amazed', 'wow', 'omg']],
    ['😳', 'Flushed Face', ['embarrassed', 'flushed', 'shy', 'awkward', 'blush']],
    ['🥺', 'Pleading Face', ['please', 'puppy eyes', 'beg', 'cute', 'sad', 'uwu']],
    ['😦', 'Frowning Face with Open Mouth', ['sad', 'shocked', 'disappointed']],
    ['😧', 'Anguished Face', ['anguish', 'shocked', 'horrified', 'distressed']],
    ['😨', 'Fearful Face', ['fear', 'scared', 'afraid', 'terrified', 'shock']],
    ['😰', 'Anxious Face with Sweat', ['anxious', 'nervous', 'worried', 'stressed', 'sweat']],
    ['😥', 'Sad but Relieved Face', ['sad', 'relieved', 'disappointed', 'sweat']],
    ['😢', 'Crying Face', ['cry', 'sad', 'tear', 'unhappy', 'upset']],
    ['😭', 'Loudly Crying Face', ['cry', 'sobbing', 'sad', 'tears', 'bawling', 'wailing']],
    ['😱', 'Face Screaming in Fear', ['scream', 'fear', 'horror', 'shocked', 'scared', 'omg']],
    ['😖', 'Confounded Face', ['frustrated', 'confused', 'upset', 'stressed']],
    ['😣', 'Persevering Face', ['struggle', 'frustrated', 'trying', 'effort']],
    ['😞', 'Disappointed Face', ['disappointed', 'sad', 'let down', 'unhappy']],
    ['😓', 'Downcast Face with Sweat', ['disappointed', 'sad', 'sweat', 'hard work']],
    ['😩', 'Weary Face', ['tired', 'weary', 'frustrated', 'exhausted', 'fed up']],
    ['😫', 'Tired Face', ['tired', 'exhausted', 'frustrated', 'sleepy']],
    ['🥱', 'Yawning Face', ['yawn', 'tired', 'sleepy', 'bored', 'boring']],
    ['😤', 'Face with Steam From Nose', ['angry', 'frustrated', 'triumph', 'huffing']],
    ['😡', 'Pouting Face', ['angry', 'mad', 'furious', 'rage', 'pout']],
    ['😠', 'Angry Face', ['angry', 'mad', 'annoyed', 'grumpy']],
    ['🤬', 'Face with Symbols on Mouth', ['swear', 'curse', 'angry', 'censored', 'expletive']],
    ['😈', 'Smiling Face with Horns', ['devil', 'evil', 'mischief', 'naughty', 'trouble']],
    ['👿', 'Angry Face with Horns', ['devil', 'angry', 'evil', 'imp']],
    ['💀', 'Skull', ['dead', 'death', 'skeleton', 'scary', 'halloween', 'rip']],
    ['☠️', 'Skull and Crossbones', ['death', 'danger', 'poison', 'pirate', 'toxic']],
    ['💩', 'Pile of Poo', ['poop', 'crap', 'shit', 'funny', 'gross']],
    ['🤡', 'Clown Face', ['clown', 'fool', 'circus', 'funny', 'joke']],
    ['👹', 'Ogre', ['monster', 'scary', 'japanese', 'oni', 'demon']],
    ['👺', 'Goblin', ['monster', 'japanese', 'tengu', 'demon']],
    ['👻', 'Ghost', ['ghost', 'halloween', 'spooky', 'scary', 'boo']],
    ['👽', 'Alien', ['alien', 'ufo', 'space', 'extraterrestrial', 'et']],
    ['👾', 'Alien Monster', ['alien', 'game', 'space invaders', 'pixel', 'arcade']],
    ['🤖', 'Robot', ['robot', 'bot', 'machine', 'ai', 'android', 'technology']],
    ['😺', 'Smiling Cat', ['cat', 'happy', 'smile', 'pet']],
    ['😸', 'Grinning Cat', ['cat', 'happy', 'grin', 'pet']],
    ['😹', 'Cat with Tears of Joy', ['cat', 'laugh', 'funny', 'pet']],
    ['😻', 'Smiling Cat with Heart-Eyes', ['cat', 'love', 'heart eyes', 'pet']],
    ['😼', 'Cat with Wry Smile', ['cat', 'smirk', 'sly', 'pet']],
    ['😽', 'Kissing Cat', ['cat', 'kiss', 'love', 'pet']],
    ['🙀', 'Weary Cat', ['cat', 'shocked', 'scared', 'pet']],
    ['😿', 'Crying Cat', ['cat', 'sad', 'cry', 'pet']],
    ['😾', 'Pouting Cat', ['cat', 'angry', 'grumpy', 'pet']],
    ['🙈', 'See-No-Evil Monkey', ['monkey', 'hide', 'shy', 'embarrassed', "don't look"]],
    ['🙉', 'Hear-No-Evil Monkey', ['monkey', 'ignore', 'not listening', 'la la la']],
    ['🙊', 'Speak-No-Evil Monkey', ['monkey', 'secret', 'oops', 'quiet', 'shh']],

    # Gestures & Body Parts
    ['👋', 'Waving Hand', ['wave', 'hello', 'hi', 'bye', 'goodbye', 'greeting']],
    ['🤚', 'Raised Back of Hand', ['hand', 'stop', 'high five']],
    ['🖐️', 'Hand with Fingers Splayed', ['hand', 'five', 'stop', 'high five']],
    ['✋', 'Raised Hand', ['hand', 'stop', 'high five', 'halt']],
    ['🖖', 'Vulcan Salute', ['spock', 'star trek', 'live long', 'prosper']],
    ['👌', 'OK Hand', ['ok', 'okay', 'perfect', 'good', 'nice', 'fine']],
    ['🤌', 'Pinched Fingers', ['italian', 'perfection', 'chef kiss', 'what do you want']],
    ['🤏', 'Pinching Hand', ['small', 'tiny', 'little', 'pinch', 'bit']],
    ['✌️', 'Victory Hand', ['peace', 'victory', 'two', 'v sign']],
    ['🤞', 'Crossed Fingers', ['luck', 'hope', 'fingers crossed', 'wish']],
    ['🤟', 'Love-You Gesture', ['love', 'ily', 'rock', 'sign language']],
    ['🤘', 'Sign of the Horns', ['rock', 'metal', 'horns', 'rock on', 'party']],
    ['🤙', 'Call Me Hand', ['call', 'shaka', 'hang loose', 'phone', 'surf']],
    ['👈', 'Backhand Index Pointing Left', ['point', 'left', 'direction', 'that way']],
    ['👉', 'Backhand Index Pointing Right', ['point', 'right', 'direction', 'this way']],
    ['👆', 'Backhand Index Pointing Up', ['point', 'up', 'direction', 'above']],
    ['🖕', 'Middle Finger', ['middle finger', 'fuck', 'flip off', 'rude', 'angry']],
    ['👇', 'Backhand Index Pointing Down', ['point', 'down', 'direction', 'below']],
    ['☝️', 'Index Pointing Up', ['point', 'up', 'one', 'wait', 'important']],
    ['👍', 'Thumbs Up', ['good', 'yes', 'ok', 'approve', 'like', 'agree', 'nice']],
    ['👎', 'Thumbs Down', ['bad', 'no', 'dislike', 'disapprove', 'disagree', 'boo']],
    ['✊', 'Raised Fist', ['fist', 'power', 'solidarity', 'punch', 'strong']],
    ['👊', 'Oncoming Fist', ['fist bump', 'punch', 'bro', 'power']],
    ['🤛', 'Left-Facing Fist', ['fist bump', 'punch', 'left']],
    ['🤜', 'Right-Facing Fist', ['fist bump', 'punch', 'right']],
    ['👏', 'Clapping Hands', ['clap', 'applause', 'bravo', 'congratulations', 'well done']],
    ['🙌', 'Raising Hands', ['celebrate', 'praise', 'hooray', 'yay', 'hallelujah']],
    ['👐', 'Open Hands', ['open', 'hands', 'hug', 'jazz hands']],
    ['🤲', 'Palms Up Together', ['prayer', 'please', 'give', 'receive']],
    ['🤝', 'Handshake', ['handshake', 'deal', 'agreement', 'meeting', 'partnership']],
    ['🙏', 'Folded Hands', ['pray', 'please', 'thank you', 'hope', 'namaste', 'grateful']],
    ['✍️', 'Writing Hand', ['write', 'writing', 'sign', 'signature']],
    ['💅', 'Nail Polish', ['nails', 'beauty', 'fabulous', 'sassy', 'glamour']],
    ['🤳', 'Selfie', ['selfie', 'photo', 'camera', 'phone', 'picture']],
    ['💪', 'Flexed Biceps', ['strong', 'muscle', 'power', 'strength', 'gym', 'workout', 'flex']],
    ['🦾', 'Mechanical Arm', ['robot', 'prosthetic', 'strong', 'cyborg']],
    ['🦿', 'Mechanical Leg', ['robot', 'prosthetic', 'cyborg']],
    ['🦵', 'Leg', ['leg', 'kick', 'limb']],
    ['🦶', 'Foot', ['foot', 'kick', 'stomp']],
    ['👂', 'Ear', ['ear', 'hear', 'listen', 'sound']],
    ['🦻', 'Ear with Hearing Aid', ['deaf', 'hearing aid', 'accessibility']],
    ['👃', 'Nose', ['nose', 'smell', 'sniff']],
    ['🧠', 'Brain', ['brain', 'smart', 'think', 'intelligence', 'mind']],
    ['👀', 'Eyes', ['eyes', 'look', 'see', 'watch', 'stare', 'looking']],
    ['👁️', 'Eye', ['eye', 'see', 'look', 'watch']],
    ['👅', 'Tongue', ['tongue', 'taste', 'lick']],
    ['👄', 'Mouth', ['mouth', 'lips', 'kiss']],

    # Hearts & Love
    ['💋', 'Kiss Mark', ['kiss', 'lips', 'love', 'lipstick', 'smooch']],
    ['❤️', 'Red Heart', ['love', 'heart', 'romance', 'like', 'favorite']],
    ['🧡', 'Orange Heart', ['love', 'heart', 'orange', 'friendship']],
    ['💛', 'Yellow Heart', ['love', 'heart', 'yellow', 'friendship', 'happiness']],
    ['💚', 'Green Heart', ['love', 'heart', 'green', 'nature', 'jealousy']],
    ['💙', 'Blue Heart', ['love', 'heart', 'blue', 'trust', 'loyalty']],
    ['💜', 'Purple Heart', ['love', 'heart', 'purple', 'sensitive', 'bts']],
    ['🖤', 'Black Heart', ['love', 'heart', 'black', 'dark', 'emo', 'goth']],
    ['🤍', 'White Heart', ['love', 'heart', 'white', 'pure', 'clean']],
    ['🤎', 'Brown Heart', ['love', 'heart', 'brown', 'nature']],
    ['💔', 'Broken Heart', ['heartbreak', 'sad', 'breakup', 'hurt', 'pain']],
    ['❤️‍🔥', 'Heart on Fire', ['love', 'passion', 'lust', 'burning', 'desire']],
    ['❤️‍🩹', 'Mending Heart', ['healing', 'recovery', 'getting better', 'health']],
    ['❣️', 'Heart Exclamation', ['love', 'heart', 'exclamation', 'emphasis']],
    ['💕', 'Two Hearts', ['love', 'hearts', 'romance', 'couple']],
    ['💞', 'Revolving Hearts', ['love', 'hearts', 'romance', 'falling in love']],
    ['💓', 'Beating Heart', ['love', 'heartbeat', 'alive', 'excited']],
    ['💗', 'Growing Heart', ['love', 'heart', 'growing', 'affection']],
    ['💖', 'Sparkling Heart', ['love', 'heart', 'sparkle', 'excited', 'shiny']],
    ['💘', 'Heart with Arrow', ['love', 'cupid', 'romance', 'valentine']],
    ['💝', 'Heart with Ribbon', ['love', 'gift', 'present', 'valentine']],
    ['💟', 'Heart Decoration', ['love', 'heart', 'decoration']],

    # Celebrations & Objects
    ['🎉', 'Party Popper', ['party', 'celebrate', 'congratulations', 'birthday', 'new year', 'confetti']],
    ['🎊', 'Confetti Ball', ['party', 'celebrate', 'confetti', 'festive']],
    ['🎈', 'Balloon', ['party', 'balloon', 'birthday', 'celebration']],
    ['🎁', 'Wrapped Gift', ['gift', 'present', 'birthday', 'christmas', 'surprise']],
    ['🎂', 'Birthday Cake', ['birthday', 'cake', 'celebration', 'party']],
    ['🎄', 'Christmas Tree', ['christmas', 'tree', 'holiday', 'xmas', 'december']],
    ['🎃', 'Jack-O-Lantern', ['halloween', 'pumpkin', 'spooky', 'october']],
    ['🎆', 'Fireworks', ['fireworks', 'celebration', 'new year', 'july 4th']],
    ['🎇', 'Sparkler', ['sparkler', 'fireworks', 'celebration']],
    ['✨', 'Sparkles', ['sparkle', 'shine', 'magic', 'special', 'clean', 'new', 'star']],
    ['🎀', 'Ribbon', ['ribbon', 'gift', 'present', 'bow', 'cute']],
    ['🏆', 'Trophy', ['trophy', 'winner', 'award', 'champion', 'first place', 'success']],
    ['🥇', '1st Place Medal', ['gold', 'first', 'winner', 'medal', 'champion']],
    ['🥈', '2nd Place Medal', ['silver', 'second', 'medal', 'runner up']],
    ['🥉', '3rd Place Medal', ['bronze', 'third', 'medal']],
    ['🏅', 'Sports Medal', ['medal', 'sports', 'winner', 'achievement']],
    ['🎖️', 'Military Medal', ['medal', 'military', 'honor', 'award']],

    # Weather & Nature
    ['☀️', 'Sun', ['sun', 'sunny', 'weather', 'hot', 'summer', 'bright']],
    ['🌙', 'Crescent Moon', ['moon', 'night', 'sleep', 'dark', 'crescent']],
    ['⭐', 'Star', ['star', 'favorite', 'rating', 'sky', 'night']],
    ['🌟', 'Glowing Star', ['star', 'glow', 'sparkle', 'shiny', 'special']],
    ['💫', 'Dizzy', ['dizzy', 'star', 'shooting star', 'sparkle']],
    ['🌈', 'Rainbow', ['rainbow', 'colorful', 'pride', 'lgbtq', 'colors']],
    ['☁️', 'Cloud', ['cloud', 'weather', 'sky', 'cloudy']],
    ['⛈️', 'Cloud with Lightning and Rain', ['storm', 'thunder', 'lightning', 'rain', 'weather']],
    ['🌧️', 'Cloud with Rain', ['rain', 'rainy', 'weather', 'cloud']],
    ['❄️', 'Snowflake', ['snow', 'cold', 'winter', 'frozen', 'ice']],
    ['🔥', 'Fire', ['fire', 'hot', 'lit', 'flame', 'burn', 'awesome', 'trending']],
    ['💧', 'Droplet', ['water', 'drop', 'rain', 'tear', 'sweat']],
    ['🌊', 'Water Wave', ['wave', 'ocean', 'sea', 'water', 'surf', 'beach']],

    # Plants
    ['🌸', 'Cherry Blossom', ['flower', 'cherry', 'blossom', 'spring', 'pink', 'japan']],
    ['🌺', 'Hibiscus', ['flower', 'tropical', 'hawaii', 'pink']],
    ['🌻', 'Sunflower', ['flower', 'sunflower', 'yellow', 'summer', 'sun']],
    ['🌹', 'Rose', ['flower', 'rose', 'love', 'romance', 'red', 'valentine']],
    ['🌷', 'Tulip', ['flower', 'tulip', 'spring', 'pink']],
    ['🌱', 'Seedling', ['plant', 'seedling', 'growth', 'new', 'sprout', 'garden']],
    ['🌲', 'Evergreen Tree', ['tree', 'evergreen', 'pine', 'forest', 'nature']],
    ['🌳', 'Deciduous Tree', ['tree', 'nature', 'forest', 'green']],
    ['🌴', 'Palm Tree', ['palm', 'tree', 'tropical', 'beach', 'vacation']],
    ['🌵', 'Cactus', ['cactus', 'desert', 'plant', 'succulent']],
    ['🍀', 'Four Leaf Clover', ['clover', 'luck', 'lucky', 'irish', 'st patrick']],
    ['🍁', 'Maple Leaf', ['maple', 'leaf', 'fall', 'autumn', 'canada']],
    ['🍂', 'Fallen Leaf', ['leaf', 'fall', 'autumn', 'nature']],
    ['🍃', 'Leaf Fluttering in Wind', ['leaf', 'wind', 'nature', 'green']],

    # Animals
    ['🐶', 'Dog Face', ['dog', 'puppy', 'pet', 'cute', 'animal']],
    ['🐱', 'Cat Face', ['cat', 'kitty', 'pet', 'cute', 'animal', 'meow']],
    ['🐭', 'Mouse Face', ['mouse', 'animal', 'cute', 'rodent']],
    ['🐹', 'Hamster', ['hamster', 'pet', 'cute', 'rodent']],
    ['🐰', 'Rabbit Face', ['rabbit', 'bunny', 'pet', 'cute', 'easter']],
    ['🦊', 'Fox', ['fox', 'animal', 'clever', 'cute']],
    ['🐻', 'Bear', ['bear', 'animal', 'cute', 'teddy']],
    ['🐼', 'Panda', ['panda', 'bear', 'animal', 'cute', 'china']],
    ['🐨', 'Koala', ['koala', 'animal', 'cute', 'australia']],
    ['🐯', 'Tiger Face', ['tiger', 'animal', 'cat', 'wild']],
    ['🦁', 'Lion', ['lion', 'animal', 'king', 'wild', 'cat']],
    ['🐮', 'Cow Face', ['cow', 'animal', 'farm', 'moo']],
    ['🐷', 'Pig Face', ['pig', 'animal', 'farm', 'oink']],
    ['🐸', 'Frog', ['frog', 'animal', 'amphibian', 'pepe']],
    ['🐵', 'Monkey Face', ['monkey', 'animal', 'ape', 'primate']],
    ['🐔', 'Chicken', ['chicken', 'animal', 'bird', 'farm']],
    ['🐧', 'Penguin', ['penguin', 'animal', 'bird', 'cold', 'linux']],
    ['🐦', 'Bird', ['bird', 'animal', 'fly', 'tweet']],
    ['🦅', 'Eagle', ['eagle', 'bird', 'america', 'freedom']],
    ['🦆', 'Duck', ['duck', 'bird', 'animal', 'quack']],
    ['🦉', 'Owl', ['owl', 'bird', 'wise', 'night']],
    ['🐺', 'Wolf', ['wolf', 'animal', 'wild', 'howl']],
    ['🐗', 'Boar', ['boar', 'pig', 'wild', 'animal']],
    ['🐴', 'Horse Face', ['horse', 'animal', 'pony']],
    ['🦄', 'Unicorn', ['unicorn', 'magic', 'fantasy', 'mythical', 'horse']],
    ['🐝', 'Bee', ['bee', 'insect', 'honey', 'buzz']],
    ['🐛', 'Bug', ['bug', 'insect', 'caterpillar']],
    ['🦋', 'Butterfly', ['butterfly', 'insect', 'pretty', 'nature']],
    ['🐌', 'Snail', ['snail', 'slow', 'animal']],
    ['🐙', 'Octopus', ['octopus', 'sea', 'ocean', 'tentacles']],
    ['🦀', 'Crab', ['crab', 'sea', 'ocean', 'zodiac', 'cancer']],
    ['🐠', 'Tropical Fish', ['fish', 'tropical', 'ocean', 'sea']],
    ['🐟', 'Fish', ['fish', 'ocean', 'sea', 'animal']],
    ['🐬', 'Dolphin', ['dolphin', 'ocean', 'sea', 'smart', 'flipper']],
    ['🐳', 'Spouting Whale', ['whale', 'ocean', 'sea', 'big']],
    ['🦈', 'Shark', ['shark', 'ocean', 'dangerous', 'jaws']],
    ['🐊', 'Crocodile', ['crocodile', 'alligator', 'reptile']],
    ['🐢', 'Turtle', ['turtle', 'slow', 'reptile', 'shell']],
    ['🦎', 'Lizard', ['lizard', 'reptile', 'gecko']],
    ['🐍', 'Snake', ['snake', 'reptile', 'slither']],
    ['🦖', 'T-Rex', ['dinosaur', 't-rex', 'jurassic', 'extinct']],
    ['🦕', 'Sauropod', ['dinosaur', 'long neck', 'jurassic', 'extinct']],

    # Food & Drink
    ['🍎', 'Red Apple', ['apple', 'fruit', 'healthy', 'red', 'teacher']],
    ['🍊', 'Tangerine', ['orange', 'fruit', 'citrus']],
    ['🍋', 'Lemon', ['lemon', 'fruit', 'citrus', 'sour', 'yellow']],
    ['🍌', 'Banana', ['banana', 'fruit', 'yellow']],
    ['🍉', 'Watermelon', ['watermelon', 'fruit', 'summer']],
    ['🍇', 'Grapes', ['grapes', 'fruit', 'wine', 'purple']],
    ['🍓', 'Strawberry', ['strawberry', 'fruit', 'berry', 'red']],
    ['🍑', 'Peach', ['peach', 'fruit', 'butt', 'booty']],
    ['🍒', 'Cherries', ['cherry', 'cherries', 'fruit', 'red']],
    ['🥑', 'Avocado', ['avocado', 'fruit', 'guacamole', 'healthy', 'millennial']],
    ['🥕', 'Carrot', ['carrot', 'vegetable', 'orange', 'healthy']],
    ['🌽', 'Ear of Corn', ['corn', 'vegetable', 'cob']],
    ['🌶️', 'Hot Pepper', ['pepper', 'hot', 'spicy', 'chili']],
    ['🥒', 'Cucumber', ['cucumber', 'vegetable', 'pickle']],
    ['🥬', 'Leafy Green', ['lettuce', 'salad', 'vegetable', 'healthy', 'green']],
    ['🥦', 'Broccoli', ['broccoli', 'vegetable', 'healthy', 'green']],
    ['🍄', 'Mushroom', ['mushroom', 'fungus', 'toadstool']],
    ['🥜', 'Peanuts', ['peanut', 'nut', 'legume']],
    ['🍞', 'Bread', ['bread', 'toast', 'loaf', 'carbs']],
    ['🥐', 'Croissant', ['croissant', 'bread', 'french', 'pastry']],
    ['🥖', 'Baguette Bread', ['baguette', 'bread', 'french']],
    ['🧀', 'Cheese Wedge', ['cheese', 'dairy', 'cheddar']],
    ['🍳', 'Cooking', ['egg', 'cooking', 'breakfast', 'fried']],
    ['🥞', 'Pancakes', ['pancakes', 'breakfast', 'syrup']],
    ['🥓', 'Bacon', ['bacon', 'meat', 'breakfast', 'pork']],
    ['🍔', 'Hamburger', ['burger', 'hamburger', 'fast food', 'beef']],
    ['🍟', 'French Fries', ['fries', 'french fries', 'fast food', 'potato']],
    ['🍕', 'Pizza', ['pizza', 'italian', 'fast food', 'slice']],
    ['🌭', 'Hot Dog', ['hot dog', 'sausage', 'fast food']],
    ['🥪', 'Sandwich', ['sandwich', 'lunch', 'bread']],
    ['🌮', 'Taco', ['taco', 'mexican', 'food', 'tuesday']],
    ['🌯', 'Burrito', ['burrito', 'mexican', 'wrap']],
    ['🍜', 'Steaming Bowl', ['noodles', 'ramen', 'soup', 'asian', 'pho']],
    ['🍝', 'Spaghetti', ['spaghetti', 'pasta', 'italian', 'noodles']],
    ['🍣', 'Sushi', ['sushi', 'japanese', 'fish', 'rice']],
    ['🍤', 'Fried Shrimp', ['shrimp', 'tempura', 'seafood']],
    ['🍦', 'Soft Ice Cream', ['ice cream', 'dessert', 'sweet', 'cone']],
    ['🍩', 'Doughnut', ['donut', 'doughnut', 'dessert', 'sweet']],
    ['🍪', 'Cookie', ['cookie', 'dessert', 'sweet', 'biscuit']],
    ['🍰', 'Shortcake', ['cake', 'dessert', 'strawberry', 'sweet']],
    ['🧁', 'Cupcake', ['cupcake', 'dessert', 'sweet', 'muffin']],
    ['🍫', 'Chocolate Bar', ['chocolate', 'candy', 'sweet', 'dessert']],
    ['🍬', 'Candy', ['candy', 'sweet', 'sugar']],
    ['🍭', 'Lollipop', ['lollipop', 'candy', 'sweet']],
    ['☕', 'Hot Beverage', ['coffee', 'tea', 'hot', 'drink', 'cafe', 'morning']],
    ['🍵', 'Teacup', ['tea', 'green tea', 'hot', 'drink', 'japanese']],
    ['🍺', 'Beer Mug', ['beer', 'drink', 'alcohol', 'cheers']],
    ['🍻', 'Clinking Beer Mugs', ['beer', 'cheers', 'drink', 'alcohol', 'toast']],
    ['🥂', 'Clinking Glasses', ['champagne', 'cheers', 'toast', 'celebration', 'wine']],
    ['🍷', 'Wine Glass', ['wine', 'drink', 'alcohol', 'red wine']],
    ['🍸', 'Cocktail Glass', ['cocktail', 'martini', 'drink', 'alcohol']],
    ['🍹', 'Tropical Drink', ['cocktail', 'tropical', 'drink', 'vacation']],
    ['🧃', 'Beverage Box', ['juice', 'juice box', 'drink']],
    ['🧋', 'Bubble Tea', ['boba', 'bubble tea', 'drink', 'taiwanese']],

    # Activities & Sports
    ['⚽', 'Soccer Ball', ['soccer', 'football', 'ball', 'sport']],
    ['🏀', 'Basketball', ['basketball', 'ball', 'sport', 'nba']],
    ['🏈', 'American Football', ['football', 'american', 'sport', 'nfl']],
    ['⚾', 'Baseball', ['baseball', 'ball', 'sport', 'mlb']],
    ['🎾', 'Tennis', ['tennis', 'ball', 'sport', 'racket']],
    ['🏐', 'Volleyball', ['volleyball', 'ball', 'sport', 'beach']],
    ['🏉', 'Rugby Football', ['rugby', 'ball', 'sport']],
    ['🎱', 'Pool 8 Ball', ['pool', 'billiards', '8 ball', 'game']],
    ['🏓', 'Ping Pong', ['ping pong', 'table tennis', 'sport']],
    ['🏸', 'Badminton', ['badminton', 'shuttlecock', 'sport']],
    ['🥊', 'Boxing Glove', ['boxing', 'fight', 'sport', 'punch']],
    ['🥋', 'Martial Arts Uniform', ['martial arts', 'karate', 'judo', 'taekwondo']],
    ['⛳', 'Flag in Hole', ['golf', 'sport', 'hole']],
    ['⛷️', 'Skier', ['ski', 'skiing', 'winter', 'sport', 'snow']],
    ['🏂', 'Snowboarder', ['snowboard', 'winter', 'sport', 'snow']],
    ['🏄', 'Person Surfing', ['surf', 'surfing', 'beach', 'wave', 'ocean']],
    ['🏊', 'Person Swimming', ['swim', 'swimming', 'pool', 'water']],
    ['🚴', 'Person Biking', ['bike', 'bicycle', 'cycling', 'sport']],
    ['🧘', 'Person in Lotus Position', ['yoga', 'meditation', 'zen', 'mindfulness', 'calm']],
    ['🎮', 'Video Game', ['game', 'gaming', 'video game', 'controller', 'play']],
    ['🕹️', 'Joystick', ['game', 'arcade', 'joystick', 'retro']],
    ['🎲', 'Game Die', ['dice', 'game', 'random', 'chance', 'gambling']],
    ['🧩', 'Puzzle Piece', ['puzzle', 'game', 'piece', 'jigsaw']],
    ['♟️', 'Chess Pawn', ['chess', 'game', 'strategy', 'pawn']],
    ['🎯', 'Direct Hit', ['target', 'bullseye', 'goal', 'aim', 'dart']],
    ['🎳', 'Bowling', ['bowling', 'sport', 'pins', 'ball']],
    ['🎰', 'Slot Machine', ['slot', 'casino', 'gambling', 'jackpot']],

    # Travel & Places
    ['🚗', 'Automobile', ['car', 'vehicle', 'drive', 'road', 'auto']],
    ['🚕', 'Taxi', ['taxi', 'cab', 'car', 'uber', 'lyft']],
    ['🚌', 'Bus', ['bus', 'vehicle', 'public transport', 'school']],
    ['🚎', 'Trolleybus', ['trolley', 'bus', 'tram', 'transport']],
    ['🏎️', 'Racing Car', ['race car', 'fast', 'formula 1', 'speed']],
    ['🚓', 'Police Car', ['police', 'cop', 'car', 'emergency']],
    ['🚑', 'Ambulance', ['ambulance', 'emergency', 'hospital', 'medical']],
    ['🚒', 'Fire Engine', ['fire truck', 'fire', 'emergency', 'firefighter']],
    ['🚲', 'Bicycle', ['bike', 'bicycle', 'cycling', 'pedal']],
    ['🛵', 'Motor Scooter', ['scooter', 'moped', 'vespa']],
    ['🏍️', 'Motorcycle', ['motorcycle', 'bike', 'harley']],
    ['✈️', 'Airplane', ['plane', 'airplane', 'flight', 'travel', 'fly']],
    ['🚀', 'Rocket', ['rocket', 'space', 'launch', 'fast', 'startup']],
    ['🛸', 'Flying Saucer', ['ufo', 'alien', 'space', 'flying saucer']],
    ['🚁', 'Helicopter', ['helicopter', 'chopper', 'fly']],
    ['🛶', 'Canoe', ['canoe', 'kayak', 'boat', 'paddle']],
    ['⛵', 'Sailboat', ['sailboat', 'boat', 'sailing', 'yacht']],
    ['🚢', 'Ship', ['ship', 'boat', 'cruise', 'ocean']],
    ['🚂', 'Locomotive', ['train', 'locomotive', 'steam', 'railroad']],
    ['🚆', 'Train', ['train', 'rail', 'transport']],
    ['🚇', 'Metro', ['metro', 'subway', 'underground', 'train']],
    ['🏠', 'House', ['house', 'home', 'building', 'residence']],
    ['🏡', 'House with Garden', ['house', 'home', 'garden', 'yard']],
    ['🏢', 'Office Building', ['office', 'building', 'work', 'business']],
    ['🏣', 'Japanese Post Office', ['post office', 'mail', 'japan']],
    ['🏥', 'Hospital', ['hospital', 'medical', 'health', 'doctor']],
    ['🏦', 'Bank', ['bank', 'money', 'finance', 'building']],
    ['🏨', 'Hotel', ['hotel', 'travel', 'accommodation', 'vacation']],
    ['🏪', 'Convenience Store', ['store', 'shop', 'convenience', '7-eleven']],
    ['🏫', 'School', ['school', 'education', 'building', 'learn']],
    ['🏛️', 'Classical Building', ['museum', 'government', 'classical', 'building']],
    ['⛪', 'Church', ['church', 'religion', 'christian', 'building']],
    ['🕌', 'Mosque', ['mosque', 'muslim', 'islam', 'religion']],
    ['🕍', 'Synagogue', ['synagogue', 'jewish', 'judaism', 'religion']],
    ['🗽', 'Statue of Liberty', ['statue of liberty', 'new york', 'america', 'freedom']],
    ['🗼', 'Tokyo Tower', ['tokyo tower', 'japan', 'landmark']],
    ['🗾', 'Map of Japan', ['japan', 'map', 'country']],
    ['🌍', 'Globe Europe-Africa', ['earth', 'globe', 'world', 'europe', 'africa']],
    ['🌎', 'Globe Americas', ['earth', 'globe', 'world', 'america', 'americas']],
    ['🌏', 'Globe Asia-Australia', ['earth', 'globe', 'world', 'asia', 'australia']],

    # Tech & Objects
    ['💻', 'Laptop', ['laptop', 'computer', 'work', 'coding', 'programming']],
    ['🖥️', 'Desktop Computer', ['desktop', 'computer', 'pc', 'monitor']],
    ['🖨️', 'Printer', ['printer', 'print', 'paper', 'office']],
    ['⌨️', 'Keyboard', ['keyboard', 'type', 'computer', 'input']],
    ['🖱️', 'Computer Mouse', ['mouse', 'computer', 'click', 'cursor']],
    ['💾', 'Floppy Disk', ['floppy', 'disk', 'save', 'retro', 'storage']],
    ['💿', 'Optical Disk', ['cd', 'dvd', 'disk', 'disc', 'music']],
    ['📱', 'Mobile Phone', ['phone', 'mobile', 'smartphone', 'iphone', 'android', 'cell']],
    ['☎️', 'Telephone', ['phone', 'telephone', 'call', 'retro']],
    ['📞', 'Telephone Receiver', ['phone', 'call', 'receiver']],
    ['📺', 'Television', ['tv', 'television', 'screen', 'watch']],
    ['📻', 'Radio', ['radio', 'music', 'broadcast']],
    ['🎙️', 'Studio Microphone', ['microphone', 'podcast', 'recording', 'studio']],
    ['🎚️', 'Level Slider', ['slider', 'volume', 'audio', 'control']],
    ['🎛️', 'Control Knobs', ['knobs', 'control', 'audio', 'mixer']],
    ['🎤', 'Microphone', ['microphone', 'karaoke', 'sing', 'music']],
    ['🎧', 'Headphone', ['headphones', 'music', 'audio', 'listen']],
    ['📷', 'Camera', ['camera', 'photo', 'picture', 'photography']],
    ['📹', 'Video Camera', ['video', 'camera', 'record', 'film']],
    ['🎬', 'Clapper Board', ['movie', 'film', 'action', 'cinema', 'director']],
    ['📡', 'Satellite Antenna', ['satellite', 'antenna', 'signal', 'broadcast']],
    ['🔋', 'Battery', ['battery', 'power', 'energy', 'charge']],
    ['🔌', 'Electric Plug', ['plug', 'electric', 'power', 'outlet']],
    ['💡', 'Light Bulb', ['idea', 'light', 'bulb', 'bright', 'thought', 'innovation']],
    ['🔦', 'Flashlight', ['flashlight', 'light', 'torch', 'dark']],
    ['🔒', 'Locked', ['lock', 'locked', 'security', 'private', 'password']],
    ['🔓', 'Unlocked', ['unlock', 'open', 'security', 'access']],
    ['🔑', 'Key', ['key', 'lock', 'unlock', 'access', 'password']],
    ['🗝️', 'Old Key', ['key', 'old', 'vintage', 'antique']],
    ['🔨', 'Hammer', ['hammer', 'tool', 'build', 'construction']],
    ['🪓', 'Axe', ['axe', 'tool', 'chop', 'wood']],
    ['⛏️', 'Pick', ['pick', 'pickaxe', 'mine', 'minecraft', 'tool']],
    ['🔧', 'Wrench', ['wrench', 'tool', 'fix', 'repair', 'settings']],
    ['🔩', 'Nut and Bolt', ['nut', 'bolt', 'screw', 'hardware']],
    ['⚙️', 'Gear', ['gear', 'settings', 'cog', 'mechanical', 'options']],
    ['🧲', 'Magnet', ['magnet', 'attract', 'magnetic']],
    ['💈', 'Barber Pole', ['barber', 'haircut', 'salon']],
    ['🧪', 'Test Tube', ['test tube', 'science', 'chemistry', 'lab', 'experiment']],
    ['🧫', 'Petri Dish', ['petri dish', 'science', 'biology', 'lab']],
    ['🧬', 'DNA', ['dna', 'genetics', 'science', 'biology', 'helix']],
    ['🔬', 'Microscope', ['microscope', 'science', 'research', 'lab', 'biology']],
    ['🔭', 'Telescope', ['telescope', 'astronomy', 'space', 'stars', 'science']],
    ['💉', 'Syringe', ['syringe', 'needle', 'vaccine', 'injection', 'medical']],
    ['💊', 'Pill', ['pill', 'medicine', 'drug', 'medication', 'pharmacy']],
    ['🩺', 'Stethoscope', ['stethoscope', 'doctor', 'medical', 'health']],
    ['🩹', 'Adhesive Bandage', ['bandage', 'band-aid', 'injury', 'hurt', 'heal']],

    # Symbols
    ['❌', 'Cross Mark', ['no', 'wrong', 'error', 'cancel', 'delete', 'x']],
    ['✅', 'Check Mark Button', ['yes', 'correct', 'done', 'complete', 'success', 'check']],
    ['☑️', 'Check Box with Check', ['check', 'done', 'complete', 'checkbox']],
    ['✔️', 'Check Mark', ['check', 'correct', 'yes', 'done', 'approved']],
    ['❓', 'Question Mark', ['question', 'what', 'help', 'confused']],
    ['❗', 'Exclamation Mark', ['exclamation', 'important', 'warning', 'alert']],
    ['‼️', 'Double Exclamation Mark', ['exclamation', 'important', 'urgent', 'emphasis']],
    ['⁉️', 'Exclamation Question Mark', ['surprise', 'what', 'shocked', 'interrobang']],
    ['💯', 'Hundred Points', ['100', 'perfect', 'score', 'hundred', 'full marks']],
    ['🔴', 'Red Circle', ['red', 'circle', 'dot', 'stop', 'record']],
    ['🟠', 'Orange Circle', ['orange', 'circle', 'dot']],
    ['🟡', 'Yellow Circle', ['yellow', 'circle', 'dot']],
    ['🟢', 'Green Circle', ['green', 'circle', 'dot', 'go', 'online']],
    ['🔵', 'Blue Circle', ['blue', 'circle', 'dot']],
    ['🟣', 'Purple Circle', ['purple', 'circle', 'dot']],
    ['⚫', 'Black Circle', ['black', 'circle', 'dot']],
    ['⚪', 'White Circle', ['white', 'circle', 'dot']],
    ['🔺', 'Red Triangle Pointed Up', ['triangle', 'up', 'red', 'arrow']],
    ['🔻', 'Red Triangle Pointed Down', ['triangle', 'down', 'red', 'arrow']],
    ['🔶', 'Large Orange Diamond', ['orange', 'diamond', 'shape']],
    ['🔷', 'Large Blue Diamond', ['blue', 'diamond', 'shape']],
    ['➕', 'Plus', ['plus', 'add', 'positive', 'more']],
    ['➖', 'Minus', ['minus', 'subtract', 'negative', 'less']],
    ['➗', 'Divide', ['divide', 'division', 'math']],
    ['✖️', 'Multiply', ['multiply', 'times', 'x', 'math']],
    ['♾️', 'Infinity', ['infinity', 'forever', 'endless', 'unlimited']],
    ['💲', 'Heavy Dollar Sign', ['dollar', 'money', 'price', 'cost', 'currency']],
    ['💱', 'Currency Exchange', ['currency', 'exchange', 'money', 'forex']],
    ['©️', 'Copyright', ['copyright', 'legal', 'c']],
    ['®️', 'Registered', ['registered', 'trademark', 'legal', 'r']],
    ['™️', 'Trade Mark', ['trademark', 'tm', 'brand', 'legal']],
    ['🔙', 'Back Arrow', ['back', 'arrow', 'return', 'previous']],
    ['🔚', 'End Arrow', ['end', 'arrow', 'finish']],
    ['🔛', 'On! Arrow', ['on', 'arrow', 'enable']],
    ['🔜', 'Soon Arrow', ['soon', 'arrow', 'coming']],
    ['🔝', 'Top Arrow', ['top', 'arrow', 'up', 'best']],
    ['⬆️', 'Up Arrow', ['up', 'arrow', 'north']],
    ['⬇️', 'Down Arrow', ['down', 'arrow', 'south']],
    ['⬅️', 'Left Arrow', ['left', 'arrow', 'west', 'back']],
    ['➡️', 'Right Arrow', ['right', 'arrow', 'east', 'forward', 'next']],
    ['↗️', 'Up-Right Arrow', ['up right', 'arrow', 'northeast']],
    ['↘️', 'Down-Right Arrow', ['down right', 'arrow', 'southeast']],
    ['↙️', 'Down-Left Arrow', ['down left', 'arrow', 'southwest']],
    ['↖️', 'Up-Left Arrow', ['up left', 'arrow', 'northwest']],
    ['↕️', 'Up-Down Arrow', ['up down', 'arrow', 'vertical']],
    ['↔️', 'Left-Right Arrow', ['left right', 'arrow', 'horizontal']],
    ['🔄', 'Counterclockwise Arrows', ['refresh', 'reload', 'repeat', 'sync', 'update']],
    ['🔃', 'Clockwise Arrows', ['clockwise', 'repeat', 'cycle']],
    ['🔁', 'Repeat Button', ['repeat', 'loop', 'replay']],
    ['🔂', 'Repeat Single Button', ['repeat one', 'loop', 'single']],
    ['▶️', 'Play Button', ['play', 'start', 'video', 'music']],
    ['⏸️', 'Pause Button', ['pause', 'stop', 'wait']],
    ['⏹️', 'Stop Button', ['stop', 'end', 'halt']],
    ['⏺️', 'Record Button', ['record', 'recording', 'red dot']],
    ['⏭️', 'Next Track Button', ['next', 'skip', 'forward']],
    ['⏮️', 'Last Track Button', ['previous', 'back', 'rewind']],
    ['⏩', 'Fast-Forward Button', ['fast forward', 'skip', 'speed']],
    ['⏪', 'Fast Reverse Button', ['rewind', 'back', 'reverse']],
    ['🔀', 'Shuffle Tracks Button', ['shuffle', 'random', 'mix']],
    ['🔊', 'Speaker High Volume', ['volume', 'loud', 'speaker', 'sound']],
    ['🔉', 'Speaker Medium Volume', ['volume', 'medium', 'speaker', 'sound']],
    ['🔈', 'Speaker Low Volume', ['volume', 'low', 'speaker', 'quiet']],
    ['🔇', 'Muted Speaker', ['mute', 'silent', 'no sound', 'quiet']],
    ['🔔', 'Bell', ['bell', 'notification', 'alert', 'ring']],
    ['🔕', 'Bell with Slash', ['mute', 'silent', 'no notification', 'quiet']],
    ['📢', 'Loudspeaker', ['announcement', 'megaphone', 'loud', 'speaker']],
    ['📣', 'Megaphone', ['megaphone', 'cheer', 'announcement', 'loud']],

    # Office & Stationery
    ['📄', 'Page Facing Up', ['document', 'page', 'file', 'paper']],
    ['📃', 'Page with Curl', ['document', 'page', 'paper', 'scroll']],
    ['📝', 'Memo', ['memo', 'note', 'write', 'document', 'edit', 'pencil']],
    ['📁', 'File Folder', ['folder', 'directory', 'file', 'organize']],
    ['📂', 'Open File Folder', ['folder', 'open', 'directory', 'file']],
    ['🗂️', 'Card Index Dividers', ['dividers', 'organize', 'tabs', 'index']],
    ['📅', 'Calendar', ['calendar', 'date', 'schedule', 'event']],
    ['📆', 'Tear-Off Calendar', ['calendar', 'date', 'schedule']],
    ['📇', 'Card Index', ['rolodex', 'contacts', 'index', 'cards']],
    ['📈', 'Chart Increasing', ['chart', 'graph', 'growth', 'up', 'stonks', 'increase', 'profit']],
    ['📉', 'Chart Decreasing', ['chart', 'graph', 'decline', 'down', 'decrease', 'loss']],
    ['📊', 'Bar Chart', ['chart', 'graph', 'statistics', 'data', 'analytics']],
    ['📋', 'Clipboard', ['clipboard', 'paste', 'list', 'tasks']],
    ['📌', 'Pushpin', ['pin', 'pushpin', 'location', 'mark', 'important']],
    ['📍', 'Round Pushpin', ['pin', 'location', 'map', 'marker']],
    ['📎', 'Paperclip', ['paperclip', 'attachment', 'attach', 'clip']],
    ['🖇️', 'Linked Paperclips', ['paperclips', 'linked', 'attachment']],
    ['📏', 'Straight Ruler', ['ruler', 'measure', 'length', 'straight']],
    ['📐', 'Triangular Ruler', ['ruler', 'triangle', 'measure', 'angle']],
    ['✂️', 'Scissors', ['scissors', 'cut', 'trim']],
    ['🗃️', 'Card File Box', ['file', 'box', 'storage', 'archive']],
    ['🗄️', 'File Cabinet', ['cabinet', 'file', 'storage', 'office']],
    ['🗑️', 'Wastebasket', ['trash', 'delete', 'garbage', 'bin', 'waste']],
    ['✏️', 'Pencil', ['pencil', 'write', 'edit', 'draw']],
    ['🖊️', 'Pen', ['pen', 'write', 'sign']],
    ['🖋️', 'Fountain Pen', ['fountain pen', 'write', 'fancy']],
    ['✒️', 'Black Nib', ['pen', 'nib', 'write', 'calligraphy']],
    ['🖌️', 'Paintbrush', ['paintbrush', 'art', 'paint', 'draw']],
    ['🖍️', 'Crayon', ['crayon', 'color', 'draw', 'kids']],
    ['📚', 'Books', ['books', 'read', 'study', 'library', 'education']],
    ['📖', 'Open Book', ['book', 'read', 'open', 'study']],
    ['📕', 'Closed Book', ['book', 'closed', 'red']],
    ['📗', 'Green Book', ['book', 'green']],
    ['📘', 'Blue Book', ['book', 'blue']],
    ['📙', 'Orange Book', ['book', 'orange']],
    ['📓', 'Notebook', ['notebook', 'journal', 'write']],
    ['📔', 'Notebook with Decorative Cover', ['notebook', 'journal', 'diary']],
    ['📒', 'Ledger', ['ledger', 'notebook', 'accounts']],
    ['📰', 'Newspaper', ['newspaper', 'news', 'press', 'media']],
    ['🗞️', 'Rolled-Up Newspaper', ['newspaper', 'news', 'rolled']],
    ['🏷️', 'Label', ['label', 'tag', 'price', 'sale']],
    ['✉️', 'Envelope', ['envelope', 'email', 'mail', 'letter']],
    ['📧', 'E-Mail', ['email', 'mail', 'message', 'inbox']],
    ['📨', 'Incoming Envelope', ['email', 'incoming', 'receive', 'mail']],
    ['📩', 'Envelope with Arrow', ['email', 'send', 'outgoing', 'mail']],
    ['📤', 'Outbox Tray', ['outbox', 'send', 'upload', 'mail']],
    ['📥', 'Inbox Tray', ['inbox', 'receive', 'download', 'mail']],
    ['📦', 'Package', ['package', 'box', 'delivery', 'shipping', 'parcel']],
    ['📫', 'Closed Mailbox with Raised Flag', ['mailbox', 'mail', 'inbox']],
    ['📬', 'Open Mailbox with Raised Flag', ['mailbox', 'mail', 'inbox']],
    ['📭', 'Open Mailbox with Lowered Flag', ['mailbox', 'empty', 'no mail']],
    ['📮', 'Postbox', ['postbox', 'mail', 'send', 'letter']],

    # Time
    ['⏰', 'Alarm Clock', ['alarm', 'clock', 'time', 'wake up', 'morning']],
    ['⏱️', 'Stopwatch', ['stopwatch', 'timer', 'time', 'speed']],
    ['⏲️', 'Timer Clock', ['timer', 'clock', 'countdown', 'time']],
    ['🕐', 'One O\'Clock', ['1', 'one', 'clock', 'time']],
    ['🕑', 'Two O\'Clock', ['2', 'two', 'clock', 'time']],
    ['🕒', 'Three O\'Clock', ['3', 'three', 'clock', 'time']],
    ['🕓', 'Four O\'Clock', ['4', 'four', 'clock', 'time']],
    ['🕔', 'Five O\'Clock', ['5', 'five', 'clock', 'time']],
    ['🕕', 'Six O\'Clock', ['6', 'six', 'clock', 'time']],
    ['🕖', 'Seven O\'Clock', ['7', 'seven', 'clock', 'time']],
    ['🕗', 'Eight O\'Clock', ['8', 'eight', 'clock', 'time']],
    ['🕘', 'Nine O\'Clock', ['9', 'nine', 'clock', 'time']],
    ['🕙', 'Ten O\'Clock', ['10', 'ten', 'clock', 'time']],
    ['🕚', 'Eleven O\'Clock', ['11', 'eleven', 'clock', 'time']],
    ['🕛', 'Twelve O\'Clock', ['12', 'twelve', 'clock', 'time', 'noon', 'midnight']],
    ['⌛', 'Hourglass Done', ['hourglass', 'time', 'wait', 'done']],
    ['⏳', 'Hourglass Not Done', ['hourglass', 'time', 'wait', 'loading', 'pending']],

    # Misc
    ['🎵', 'Musical Note', ['music', 'note', 'song', 'melody', 'sound']],
    ['🎶', 'Musical Notes', ['music', 'notes', 'song', 'melody', 'singing']],
    ['🎼', 'Musical Score', ['music', 'score', 'sheet music', 'notes']],
    ['🎹', 'Musical Keyboard', ['piano', 'keyboard', 'music', 'keys']],
    ['🎸', 'Guitar', ['guitar', 'music', 'rock', 'instrument']],
    ['🎺', 'Trumpet', ['trumpet', 'music', 'brass', 'instrument']],
    ['🎻', 'Violin', ['violin', 'music', 'classical', 'instrument']],
    ['🥁', 'Drum', ['drum', 'music', 'percussion', 'instrument']],
    ['🎷', 'Saxophone', ['saxophone', 'music', 'jazz', 'instrument']],
    ['🪕', 'Banjo', ['banjo', 'music', 'country', 'instrument']],
    ['🎨', 'Artist Palette', ['art', 'paint', 'palette', 'creative', 'design']],
    ['🎭', 'Performing Arts', ['theater', 'drama', 'masks', 'acting', 'performance']],
    ['🎪', 'Circus Tent', ['circus', 'tent', 'carnival', 'fair']],
    ['🎟️', 'Admission Tickets', ['ticket', 'admission', 'event', 'movie']],
    ['🎫', 'Ticket', ['ticket', 'event', 'admission', 'pass']],
    ['🧸', 'Teddy Bear', ['teddy', 'bear', 'toy', 'cute', 'stuffed']],
    ['🪀', 'Yo-Yo', ['yo-yo', 'toy', 'play', 'string']],
    ['🪁', 'Kite', ['kite', 'fly', 'wind', 'toy']],
    ['🔮', 'Crystal Ball', ['crystal ball', 'fortune', 'magic', 'future', 'predict']],
    ['🧿', 'Nazar Amulet', ['evil eye', 'amulet', 'protection', 'luck']],
    ['🪄', 'Magic Wand', ['magic', 'wand', 'wizard', 'spell']],
    ['🧙', 'Mage', ['wizard', 'mage', 'magic', 'fantasy']],
    ['🧚', 'Fairy', ['fairy', 'magic', 'fantasy', 'wings']],
    ['🧜', 'Merperson', ['mermaid', 'merman', 'ocean', 'sea', 'fantasy']],
    ['🧝', 'Elf', ['elf', 'fantasy', 'magic', 'tolkien']],
    ['🧞', 'Genie', ['genie', 'wish', 'lamp', 'magic']],
    ['🧟', 'Zombie', ['zombie', 'undead', 'horror', 'halloween']],
    ['🦸', 'Superhero', ['superhero', 'hero', 'power', 'cape']],
    ['🦹', 'Supervillain', ['villain', 'evil', 'bad', 'supervillain']],
    ['🤴', 'Prince', ['prince', 'royal', 'king', 'crown']],
    ['👸', 'Princess', ['princess', 'royal', 'queen', 'crown', 'tiara']],
    ['👰', 'Person with Veil', ['bride', 'wedding', 'marriage', 'veil']],
    ['🤵', 'Person in Tuxedo', ['groom', 'wedding', 'tuxedo', 'formal']],
    ['👼', 'Baby Angel', ['angel', 'baby', 'cherub', 'innocent']],
    ['🎅', 'Santa Claus', ['santa', 'christmas', 'xmas', 'holiday']],
    ['🤶', 'Mrs. Claus', ['mrs claus', 'christmas', 'xmas', 'holiday']],
    ['🧑‍🎄', 'Mx Claus', ['mx claus', 'christmas', 'xmas', 'holiday']],
    ['👁️‍🗨️', 'Eye in Speech Bubble', ['witness', 'eye', 'speech', 'awareness']],
    ['🗣️', 'Speaking Head', ['speaking', 'talk', 'voice', 'speech']],
    ['👤', 'Bust in Silhouette', ['person', 'user', 'profile', 'silhouette', 'account']],
    ['👥', 'Busts in Silhouette', ['people', 'users', 'group', 'team', 'profiles']],
    ['🫂', 'People Hugging', ['hug', 'embrace', 'comfort', 'support', 'friends']],
    ['👣', 'Footprints', ['footprints', 'feet', 'walk', 'steps', 'tracks']],
    ['🐾', 'Paw Prints', ['paw', 'pet', 'dog', 'cat', 'animal', 'tracks']],

    # Flags
    ['🏁', 'Chequered Flag', ['finish', 'race', 'checkered', 'flag', 'end']],
    ['🚩', 'Triangular Flag', ['flag', 'red flag', 'warning', 'marker']],
    ['🎌', 'Crossed Flags', ['flags', 'japan', 'celebration']],
    ['🏴', 'Black Flag', ['flag', 'black', 'pirate']],
    ['🏳️', 'White Flag', ['flag', 'white', 'surrender', 'peace']],
    ['🏳️‍🌈', 'Rainbow Flag', ['pride', 'lgbtq', 'rainbow', 'gay', 'flag']],
    ['🏳️‍⚧️', 'Transgender Flag', ['transgender', 'trans', 'pride', 'flag']],
    ['🏴‍☠️', 'Pirate Flag', ['pirate', 'skull', 'jolly roger', 'flag']],

    # Additional common emojis
    ['💬', 'Speech Balloon', ['speech', 'chat', 'talk', 'message', 'comment', 'bubble']],
    ['💭', 'Thought Balloon', ['thought', 'think', 'bubble', 'idea']],
    ['🗯️', 'Right Anger Bubble', ['anger', 'angry', 'speech', 'yell']],
    ['💤', 'Zzz', ['sleep', 'zzz', 'tired', 'snore', 'nap']],
    ['💢', 'Anger Symbol', ['anger', 'angry', 'mad', 'frustration']],
    ['💥', 'Collision', ['boom', 'explosion', 'collision', 'crash', 'bang']],
    ['💦', 'Sweat Droplets', ['sweat', 'water', 'splash', 'effort', 'work']],
    ['💨', 'Dashing Away', ['dash', 'fast', 'run', 'wind', 'speed', 'whoosh']],
    ['🕳️', 'Hole', ['hole', 'empty', 'void', 'pit']],
    ['👨‍💻', 'Man Technologist', ['developer', 'programmer', 'coder', 'tech', 'man', 'software']],
    ['👩‍💻', 'Woman Technologist', ['developer', 'programmer', 'coder', 'tech', 'woman', 'software']],
    ['🧑‍💻', 'Technologist', ['developer', 'programmer', 'coder', 'tech', 'software', 'engineer']],
    ['👨‍🔬', 'Man Scientist', ['scientist', 'research', 'lab', 'man', 'science']],
    ['👩‍🔬', 'Woman Scientist', ['scientist', 'research', 'lab', 'woman', 'science']],
    ['👨‍🎨', 'Man Artist', ['artist', 'painter', 'creative', 'man', 'art']],
    ['👩‍🎨', 'Woman Artist', ['artist', 'painter', 'creative', 'woman', 'art']],
    ['👨‍🚀', 'Man Astronaut', ['astronaut', 'space', 'nasa', 'man', 'rocket']],
    ['👩‍🚀', 'Woman Astronaut', ['astronaut', 'space', 'nasa', 'woman', 'rocket']],
    ['👨‍🍳', 'Man Cook', ['chef', 'cook', 'food', 'man', 'kitchen']],
    ['👩‍🍳', 'Woman Cook', ['chef', 'cook', 'food', 'woman', 'kitchen']],
    ['🧑‍🍳', 'Cook', ['chef', 'cook', 'food', 'kitchen']],
    ['👨‍⚕️', 'Man Health Worker', ['doctor', 'nurse', 'medical', 'man', 'health']],
    ['👩‍⚕️', 'Woman Health Worker', ['doctor', 'nurse', 'medical', 'woman', 'health']],
    ['👨‍🏫', 'Man Teacher', ['teacher', 'professor', 'education', 'man', 'school']],
    ['👩‍🏫', 'Woman Teacher', ['teacher', 'professor', 'education', 'woman', 'school']],
    ['👨‍🎓', 'Man Student', ['student', 'graduate', 'education', 'man', 'school']],
    ['👩‍🎓', 'Woman Student', ['student', 'graduate', 'education', 'woman', 'school']],
    ['🧑‍🎓', 'Student', ['student', 'graduate', 'education', 'school']],
);

my @results;

if ($query eq '') {
    # Show popular emojis when no query
    my @popular = ('😀', '❤️', '👍', '😂', '🎉', '✨', '🔥', '💯', '🙏', '😊');
    my %popular_set = map { $_ => 1 } @popular;
    for my $e (@emojis) {
        if ($popular_set{$e->[0]}) {
            push @results, { emoji => $e, score => 100 };
        }
    }
} else {
    my @query_terms = split /\s+/, $query;

    for my $e (@emojis) {
        # Merge custom keywords if they exist for this emoji
        my @keywords = @{$e->[2]};
        if (exists $custom_keywords{$e->[0]}) {
            push @keywords, @{$custom_keywords{$e->[0]}};
        }
        my $emoji_with_custom = [$e->[0], $e->[1], \@keywords];

        my $score = calculate_score($emoji_with_custom, $query, \@query_terms);
        if ($score > 0) {
            push @results, { emoji => $emoji_with_custom, score => $score };
        }
    }

    @results = sort { $b->{score} <=> $a->{score} } @results;
}

my @items;
my $count = 0;
for my $r (@results) {
    last if $count >= 50;
    my $e = $r->{emoji};
    my $keywords_preview = join(', ', @{$e->[2]}[0..2]);
    push @items, {
        uid => $e->[0],
        title => "$e->[0]  $e->[1]",
        subtitle => $keywords_preview,
        arg => $e->[0],
        text => {
            copy => $e->[0],
            largetype => $e->[0]
        },
        mods => {
            cmd => {
                valid => JSON::PP::true,
                arg => $e->[0],
                subtitle => "Paste directly into frontmost app"
            }
        }
    };
    $count++;
}

if (@items == 0) {
    push @items, {
        title => "No emojis found",
        subtitle => "No matches for '$query'",
        valid => JSON::PP::false
    };
}

my $output = { items => \@items };
print encode_json($output) . "\n";

sub calculate_score {
    my ($emoji, $query, $query_terms) = @_;
    my $score = 0;
    my $name_lower = lc($emoji->[1]);

    # Exact name match - highest priority
    $score += 1000 if $name_lower eq $query;

    # Name starts with query
    $score += 500 if index($name_lower, $query) == 0;

    # Name contains query
    $score += 200 if index($name_lower, $query) >= 0;

    # Check keywords
    for my $keyword (@{$emoji->[2]}) {
        my $keyword_lower = lc($keyword);

        # Exact keyword match
        $score += 300 if $keyword_lower eq $query;

        # Keyword starts with query
        $score += 150 if index($keyword_lower, $query) == 0;

        # Keyword contains query
        $score += 50 if index($keyword_lower, $query) >= 0;

        # Check each query term
        for my $term (@$query_terms) {
            $score += 30 if index($keyword_lower, $term) >= 0;
            $score += 10 if fuzzy_match($keyword_lower, $term);
        }
    }

    return $score;
}

sub fuzzy_match {
    my ($str, $pattern) = @_;
    return 1 if length($pattern) == 0;
    return 0 if length($str) == 0;

    my $pattern_idx = 0;
    for my $char (split //, $str) {
        if ($pattern_idx < length($pattern) && lc($char) eq lc(substr($pattern, $pattern_idx, 1))) {
            $pattern_idx++;
        }
    }
    return $pattern_idx == length($pattern);
}
