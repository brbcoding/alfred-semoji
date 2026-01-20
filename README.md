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

## Building from source

Requires Go 1.21+

```bash
go build -o emoji-search .
```

## Adding emojis or keywords

Edit `emoji_data.go`:

```go
{"🆕", "New Button", []string{"new", "fresh", "recent", "update"}},
```

Then rebuild and reinstall:

```bash
go build -o emoji-search .
cp emoji-search info.plist icon.png "/path/to/workflow/directory/"
```

## Files

- `main.go` - Search algorithm and Alfred JSON output
- `emoji_data.go` - Emoji database with keywords
- `info.plist` - Alfred workflow configuration
- `icon.png` - Workflow icon

## License

MIT
