#!/usr/bin/env ruby
# Translation management script for Jekyll multilingual blog
# This script helps create and manage post translations

require 'yaml'
require 'fileutils'
require 'optparse'
require 'date'

class TranslationManager
  def initialize
    @root_dir = File.expand_path('../..', __dir__)
    @posts_dir = File.join(@root_dir, '_posts')
    @data_dir = File.join(@root_dir, '_data')
    @translations_file = File.join(@data_dir, 'translations.yml')
    @supported_languages = ['fr', 'en']
    @default_language = 'fr'
  end

  def create_translation(source_file, target_language)
    unless File.exist?(source_file)
      puts "Error: Source file '#{source_file}' not found"
      return false
    end

    unless @supported_languages.include?(target_language)
      puts "Error: Unsupported language '#{target_language}'"
      puts "Supported languages: #{@supported_languages.join(', ')}"
      return false
    end

    # Parse source post
    source_post = parse_post(source_file)
    return false unless source_post

    # Generate target filename and path
    target_filename = generate_target_filename(source_file, target_language)
    target_path = File.join(@posts_dir, target_language, target_filename)

    # Create target directory if it doesn't exist
    FileUtils.mkdir_p(File.dirname(target_path))

    # Create translation post
    create_translation_post(source_post, target_path, target_language)

    # Update translations data
    update_translations_data(source_post, target_language, target_path)

    puts "Translation created: #{target_path}"
    puts "Don't forget to:"
    puts "1. Translate the content in #{target_path}"
    puts "2. Update the translation_key in both posts if needed"
    puts "3. Commit your changes"

    true
  end

  def list_translations
    translations = load_translations_data
    
    puts "\n=== Translation Status ==="
    
    translations['post_relationships']&.each do |key, languages|
      puts "\nTranslation Key: #{key}"
      languages.each do |lang, url|
        status = check_translation_status(url)
        puts "  #{lang}: #{url} [#{status}]"
      end
    end
  end

  def validate_translations
    puts "\n=== Validating Translations ==="
    
    errors = []
    translations = load_translations_data
    
    # Check if translation files exist
    translations['post_relationships']&.each do |key, languages|
      languages.each do |lang, url|
        unless translation_exists?(url)
          errors << "Missing translation file for #{key} (#{lang}): #{url}"
        end
      end
    end

    # Check for orphaned translation keys
    all_posts = find_all_posts
    used_keys = all_posts.map { |post| parse_post(post)&.dig('translation_key') }.compact
    defined_keys = translations['post_relationships']&.keys || []
    
    orphaned_keys = defined_keys - used_keys
    orphaned_keys.each do |key|
      errors << "Orphaned translation key: #{key} (not used by any post)"
    end

    # Check for posts with translation_key but no translations data
    all_posts.each do |post_file|
      post = parse_post(post_file)
      next unless post && post['translation_key']
      
      unless translations['post_relationships']&.key?(post['translation_key'])
        errors << "Post #{File.basename(post_file)} has translation_key '#{post['translation_key']}' but no translations data"
      end
    end

    if errors.empty?
      puts "✓ All translations are valid"
    else
      puts "⚠ Translation errors found:"
      errors.each { |error| puts "  - #{error}" }
    end

    errors.empty?
  end

  def generate_translation_template(source_file, target_language)
    source_post = parse_post(source_file)
    return false unless source_post

    template = {
      'title' => "[TRANSLATE] #{source_post['title']}",
      'description' => "[TRANSLATE] #{source_post['description']}",
      'author' => source_post['author'],
      'date' => source_post['date'],
      'categories' => translate_categories(source_post['categories'], target_language),
      'tags' => translate_tags(source_post['tags'], target_language),
      'lang' => target_language,
      'translation_key' => source_post['translation_key'] || generate_translation_key(source_post['title']),
      'translations' => generate_translation_links(source_post, target_language)
    }

    puts "\n=== Translation Template ==="
    puts "Copy this front matter to your translation file:"
    puts "---"
    puts template.to_yaml.lines[1..-1].join # Remove first line (---)
    puts "---"
    puts "\n[TRANSLATE THE CONTENT BELOW]"
    puts "\n# #{template['title']}"
    puts "\n[Translate the main content here]"
  end

  private

  def parse_post(file_path)
    content = File.read(file_path)
    
    # Extract front matter
    if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
      begin
        YAML.safe_load($1)
      rescue Yaml::SyntaxError => e
        puts "Error parsing YAML in #{file_path}: #{e.message}"
        nil
      end
    else
      puts "Error: No front matter found in #{file_path}"
      nil
    end
  end

  def generate_target_filename(source_file, target_language)
    basename = File.basename(source_file)
    
    # If source is in a language directory, just use the basename
    if source_file.include?("/_posts/#{@default_language}/")
      return basename
    end
    
    # For legacy posts, generate a language-aware filename
    return basename
  end

  def create_translation_post(source_post, target_path, target_language)
    # Create the translation front matter
    translation_data = {
      'title' => "[TRANSLATE] #{source_post['title']}",
      'description' => "[TRANSLATE] #{source_post['description']}",
      'author' => source_post['author'],
      'date' => source_post['date'],
      'categories' => translate_categories(source_post['categories'], target_language),
      'tags' => translate_tags(source_post['tags'], target_language),
      'lang' => target_language,
      'translation_key' => source_post['translation_key'] || generate_translation_key(source_post['title']),
      'translations' => generate_translation_links(source_post, target_language),
      'permalink' => generate_permalink(target_language, source_post)
    }

    # Create the file content
    content = "---\n"
    content += translation_data.to_yaml.lines[1..-1].join # Remove first line
    content += "---\n\n"
    content += "# #{translation_data['title']}\n\n"
    content += "[TRANSLATE THE CONTENT - Replace this with the translated content]\n\n"
    content += "---\n\n"
    content += "*This post is also available in other languages. See the translation links above.*\n"

    File.write(target_path, content)
  end

  def generate_permalink(language, source_post)
    title_slug = source_post['title'].downcase.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-')
    
    if language == @default_language
      "/posts/#{title_slug}/"
    else
      "/#{language}/posts/#{title_slug}/"
    end
  end

  def generate_translation_links(source_post, target_language)
    links = {}
    
    # Add source language link
    source_lang = source_post['lang'] || @default_language
    source_permalink = source_post['permalink'] || generate_permalink(source_lang, source_post)
    links[source_lang] = source_permalink
    
    # Add target language link
    links[target_language] = generate_permalink(target_language, source_post)
    
    links
  end

  def translate_categories(categories, target_language)
    return categories unless categories.is_a?(Array)
    
    translations = load_translations_data
    category_translations = translations['category_translations'] || {}
    
    categories.map do |category|
      category_translations[category] || category
    end
  end

  def translate_tags(tags, target_language)
    return tags unless tags.is_a?(Array)
    
    translations = load_translations_data
    tag_translations = translations['tag_translations'] || {}
    
    tags.map do |tag|
      tag_translations[tag] || tag
    end
  end

  def generate_translation_key(title)
    title.downcase.gsub(/[^\w\s-]/, '').gsub(/\s+/, '-').gsub(/^-+|-+$/, '')
  end

  def update_translations_data(source_post, target_language, target_path)
    translations = load_translations_data
    
    # Ensure structure exists
    translations['post_relationships'] ||= {}
    
    # Get or generate translation key
    translation_key = source_post['translation_key'] || generate_translation_key(source_post['title'])
    
    # Initialize translations for this key
    translations['post_relationships'][translation_key] ||= {}
    
    # Add source language if not present
    source_lang = source_post['lang'] || @default_language
    source_permalink = source_post['permalink'] || generate_permalink(source_lang, source_post)
    translations['post_relationships'][translation_key][source_lang] = source_permalink
    
    # Add target language
    target_permalink = generate_permalink(target_language, source_post)
    translations['post_relationships'][translation_key][target_language] = target_permalink
    
    # Save translations file
    File.write(@translations_file, translations.to_yaml)
  end

  def load_translations_data
    if File.exist?(@translations_file)
      YAML.load_file(@translations_file) || {}
    else
      {
        'post_relationships' => {},
        'category_translations' => {},
        'tag_translations' => {}
      }
    end
  end

  def check_translation_status(url)
    # Convert URL to file path and check if it exists
    all_posts = find_all_posts
    
    post_exists = all_posts.any? do |post_file|
      post = parse_post(post_file)
      post && (post['permalink'] == url || File.basename(post_file, '.md').include?(url.split('/').last))
    end
    
    post_exists ? "EXISTS" : "MISSING"
  end

  def translation_exists?(url)
    check_translation_status(url) == "EXISTS"
  end

  def find_all_posts
    Dir.glob(File.join(@posts_dir, '**', '*.md'))
  end
