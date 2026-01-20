# Emoji Semantic Search

An Alfred workflow for finding emojis by meaning, not just exact names.

## Usage

Search emojis by name, emotion, concept, or slang via the `emoji` keyword.

* <kbd>↩︎</kbd> Copy emoji to clipboard
* <kbd>⌘</kbd><kbd>↩︎</kbd> Paste emoji to frontmost app

### Examples

| Query | Results |
|-------|---------|
| `emoji happy` | 😀 😃 😄 😊 😁 |
| `emoji sad` | 😢 😭 😞 😔 |
| `emoji love` | ❤️ 😍 💕 🥰 💗 |
| `emoji think` | 🤔 |
| `emoji celebrate` | 🎉 🥳 🎊 🙌 |
| `emoji fire` | 🔥 |
| `emoji cool` | 😎 |
| `emoji money` | 💰 🤑 💵 💲 |
| `emoji programmer` | 👨‍💻 👩‍💻 🧑‍💻 |

## How it works

Most emoji pickers require you to know the official Unicode name. If you want 🤔, you need to remember it's called "Thinking Face". Search "hmm" or "wonder" and you get nothing.

This workflow maps each emoji to multiple related terms:

```
🤔 Thinking Face → think, hmm, wonder, consider, ponder, curious
🔥 Fire → fire, hot, lit, flame, burn, awesome, trending
🚀 Rocket → rocket, space, launch, fast, startup
```

Search by:
- **Emotion**: "angry", "nervous", "excited"
- **Concept**: "money", "time", "food"
- **Use case**: "approve", "celebrate", "warning"
- **Slang**: "lit", "lol", "yikes"

The database includes 400+ emojis with 5-15 keywords each.

## Installation

Download the latest `.alfredworkflow` file and double-click to install.

Or build from source:

```bash
./build.sh
```

Then double-click `Semoji.alfredworkflow` to install.

## Custom Keywords

Add your own keywords to any emoji without editing the source code.

### Via Alfred

Use the `emoji:add` keyword. You can paste the emoji directly or search for it:

```
emoji:add 🔥 awesome      → paste emoji directly + keyword
emoji:add fire awesome    → or search for it + keyword
emoji:add 👍 bob          → adds "bob" to 👍
emoji:add 🦷 tooth dental → works with any emoji, even ones not in the database
```

**Tip:** Copy an emoji from search results, then paste it into `emoji:add`.

### Via Config File

Edit `~/.config/semoji/custom.json` directly:

```json
{
  "🔥": ["awesome", "great"],
  "👍": ["bob", "approve"],
  "❤️": ["favorite", "love"]
}
```

Custom keywords are merged with built-in keywords when searching.

## Editing the Built-in Database

To add new emojis or modify built-in keywords, edit `emoji-search.pl` and find the `@emojis` array:

```perl
['🆕', 'New Button', ['new', 'fresh', 'recent', 'update']],
```

Then rebuild with `./build.sh` and reinstall.

## Files

- `emoji-search.pl` - Search algorithm, emoji database, and Alfred JSON output
- `emoji-add.pl` - Script filter for adding custom keywords
- `emoji-save.pl` - Saves custom keywords to config file
- `info.plist` - Alfred workflow configuration
- `icon.png` - Workflow icon
- `build.sh` - Build script to create the .alfredworkflow package

## License

MIT
