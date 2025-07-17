# Multilingual Performance Optimization Plugin
# Optimizes performance for multilingual sites

module Jekyll
  class MultilingualPerformanceOptimizer < Generator
    safe true
    priority :low

    def generate(site)
      @site = site
      @languages = site.config['languages'] || ['fr']
      
      optimize_language_assets
      optimize_translation_loading
      add_performance_meta_tags
    end

    private

    def optimize_language_assets
      # Create language-specific asset collections
      @languages.each do |lang|
        create_language_asset_collection(lang)
      end
    end

    def create_language_asset_collection(language)
      # Group assets by language for better caching
      lang_assets = @site.static_files.select do |file|
        file.path.include?("/#{language}/") || 
        file.data&.dig('lang') == language
      end

      # Set cache headers for language-specific assets
      lang_assets.each do |asset|
        asset.data ||= {}
        asset.data['cache_control'] = 'public, max-age=31536000'
        asset.data['language'] = language
      end
    end

    def optimize_translation_loading
      # Create a minimal translation file for each language
      @languages.each do |lang|
        create_minimal_translation_file(lang)
      end
    end

    def create_minimal_translation_file(language)
      translations = load_language_translations(language)
      critical_translations = extract_critical_translations(translations)
      
      # Create a minimal JSON file for critical translations
      minimal_file = MinimalTranslationPage.new(@site, @site.source, "assets/js/translations", "#{language}.min.json")
      minimal_file.data['translations'] = critical_translations
      minimal_file.data['language'] = language
      @site.pages << minimal_file
    end

    def load_language_translations(language)
      locale_file = File.join(@site.source, '_data', 'locales', "#{language}.yml")
      return {} unless File.exist?(locale_file)
      
      YAML.load_file(locale_file) rescue {}
    end

    def extract_critical_translations(translations)
      # Extract only critical translations for initial page load
      critical_keys = %w[
        language_name
        language_switcher
        tabs
        search
        post
        panel
      ]
      
      critical = {}
      critical_keys.each do |key|
        critical[key] = translations[key] if translations[key]
      end
      
      critical
    end

    def add_performance_meta_tags
      # Add performance-related meta tags to all pages
      @site.pages.each do |page|
        add_performance_headers(page)
      end
    end

    def add_performance_headers(page)
      page.data ||= {}
      page.data['performance'] ||= {}
      
      # Add preload hints for critical resources
      page.data['performance']['preload'] = generate_preload_hints(page)
      
      # Add DNS prefetch for external resources
      page.data['performance']['dns_prefetch'] = [
        '//fonts.googleapis.com',
        '//fonts.gstatic.com',
        '//cdn.jsdelivr.net'
      ]
    end

    def generate_preload_hints(page)
      hints = []
      
      # Preload critical CSS
      hints << { rel: 'preload', href: '/assets/css/jekyll-theme-chirpy.css', as: 'style' }
      
      # Preload critical JavaScript
      hints << { rel: 'preload', href: '/assets/js/multilingual-blog.js', as: 'script' }
      
      # Preload language-specific translations
      if page.data['lang']
        hints << { 
          rel: 'preload', 
          href: "/assets/js/translations/#{page.data['lang']}.min.json", 
          as: 'fetch',
          crossorigin: 'anonymous'
        }
      end
      
      hints
    end
  end

  class MinimalTranslationPage < Page
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(@name)
      self.data = {}
    end

    def write(dest)
      dest_path = File.join(dest, @dir, @name)
      FileUtils.mkdir_p(File.dirname(dest_path))
      
      content = {
        language: self.data['language'],
        translations: self.data['translations'],
        generated_at: Time.now.utc.iso8601
      }
      
      File.write(dest_path, JSON.pretty_generate(content))
    end
  end

  # Cache optimization for multilingual content
  class MultilingualCache
    def self.cache_key(content, language)
      Digest::MD5.hexdigest("#{content.hash}-#{language}-#{Jekyll::VERSION}")
    end

    def self.cached_render(content, language, &block)
      cache_key = cache_key(content, language)
      
      if ENV['JEKYLL_ENV'] == 'production'
        Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          yield
        end
      else
        yield
      end
    end
  end
end
