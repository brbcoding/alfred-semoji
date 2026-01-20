package main

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
	"unicode"
)

type Emoji struct {
	Char     string   // The emoji character
	Name     string   // Display name
	Keywords []string // Semantic keywords for searching
}

type AlfredItem struct {
	UID      string            `json:"uid,omitempty"`
	Title    string            `json:"title"`
	Subtitle string            `json:"subtitle,omitempty"`
	Arg      string            `json:"arg,omitempty"`
	Icon     map[string]string `json:"icon,omitempty"`
	Mods     map[string]Mod    `json:"mods,omitempty"`
	Valid    *bool             `json:"valid,omitempty"`
}

type Mod struct {
	Valid    bool   `json:"valid"`
	Arg      string `json:"arg"`
	Subtitle string `json:"subtitle"`
}

type AlfredOutput struct {
	Items []AlfredItem `json:"items"`
}

type ScoredEmoji struct {
	Emoji Emoji
	Score int
}

func main() {
	query := ""
	if len(os.Args) > 1 {
		query = strings.ToLower(strings.TrimSpace(strings.Join(os.Args[1:], " ")))
	}

	emojis := getEmojiDatabase()
	var results []ScoredEmoji

	if query == "" {
		// Show popular emojis when no query
		popular := []string{"😀", "❤️", "👍", "😂", "🎉", "✨", "🔥", "💯", "🙏", "😊"}
		for _, p := range popular {
			for _, e := range emojis {
				if e.Char == p {
					results = append(results, ScoredEmoji{Emoji: e, Score: 100})
					break
				}
			}
		}
	} else {
		results = searchEmojis(emojis, query)
	}

	output := AlfredOutput{Items: make([]AlfredItem, 0)}

	for i, result := range results {
		if i >= 50 { // Limit results
			break
		}
		item := AlfredItem{
			UID:      result.Emoji.Char,
			Title:    fmt.Sprintf("%s  %s", result.Emoji.Char, result.Emoji.Name),
			Subtitle: "⏎ Copy to clipboard  ⌘⏎ Paste directly",
			Arg:      result.Emoji.Char,
			Mods: map[string]Mod{
				"cmd": {
					Valid:    true,
					Arg:      result.Emoji.Char,
					Subtitle: "Paste directly into frontmost app",
				},
			},
		}
		output.Items = append(output.Items, item)
	}

	if len(output.Items) == 0 {
		valid := false
		output.Items = append(output.Items, AlfredItem{
			Title:    "No emojis found",
			Subtitle: fmt.Sprintf("No matches for '%s'", query),
			Valid:    &valid,
		})
	}

	jsonOutput, _ := json.Marshal(output)
	fmt.Println(string(jsonOutput))
}

func searchEmojis(emojis []Emoji, query string) []ScoredEmoji {
	var results []ScoredEmoji
	queryTerms := strings.Fields(query)

	for _, emoji := range emojis {
		score := calculateScore(emoji, query, queryTerms)
		if score > 0 {
			results = append(results, ScoredEmoji{Emoji: emoji, Score: score})
		}
	}

	// Sort by score descending
	sort.Slice(results, func(i, j int) bool {
		return results[i].Score > results[j].Score
	})

	return results
}

func calculateScore(emoji Emoji, query string, queryTerms []string) int {
	score := 0
	nameLower := strings.ToLower(emoji.Name)

	// Exact name match - highest priority
	if nameLower == query {
		score += 1000
	}

	// Name starts with query
	if strings.HasPrefix(nameLower, query) {
		score += 500
	}

	// Name contains query
	if strings.Contains(nameLower, query) {
		score += 200
	}

	// Check keywords
	for _, keyword := range emoji.Keywords {
		keywordLower := strings.ToLower(keyword)

		// Exact keyword match
		if keywordLower == query {
			score += 300
		}

		// Keyword starts with query
		if strings.HasPrefix(keywordLower, query) {
			score += 150
		}

		// Keyword contains query
		if strings.Contains(keywordLower, query) {
			score += 50
		}

		// Check each query term
		for _, term := range queryTerms {
			if strings.Contains(keywordLower, term) {
				score += 30
			}
			// Fuzzy match - check if term characters appear in order
			if fuzzyMatch(keywordLower, term) {
				score += 10
			}
		}
	}

	return score
}

func fuzzyMatch(str, pattern string) bool {
	if len(pattern) == 0 {
		return true
	}
	if len(str) == 0 {
		return false
	}

	patternIdx := 0
	for _, char := range str {
		if patternIdx < len(pattern) && unicode.ToLower(char) == unicode.ToLower(rune(pattern[patternIdx])) {
			patternIdx++
		}
	}
	return patternIdx == len(pattern)
}
