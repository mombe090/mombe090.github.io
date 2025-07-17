# Fallback system for missing translations and content
# This plugin provides fallback mechanisms for multilingual Jekyll blogs

module Jekyll
  # Missing translation fallback system
  class TranslationFallbackGenerator < Generator
    safe true
    priority :low

    def generate(site)
      setup_translation_fallbacks(site)
      create_missing_language_pages(site)
      validate_translations(site)
    end

    private

    def setup_translation_fallbacks(site)
      # Add fallback filters to Liquid
      site.config['translation_fallback'] = true
      
      # Setup default translation patterns
      site.config['translation_patterns'] = {
        'missing_page_redirect' => true,
        'missing_translation_notice' => true,
        'suggest_related_content' => true
      }
    end

    def create_missing_language_pages(site)
      # Create placeholder pages for missing translations
      create_missing_category_pages(site)
      create_missing_tag_pages(site)
      create_missing_archive_pages(site)
    end

    def create_missing_category_pages(site)
      site.config['languages'].each do |lang|
        next if lang == site.config['default_language']
        
        # Create category index for each language
        create_language_page(site, lang, 'categories', 'category-index')
        
        # Create individual category pages
        site.categories.each do |category, posts|
          create_language_page(site, lang, "categories/#{category}", 'category')
        end
      end
    end

    def create_missing_tag_pages(site)
      site.config['languages'].each do |lang|
        next if lang == site.config['default_language']
        
        # Create tag index for each language
        create_language_page(site, lang, 'tags', 'tag-index')
        
        # Create individual tag pages
        site.tags.each do |tag, posts|
          create_language_page(site, lang, "tags/#{tag}", 'tag')
        end
      end
    end

    def create_missing_archive_pages(site)
      site.config['languages'].each do |lang|
        next if lang == site.config['default_language']
        
        create_language_page(site, lang, 'archives', 'archives')
      end
    end

    def create_language_page(site, lang, path, layout)
      # Check if page already exists
      existing_page = site.pages.find { |p| p.url == "/#{lang}/#{path}/" }
      return if existing_page

      # Create new page
      page = PageWithoutAFile.new(site, site.source, "", "#{path}.html")
      page.data['lang'] = lang
      page.data['layout'] = layout
      page.data['permalink'] = "/#{lang}/#{path}/"
      page.data['auto_generated'] = true
      
      # Add language-specific content
      setup_language_page_content(page, lang, layout)
      
      site.pages << page
    end

    def setup_language_page_content(page, lang, layout)
      case layout
      when 'category-index'
        page.data['title'] = get_localized_text(lang, 'tabs.categories', 'Categories')
      when 'tag-index'
        page.data['title'] = get_localized_text(lang, 'tabs.tags', 'Tags')
      when 'archives'
        page.data['title'] = get_localized_text(lang, 'tabs.archives', 'Archives')
      when 'category'
        category_name = page.data['permalink'].split('/').last
        page.data['title'] = get_localized_text(lang, 'layout.category', 'Category') + ": #{category_name}"
      when 'tag'
        tag_name = page.data['permalink'].split('/').last
        page.data['title'] = get_localized_text(lang, 'layout.tag', 'Tag') + ": #{tag_name}"
      end
    end

    def get_localized_text(lang, key, fallback)
      # This would need access to site.data.locales
      # For now, return fallback
      fallback
    end

    def validate_translations(site)
      missing_translations = []
      
      site.posts.docs.each do |post|
        if post.data['translation_key'] && post.data['translations']
          post.data['translations'].each do |lang, url|
            # Check if translation actually exists
            unless translation_exists?(site, url)
              missing_translations << {
                post: post.data['title'],
                lang: lang,
                url: url,
                translation_key: post.data['translation_key']
              }
            end
          end
        end
      end
      
      unless missing_translations.empty?
        Jekyll.logger.warn "Missing translations found:"
        missing_translations.each do |missing|
          Jekyll.logger.warn "  - #{missing[:post]} (#{missing[:lang]}): #{missing[:url]}"
        end
      end
    end

    def translation_exists?(site, url)
      # Check if a post exists with the given URL
      site.posts.docs.any? { |post| post.url == url }
    end
  end

  # Liquid filter for translation fallbacks
  module TranslationFallbackFilters
    def with_fallback(text, fallback_text = nil)
      return text if text && !text.empty?
      return fallback_text if fallback_text && !fallback_text.empty?
      return "[Translation missing]"
    end

    def localized_text(key, lang = nil, fallback = nil)
      # Get current page language
      current_lang = lang || @context.registers[:page]['lang'] || @context.registers[:site].config['lang']
      
      # Try to get text from locales
      locales = @context.registers[:site].data['locales']
      
      if locales && locales[current_lang]
        # Navigate through nested keys (e.g., 'tabs.home')
        keys = key.split('.')
        value = locales[current_lang]
        
        keys.each do |k|
          value = value[k] if value.is_a?(Hash)
          break unless value
        end
        
        return value if value && value.is_a?(String)
      end
      
      # Try fallback language
      default_lang = @context.registers[:site].config['default_language'] || 'fr'
      if current_lang != default_lang && locales && locales[default_lang]
        keys = key.split('.')
        value = locales[default_lang]
        
        keys.each do |k|
          value = value[k] if value.is_a?(Hash)
          break unless value
        end
        
        return value if value && value.is_a?(String)
      end
      
      # Return provided fallback or generate one
      return fallback if fallback
      return key.split('.').last.humanize
    end

    def translation_url(page, target_lang)
      return nil unless page && target_lang
      
      # Check direct translations
      if page['translations'] && page['translations'][target_lang]
        return page['translations'][target_lang]
      end
      
      # Try to construct URL for target language
      current_url = page['url']
      current_lang = page['lang'] || @context.registers[:site].config['lang']
      
      # If current is default language, add language prefix
      default_lang = @context.registers[:site].config['default_language'] || 'fr'
      
      if current_lang == default_lang && target_lang != default_lang
        return "/#{target_lang}#{current_url}"
      elsif current_lang != default_lang && target_lang == default_lang
        return current_url.gsub(/^\/#{current_lang}\//, '/')
      elsif current_lang != default_lang && target_lang != default_lang
        return current_url.gsub(/^\/#{current_lang}\//, "/#{target_lang}/")
      end
      
      return current_url
    end

    def has_translation?(page, target_lang)
      return false unless page && target_lang
      
      # Check if direct translation exists
      if page['translations'] && page['translations'][target_lang]
        # Verify the translation URL actually exists
        translation_url = page['translations'][target_lang]
        site = @context.registers[:site]
        
        # Check if any post or page has this URL
        all_docs = site.posts.docs + site.pages + site.collections.values.flat_map(&:docs)
        return all_docs.any? { |doc| doc.url == translation_url }
      end
      
      false
    end

    def suggest_related_content(page, target_lang, limit = 5)
      return [] unless page && target_lang
      
      site = @context.registers[:site]
      current_lang = page['lang'] || site.config['lang']
      
      # Get posts in target language
      target_posts = site.posts.docs.select { |post| 
        post.data['lang'] == target_lang 
      }
      
      return [] if target_posts.empty?
      
      # If current page has categories or tags, find similar content
      if page['categories'] || page['tags']
        related_posts = target_posts.select { |post|
          common_categories = (page['categories'] || []) & (post.data['categories'] || [])
          common_tags = (page['tags'] || []) & (post.data['tags'] || [])
          
          !common_categories.empty? || !common_tags.empty?
        }
        
        return related_posts.first(limit) unless related_posts.empty?
      end
      
      # Return recent posts in target language
      target_posts.sort_by { |post| post.date }.reverse.first(limit)
    end

    def missing_translation_notice(page, target_lang)
      current_lang = page['lang'] || @context.registers[:site].config['lang']
      site = @context.registers[:site]
      
      # Get localized notice text
      if current_lang == 'fr'
        notice = "Cette page n'est pas encore disponible en #{language_name(target_lang)}."
        suggestion = "Voici du contenu similaire qui pourrait vous intéresser :"
      else
        notice = "This page is not yet available in #{language_name(target_lang)}."
        suggestion = "Here's some similar content that might interest you:"
      end
      
      # Get related content
      related_posts = suggest_related_content(page, target_lang, 3)
      
      html = "<div class='missing-translation-notice'>"
      html += "<p class='notice-text'>#{notice}</p>"
      
      unless related_posts.empty?
        html += "<p class='suggestion-text'>#{suggestion}</p>"
        html += "<ul class='related-content-list'>"
        
        related_posts.each do |post|
          html += "<li><a href='#{post.url}'>#{post.data['title']}</a></li>"
        end
        
        html += "</ul>"
      end
      
      html += "</div>"
      html
    end

    private

    def language_name(lang)
      names = {
        'fr' => 'français',
        'en' => 'English'
      }
      names[lang] || lang.upcase
    end
  end

  # Error handling for missing layouts and includes
  class MissingResourceHandler
    def self.handle_missing_layout(site, layout_name, page)
      Jekyll.logger.warn "Missing layout '#{layout_name}' for page: #{page.path}"
      
      # Use default layout as fallback
      fallback_layout = site.config['default_layout'] || 'default'
      
      if site.layouts[fallback_layout]
        Jekyll.logger.info "Using fallback layout '#{fallback_layout}'"
        return fallback_layout
      end
      
      # Create minimal layout if no fallback exists
      create_minimal_layout(site, layout_name)
      return layout_name
    end

    def self.handle_missing_include(site, include_name, context)
      Jekyll.logger.warn "Missing include '#{include_name}'"
      
      # Return empty string or create placeholder
      return "<!-- Include '#{include_name}' not found -->"
    end

    private

    def self.create_minimal_layout(site, layout_name)
      # Create a minimal layout file in memory
      layout_content = <<~LAYOUT
        <!DOCTYPE html>
        <html lang="{{ page.lang | default: site.lang }}">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <title>{{ page.title | default: site.title }}</title>
        </head>
        <body>
          <main>
            {{ content }}
          </main>
        </body>
        </html>
      LAYOUT
      
      layout = Layout.new(site, site.source, '_layouts', "#{layout_name}.html")
      layout.content = layout_content
      site.layouts[layout_name] = layout
      
      Jekyll.logger.info "Created minimal layout '#{layout_name}'"
    end
  end
end

# Register the filters
Liquid::Template.register_filter(Jekyll::TranslationFallbackFilters)
