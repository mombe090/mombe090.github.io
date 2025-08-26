# Language detection and context setting plugin for Jekyll multilingual support
# This plugin provides language detection from URLs and browser headers
# and sets up the language context for pages and posts

module Jekyll
  # Language detector for multilingual support
  class LanguageDetector
    def self.detect_language(site, page_url, headers = {})
      # Extract language from URL path
      if page_url =~ /^\/([a-z]{2})\//
        lang = $1
        return lang if site.config['languages'].include?(lang)
      end
      
      # Check browser Accept-Language header
      if headers['accept-language']
        preferred_languages = parse_accept_language(headers['accept-language'])
        preferred_languages.each do |lang|
          lang_code = lang.split('-').first.downcase
          return lang_code if site.config['languages'].include?(lang_code)
        end
      end
      
      # Default to site's default language
      site.config['default_language'] || site.config['lang'] || 'fr'
    end
    
    private
    
    def self.parse_accept_language(accept_language_header)
      # Parse Accept-Language header and return ordered list of preferred languages
      languages = []
      accept_language_header.split(',').each do |lang_entry|
        lang_parts = lang_entry.strip.split(';')
        lang = lang_parts[0].strip
        quality = 1.0
        
        if lang_parts.length > 1 && lang_parts[1].include?('q=')
          quality = lang_parts[1].split('=')[1].to_f
        end
        
        languages << { lang: lang, quality: quality }
      end
      
      # Sort by quality and return language codes
      languages.sort_by { |l| -l[:quality] }.map { |l| l[:lang] }
    end
  end

  # Hook to set language context for all pages and posts
  class LanguageContextGenerator < Generator
    safe true
    priority :high

    def generate(site)
      site.posts.docs.each do |post|
        set_language_context(site, post)
      end
      
      site.pages.each do |page|
        set_language_context(site, page)
      end
    end

    private

    def set_language_context(site, page)
      # Set language from front matter or detect from URL
      page.data['lang'] ||= detect_page_language(site, page)
      
      # Set up translation links if available
      setup_translation_links(site, page)
      
      # Set localized site configuration
      setup_localized_config(site, page)
    end

    def detect_page_language(site, page)
      # Check if language is specified in front matter
      return page.data['lang'] if page.data['lang']
      
      # Detect from URL path
      url = page.url || page.data['permalink'] || ''
      
      # Check for language prefix in URL
      if url =~ /^\/([a-z]{2})\//
        lang = $1
        return lang if site.config['languages']&.include?(lang)
      end
      
      # Check if page is in a language-specific directory
      if page.path =~ /_posts\/([a-z]{2})\//
        lang = $1
        return lang if site.config['languages']&.include?(lang)
      end
      
      # Default to site's default language
      site.config['default_language'] || site.config['lang'] || 'fr'
    end

    def setup_translation_links(site, page)
      # Set up translation links from front matter or translation data
      page.data['translations'] ||= {}
      
      # If page has a translation_key, look up related translations
      if page.data['translation_key']
        translation_key = page.data['translation_key']
        translations = site.data['translations']&.dig('post_relationships', translation_key)
        
        if translations
          page.data['translations'] = translations
        end
      end
    end

    def setup_localized_config(site, page)
      lang = page.data['lang']
      
      # Set language-specific site configuration
      if site.config['lang_config'] && site.config['lang_config'][lang]
        lang_config = site.config['lang_config'][lang]
        page.data['site_title'] = lang_config['title']
        page.data['site_tagline'] = lang_config['tagline']
        page.data['site_description'] = lang_config['description']
      end
    end
  end

  # Liquid filter for language-aware URL generation
  module LanguageFilters
    def localize_url(url, target_lang)
      return url unless url && target_lang
      
      # Remove existing language prefix
      clean_url = url.gsub(/^\/[a-z]{2}\//, '/')
      
      # Add target language prefix (except for default language)
      if target_lang != @context.registers[:site].config['default_language']
        "/#{target_lang}#{clean_url}"
      else
        clean_url
      end
    end

    def language_url(url, from_lang, to_lang)
      return url unless url && from_lang && to_lang
      
      # Replace language prefix in URL
      if from_lang == @context.registers[:site].config['default_language']
        # Add language prefix to default language URL
        "/#{to_lang}#{url}"
      elsif to_lang == @context.registers[:site].config['default_language']
        # Remove language prefix for default language
        url.gsub(/^\/#{from_lang}\//, '/')
      else
        # Replace language prefix
        url.gsub(/^\/#{from_lang}\//, "/#{to_lang}/")
      end
    end

    def get_translation_url(page, target_lang)
      return nil unless page && target_lang
      
      # Check if page has direct translation links
      if page['translations'] && page['translations'][target_lang]
        return page['translations'][target_lang]
      end
      
      # Try to construct URL based on current page
      current_url = page['url']
      return language_url(current_url, page['lang'], target_lang)
    end
  end
end

# Register the filters with Liquid
Liquid::Template.register_filter(Jekyll::LanguageFilters)
