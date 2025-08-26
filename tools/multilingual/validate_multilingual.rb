#!/usr/bin/env ruby
# Content validation script for multilingual Jekyll blog
# Validates multilingual content consistency and structure

require 'yaml'
require 'fileutils'
require 'optparse'

class MultilingualValidator
  def initialize
    @root_dir = File.expand_path('../..', __dir__)
    @posts_dir = File.join(@root_dir, '_posts')
    @data_dir = File.join(@root_dir, '_data')
    @config_file = File.join(@root_dir, '_config.yml')
    @translations_file = File.join(@data_dir, 'translations.yml')
    @supported_languages = ['fr', 'en']
    @errors = []
    @warnings = []
  end

  def validate_all
    puts "🔍 Validating multilingual blog structure..."
    
    validate_configuration
    validate_directory_structure
    validate_locale_files
    validate_posts
    validate_translations
    validate_required_includes
    
    report_results
    
    @errors.empty?
  end

  def validate_configuration
    puts "\n📋 Validating configuration..."
    
    unless File.exist?(@config_file)
      add_error("Missing _config.yml file")
      return
    end

    config = YAML.load_file(@config_file)
    
    # Check required multilingual configuration
    unless config['languages']
      add_error("Missing 'languages' configuration in _config.yml")
    else
      unless config['languages'].is_a?(Array) && config['languages'].length >= 2
        add_error("'languages' must be an array with at least 2 languages")
      end
    end

    unless config['default_language']
      add_warning("Missing 'default_language' configuration (defaulting to 'fr')")
    end

    unless config['lang_config']
      add_error("Missing 'lang_config' section in _config.yml")
    else
      @supported_languages.each do |lang|
        unless config['lang_config'][lang]
          add_error("Missing language configuration for '#{lang}' in lang_config")
        else
          lang_config = config['lang_config'][lang]
          ['title', 'tagline', 'description'].each do |key|
            unless lang_config[key]
              add_warning("Missing '#{key}' for language '#{lang}' in lang_config")
            end
          end
        end
      end
    end

    puts "✓ Configuration validation complete"
  end

  def validate_directory_structure
    puts "\n📁 Validating directory structure..."
    
    # Check posts directory structure
    unless Dir.exist?(@posts_dir)
      add_error("Missing _posts directory")
      return
    end

    @supported_languages.each do |lang|
      lang_dir = File.join(@posts_dir, lang)
      unless Dir.exist?(lang_dir)
        add_warning("Missing language directory: _posts/#{lang}")
      end
    end

    # Check data directory
    unless Dir.exist?(@data_dir)
      add_error("Missing _data directory")
    end

    # Check includes directory
    includes_dir = File.join(@root_dir, '_includes')
    unless Dir.exist?(includes_dir)
      add_error("Missing _includes directory")
    else
      lang_includes_dir = File.join(includes_dir, 'lang')
      unless Dir.exist?(lang_includes_dir)
        add_warning("Missing _includes/lang directory for multilingual components")
      end
    end

    puts "✓ Directory structure validation complete"
  end

  def validate_locale_files
    puts "\n🌐 Validating locale files..."
    
    locales_dir = File.join(@data_dir, 'locales')
    unless Dir.exist?(locales_dir)
      add_error("Missing _data/locales directory")
      return
    end

    @supported_languages.each do |lang|
      locale_file = File.join(locales_dir, "#{lang}.yml")
      
      unless File.exist?(locale_file)
        add_error("Missing locale file: _data/locales/#{lang}.yml")
        next
      end

      begin
        locale_data = YAML.load_file(locale_file)
        validate_locale_structure(locale_data, lang)
      rescue => e
        add_error("Error parsing locale file #{lang}.yml: #{e.message}")
      end
    end

    puts "✓ Locale files validation complete"
  end

  def validate_locale_structure(locale_data, lang)
    required_keys = [
      'language_name',
      'language_code',
      'layout.post',
      'layout.category',
      'layout.tag',
      'tabs.home',
      'tabs.categories',
      'tabs.tags',
      'tabs.archives',
      'tabs.about',
      'search.hint',
      'search.cancel',
      'not_found.title',
      'not_found.message',
      'not_found.home_link'
    ]

    required_keys.each do |key_path|
      unless get_nested_value(locale_data, key_path)
        add_warning("Missing locale key '#{key_path}' in #{lang}.yml")
      end
    end
  end

  def validate_posts
    puts "\n📝 Validating posts..."
    
    all_posts = Dir.glob(File.join(@posts_dir, '**', '*.md'))
    
    if all_posts.empty?
      add_warning("No posts found")
      return
    end

    all_posts.each do |post_file|
      validate_post(post_file)
    end

    puts "✓ Posts validation complete"
  end

  def validate_post(post_file)
    begin
      content = File.read(post_file)
      
      # Extract and validate front matter
      if content =~ /\A---\s*\n(.*?)\n---\s*\n/m
        front_matter = YAML.safe_load($1)
        validate_post_front_matter(front_matter, post_file)
      else
        add_error("Missing front matter in #{relative_path(post_file)}")
      end
    rescue => e
      add_error("Error processing post #{relative_path(post_file)}: #{e.message}")
    end
  end

  def validate_post_front_matter(front_matter, post_file)
    file_path = relative_path(post_file)
    
    # Required fields
    required_fields = ['title', 'description', 'date']
    required_fields.each do |field|
      unless front_matter[field]
        add_error("Missing required field '#{field}' in #{file_path}")
      end
    end

    # Language validation
    if front_matter['lang']
      unless @supported_languages.include?(front_matter['lang'])
        add_error("Unsupported language '#{front_matter['lang']}' in #{file_path}")
      end
      
      # Check if post is in correct directory
      expected_dir = File.join(@posts_dir, front_matter['lang'])
      unless post_file.start_with?(expected_dir) || post_file.start_with?(@posts_dir + '/')
        add_warning("Post language '#{front_matter['lang']}' doesn't match directory structure in #{file_path}")
      end
    else
      # Check if post is in a language directory without lang field
      lang_match = post_file.match(%r{/_posts/([a-z]{2})/})
      if lang_match
        add_warning("Post in language directory but missing 'lang' field in #{file_path}")
      end
    end

    # Translation validation
    if front_matter['translation_key']
      validate_translation_key(front_matter['translation_key'], front_matter, file_path)
    end

    if front_matter['translations']
      validate_translations_field(front_matter['translations'], file_path)
    end

    # Permalink validation
    if front_matter['permalink']
      validate_permalink(front_matter['permalink'], front_matter['lang'], file_path)
    end
  end

  def validate_translation_key(translation_key, front_matter, file_path)
    # Check if translation key is used in translations.yml
    translations_data = load_translations_data
    
    unless translations_data['post_relationships'] && translations_data['post_relationships'][translation_key]
      add_warning("Translation key '#{translation_key}' not found in translations.yml for #{file_path}")
    end
  end

  def validate_translations_field(translations, file_path)
    unless translations.is_a?(Hash)
      add_error("'translations' field must be a hash in #{file_path}")
      return
    end

    translations.each do |lang, url|
      unless @supported_languages.include?(lang)
        add_warning("Unsupported translation language '#{lang}' in #{file_path}")
      end

      unless url.start_with?('/')
        add_error("Translation URL for '#{lang}' must start with '/' in #{file_path}")
      end
    end
  end

  def validate_permalink(permalink, lang, file_path)
    unless permalink.start_with?('/')
      add_error("Permalink must start with '/' in #{file_path}")
    end

    # Check if permalink matches expected pattern for language
    if lang && lang != 'fr' # Assuming 'fr' is default
      unless permalink.start_with?("/#{lang}/")
        add_warning("Permalink should start with '/#{lang}/' for language '#{lang}' in #{file_path}")
      end
    end
  end

  def validate_translations
    puts "\n🔗 Validating translations data..."
    
    unless File.exist?(@translations_file)
      add_warning("Missing translations.yml file")
      return
    end

    begin
      translations_data = YAML.load_file(@translations_file)
      validate_translations_structure(translations_data)
    rescue => e
      add_error("Error parsing translations.yml: #{e.message}")
    end

    puts "✓ Translations data validation complete"
  end

  def validate_translations_structure(translations_data)
    unless translations_data['post_relationships']
      add_warning("Missing 'post_relationships' section in translations.yml")
      return
    end

    translations_data['post_relationships'].each do |key, languages|
      unless languages.is_a?(Hash)
        add_error("Post relationship '#{key}' must be a hash")
        next
      end

      languages.each do |lang, url|
        unless @supported_languages.include?(lang)
          add_warning("Unsupported language '#{lang}' in translation key '#{key}'")
        end

        unless url.start_with?('/')
          add_error("Translation URL must start with '/' for key '#{key}', language '#{lang}'")
        end
      end
    end
  end

  def validate_required_includes
    puts "\n🧩 Validating required includes..."
    
    includes_dir = File.join(@root_dir, '_includes')
    required_includes = [
      'lang/language-switcher.html',
      'lang/hreflang-tags.html',
      'lang/localized-navigation.html'
    ]

    required_includes.each do |include_file|
      include_path = File.join(includes_dir, include_file)
      unless File.exist?(include_path)
        add_error("Missing required include file: _includes/#{include_file}")
      end
    end

    puts "✓ Required includes validation complete"
  end

  def load_translations_data
    if File.exist?(@translations_file)
      YAML.load_file(@translations_file) || {}
    else
      {}
    end
  end

  def get_nested_value(hash, key_path)
    keys = key_path.split('.')
    value = hash
    
    keys.each do |key|
      return nil unless value.is_a?(Hash) && value[key]
      value = value[key]
    end
    
    value
  end

  def relative_path(absolute_path)
    absolute_path.gsub(@root_dir + '/', '')
  end

  def add_error(message)
    @errors << message
  end

  def add_warning(message)
    @warnings << message
  end

  def report_results
    puts "\n" + "="*60
    puts "VALIDATION RESULTS"
    puts "="*60

    if @errors.empty? && @warnings.empty?
      puts "✅ All validations passed! Your multilingual blog structure is correct."
    else
      if @errors.any?
        puts "\n❌ ERRORS (#{@errors.length}):"
        @errors.each_with_index do |error, index|
          puts "#{index + 1}. #{error}"
        end
      end

      if @warnings.any?
        puts "\n⚠️  WARNINGS (#{@warnings.length}):"
        @warnings.each_with_index do |warning, index|
          puts "#{index + 1}. #{warning}"
        end
      end

      puts "\n📝 RECOMMENDATIONS:"
      puts "- Fix all errors before deploying"
      puts "- Address warnings to improve the multilingual experience"
      puts "- Run this validator again after making changes"
    end

    puts "\n" + "="*60
  end
end

# Command line interface
def main
  validator = MultilingualValidator.new
  
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} [options]"
    
    opts.on("-a", "--all", "Validate all aspects (default)") do
      options[:action] = :all
    end
    
    opts.on("-h", "--help", "Show this help") do
      puts opts
      exit
    end
  end.parse!

  success = validator.validate_all
  exit(success ? 0 : 1)
end

if __FILE__ == $0
  main
end
