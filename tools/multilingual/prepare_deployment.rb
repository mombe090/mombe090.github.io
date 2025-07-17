#!/usr/bin/env ruby

# Final Deployment Preparation Script
# Prepares the multilingual blog for production deployment

require 'yaml'
require 'json'
require 'fileutils'

class DeploymentPreparation
  def initialize
    @root_dir = Dir.pwd
    @errors = []
    @warnings = []
    @tasks_completed = []
  end

  def prepare_for_deployment
    puts "🚀 Preparing multilingual blog for deployment..."
    puts "=" * 60

    check_prerequisites
    validate_configuration
    optimize_for_production
    generate_deployment_assets
    create_deployment_checklist
    run_final_tests

    print_deployment_summary
  end

  private

  def check_prerequisites
    puts "\n✅ Checking prerequisites..."
    
    # Check Jekyll installation
    unless system('bundle exec jekyll --version > /dev/null 2>&1')
      add_error("Jekyll not properly installed or configured")
    else
      add_success("Jekyll installation verified")
    end

    # Check required plugins
    required_plugins = %w[
      _plugins/multilingual_support.rb
      _plugins/translation_fallbacks.rb
      _plugins/multilingual_sitemap.rb
      _plugins/multilingual_performance.rb
    ]

    required_plugins.each do |plugin|
      if File.exist?(plugin)
        add_success("Plugin #{File.basename(plugin)} found")
      else
        add_error("Missing required plugin: #{plugin}")
      end
    end

    # Check required includes
    required_includes = %w[
      _includes/lang/language-switcher.html
      _includes/lang/hreflang-tags.html
      _includes/lang/localized-navigation.html
    ]

    required_includes.each do |include_file|
      if File.exist?(include_file)
        add_success("Include #{File.basename(include_file)} found")
      else
        add_error("Missing required include: #{include_file}")
      end
    end
  end

  def validate_configuration
    puts "\n🔧 Validating configuration..."
    
    config_file = '_config.yml'
    unless File.exist?(config_file)
      add_error("Missing _config.yml file")
      return
    end

    config = YAML.load_file(config_file)
    
    # Check multilingual configuration
    unless config['languages']
      add_error("Missing 'languages' configuration")
    else
      add_success("Languages configured: #{config['languages'].join(', ')}")
    end

    unless config['default_language']
      add_error("Missing 'default_language' configuration")
    else
      add_success("Default language: #{config['default_language']}")
    end

    # Check language-specific configurations
    if config['lang_config']
      config['languages']&.each do |lang|
        if config['lang_config'][lang]
          add_success("Language config for #{lang} found")
        else
          add_warning("Missing language config for #{lang}")
        end
      end
    else
      add_warning("Missing 'lang_config' section")
    end
  end

  def optimize_for_production
    puts "\n⚡ Optimizing for production..."
    
    # Set production environment
    ENV['JEKYLL_ENV'] = 'production'
    add_success("Production environment set")

    # Optimize JavaScript
    js_file = 'assets/js/multilingual-blog.js'
    if File.exist?(js_file)
      optimize_javascript(js_file)
      add_success("JavaScript optimized")
    else
      add_warning("Multilingual JavaScript file not found")
    end

    # Optimize locale files
    optimize_locale_files
    add_success("Locale files optimized")

    # Generate minified translation files
    generate_minified_translations
    add_success("Minified translations generated")
  end

  def optimize_javascript(file_path)
    # Read and minify JavaScript (basic minification)
    content = File.read(file_path)
    
    # Remove comments and extra whitespace
    minified = content
      .gsub(/\/\*.*?\*\//m, '')  # Remove block comments
      .gsub(/\/\/.*$/, '')       # Remove line comments
      .gsub(/\s+/, ' ')          # Collapse whitespace
      .strip

    # Write minified version
    minified_path = file_path.gsub('.js', '.min.js')
    File.write(minified_path, minified)
  end

  def optimize_locale_files
    locale_dir = '_data/locales'
    return unless Dir.exist?(locale_dir)

    Dir.glob("#{locale_dir}/*.yml").each do |file|
      content = YAML.load_file(file)
      
      # Remove development-only keys
      content.delete('debug') if content['debug']
      content.delete('development') if content['development']
      
      # Rewrite file
      File.write(file, YAML.dump(content))
    end
  end

  def generate_minified_translations
    FileUtils.mkdir_p('assets/js/translations')
    
    locale_dir = '_data/locales'
    return unless Dir.exist?(locale_dir)

    Dir.glob("#{locale_dir}/*.yml").each do |file|
      lang = File.basename(file, '.yml')
      content = YAML.load_file(file)
      
      # Create minimal JSON for client-side use
      critical_translations = extract_critical_client_translations(content)
      
      json_file = "assets/js/translations/#{lang}.min.json"
      File.write(json_file, JSON.generate(critical_translations))
    end
  end

  def extract_critical_client_translations(translations)
    # Extract only translations needed for client-side functionality
    critical = {}
    
    %w[language_switcher search post panel tabs].each do |key|
      critical[key] = translations[key] if translations[key]
    end
    
    critical
  end

  def generate_deployment_assets
    puts "\n📦 Generating deployment assets..."
    
    # Generate sitemap
    system('bundle exec jekyll build --config _config.yml 2>/dev/null')
    if $?.success?
      add_success("Site built successfully")
    else
      add_error("Site build failed")
    end

    # Check generated sitemaps
    ['sitemap.xml', 'sitemap-fr.xml', 'sitemap-en.xml'].each do |sitemap|
      if File.exist?("_site/#{sitemap}")
        add_success("#{sitemap} generated")
      else
        add_warning("#{sitemap} not generated")
      end
    end

    # Generate robots.txt with sitemap references
    generate_robots_txt
    add_success("robots.txt updated")
  end

  def generate_robots_txt
    robots_content = <<~ROBOTS
      User-agent: *
      Allow: /

      # Sitemaps
      Sitemap: #{get_site_url}/sitemap.xml
      Sitemap: #{get_site_url}/sitemap-fr.xml
      Sitemap: #{get_site_url}/sitemap-en.xml

      # Disallow admin/development paths
      Disallow: /tools/
      Disallow: /_site/
      Disallow: /assets/js/translations/
    ROBOTS

    File.write('robots.txt', robots_content)
  end

  def get_site_url
    config = YAML.load_file('_config.yml')
    config['url'] || 'https://example.com'
  end

  def create_deployment_checklist
    puts "\n📋 Creating deployment checklist..."
    
    checklist = <<~CHECKLIST
      # Multilingual Blog Deployment Checklist

      ## Pre-deployment
      - [ ] All tests pass (run `ruby tools/multilingual/test_multilingual.rb`)
      - [ ] Validation passes (run `ruby tools/multilingual/validate_multilingual.rb`)
      - [ ] Production build successful (`JEKYLL_ENV=production bundle exec jekyll build`)
      - [ ] All required files present in `_site/`
      - [ ] Sitemaps generated (`_site/sitemap*.xml`)

      ## DNS & Hosting
      - [ ] Domain configured correctly
      - [ ] HTTPS certificate installed
      - [ ] CDN configured for static assets
      - [ ] Gzip compression enabled

      ## SEO & Analytics
      - [ ] Google Search Console configured
      - [ ] Google Analytics tracking code added
      - [ ] Hreflang tags verified in production
      - [ ] Sitemap submitted to search engines

      ## Performance
      - [ ] Page load times < 3 seconds
      - [ ] Core Web Vitals passing
      - [ ] Language switching < 1 second
      - [ ] Mobile responsiveness verified

      ## Functionality
      - [ ] Homepage loads in both languages
      - [ ] Language switcher works
      - [ ] All navigation links functional
      - [ ] 404 page displays correctly
      - [ ] Search functionality working

      ## Monitoring
      - [ ] Error monitoring configured
      - [ ] Performance monitoring setup
      - [ ] Uptime monitoring active
      - [ ] Log aggregation configured

      ## Post-deployment
      - [ ] Test all critical user paths
      - [ ] Verify analytics tracking
      - [ ] Monitor for 404 errors
      - [ ] Check search engine indexing

      Generated: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}
    CHECKLIST

    File.write('DEPLOYMENT_CHECKLIST.md', checklist)
    add_success("Deployment checklist created")
  end

  def run_final_tests
    puts "\n🧪 Running final tests..."
    
    # Run validation
    validation_result = system('ruby tools/multilingual/validate_multilingual.rb > /dev/null 2>&1')
    if validation_result
      add_success("Validation tests passed")
    else
      add_error("Validation tests failed")
    end

    # Test build
    build_result = system('JEKYLL_ENV=production bundle exec jekyll build > /dev/null 2>&1')
    if build_result
      add_success("Production build successful")
    else
      add_error("Production build failed")
    end

    # Check critical files exist
    critical_files = [
      '_site/index.html',
      '_site/fr/index.html',
      '_site/en/index.html',
      '_site/sitemap.xml',
      '_site/robots.txt'
    ]

    critical_files.each do |file|
      if File.exist?(file)
        add_success("Critical file #{file} exists")
      else
        add_error("Missing critical file: #{file}")
      end
    end
  end

  def add_success(message)
    puts "  ✅ #{message}"
    @tasks_completed << message
  end

  def add_error(message)
    puts "  ❌ #{message}"
    @errors << message
  end

  def add_warning(message)
    puts "  ⚠️ #{message}"
    @warnings << message
  end

  def print_deployment_summary
    puts "\n" + "=" * 60
    puts "DEPLOYMENT PREPARATION SUMMARY"
    puts "=" * 60
    
    puts "\n✅ COMPLETED TASKS (#{@tasks_completed.length}):"
    @tasks_completed.each_with_index { |task, i| puts "#{i+1}. #{task}" }
    
    if @errors.any?
      puts "\n❌ ERRORS (#{@errors.length}):"
      @errors.each_with_index { |error, i| puts "#{i+1}. #{error}" }
    end
    
    if @warnings.any?
      puts "\n⚠️ WARNINGS (#{@warnings.length}):"
      @warnings.each_with_index { |warning, i| puts "#{i+1}. #{warning}" }
    end
    
    puts "\n📝 NEXT STEPS:"
    if @errors.any?
      puts "❌ Fix all errors before deploying to production"
      puts "📖 Review DEPLOYMENT_CHECKLIST.md for detailed steps"
    else
      puts "🎉 Ready for deployment!"
      puts "📖 Follow DEPLOYMENT_CHECKLIST.md for production deployment"
      puts "🔗 Test your site: #{get_site_url}"
    end
    
    puts "=" * 60
  end
end

# Run deployment preparation
if __FILE__ == $0
  preparation = DeploymentPreparation.new
  preparation.prepare_for_deployment
end