end

# Command line interface
def main
  manager = TranslationManager.new
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("-c", "--create SOURCE TARGET_LANG", "Create translation") do |source|
      options[:action] = :create
      options[:source] = source
    end
    
    opts.on("-l", "--list", "List all translations") do
      options[:action] = :list
    end
    
    opts.on("-v", "--validate", "Validate translations") do
      options[:action] = :validate
    end
    
    opts.on("-t", "--template SOURCE TARGET_LANG", "Generate translation template") do |source|
      options[:action] = :template
      options[:source] = source
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  case options[:action]
  when :create
    if ARGV.length < 1
      puts "Error: Please specify target language"
      puts "Example: #{$0} --create _posts/2025-01-01-example.md en"
      exit 1
    end
    
    manager.create_translation(options[:source], ARGV[0])
    
  when :list
    manager.list_translations
    
  when :validate
    success = manager.validate_translations
    exit(success ? 0 : 1)
    
  when :template
    if ARGV.length < 1
      puts "Error: Please specify target language"
      puts "Example: #{$0} --template _posts/2025-01-01-example.md en"
      exit 1
    end
    
    manager.generate_translation_template(options[:source], ARGV[0])
    
  else
    puts "Error: Please specify an action"
    puts "Use --help for available options"
    exit 1
  end
end

if __FILE__ == $0
  main
end
