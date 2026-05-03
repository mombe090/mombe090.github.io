# Agent Guidelines for Jekyll Blog

## Build/Test/Lint Commands

- **Install**: `mise exec ruby@3 -- bundle install` or `just install`
- **Serve locally**: `mise exec ruby@3 -- bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload` or `just`
- **Build for production**: `JEKYLL_ENV=production mise exec ruby@3 -- bundle exec jekyll b -d _site`
- **Test (build + HTML validation)**: `bash tools/test.sh`
- **Test single file**: Build site first, then `mise exec ruby@3 -- bundle exec htmlproofer _site --disable-external --file-ignore <pattern>`
- **Lint markdown**: `markdownlint <file>` (config: .markdownlint.yaml)

## Code Style & Formatting

- **Indentation**: 2 spaces for all files (YAML, Ruby, Markdown, JS, CSS, SCSS)
- **Line endings**: LF (Unix-style), always insert final newline
- **Encoding**: UTF-8 only
- **Quotes**: Single quotes for JS/CSS/SCSS, double quotes for YAML
- **Markdown**: ATX-style headings (#), dash-style lists, fenced code blocks with backticks and language identifiers
- **Whitespace**: Trim trailing whitespace (except .md files which preserve for line breaks)
- **Comments**: Only when code is not self-explanatory. No restating what the code does.

## Content Structure & Naming

- **Posts**: `_posts/YYYY-MM-DD-title.md` with front matter (title, description, categories, tags, author, image.path)
- **Drafts**: Place in `_drafts/` (no date prefix needed)
- **Images**: Content images in `assets/img/content/`, headers in `assets/img/header/` (prefer .webp)
- **Language**: Primary language is French (fr), English (en) bilingual support scaffolded

## Project Context

- Jekyll theme: Chirpy (~> 7.4), French DevOps/homelab blog with English bilingual support
- Primary language: French (fr), alternate: English (en)
- Locale files: `_data/locales/fr.yml` (primary), `_data/locales/en.yml` (alternate)
- i18n scaffolds: `_includes/lang/` (language-switcher, hreflang-tags), `_data/translations.yml`
- Post directories: `_posts/` (current French posts), `_posts/fr/`, `_posts/en/` (future bilingual)
- Preserve French URLs and existing permalinks for SEO (/posts/:title/)
- Ruby 3.3+ compatible (requires csv, base64, bigdecimal gems)
