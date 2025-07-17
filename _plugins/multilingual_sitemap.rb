# Multilingual Sitemap Generator Plugin
# Generates language-specific sitemaps with proper hreflang attributes

module Jekyll
  class MultilingualSitemapGenerator < Generator
    safe true
    priority :low

    def generate(site)
      @site = site
      @languages = site.config['languages'] || ['fr']
      @default_language = site.config['default_language'] || 'fr'

      # Generate main sitemap index
      generate_sitemap_index

      # Generate language-specific sitemaps
      @languages.each do |lang|
        generate_language_sitemap(lang)
      end
    end

    private

    def generate_sitemap_index
      sitemap_index = @site.pages.find { |page| page.name == 'sitemap.xml' }
      
      unless sitemap_index
        sitemap_index = SitemapIndexPage.new(@site, @site.source, '', 'sitemap.xml')
        @site.pages << sitemap_index
      end

      sitemap_index.data['languages'] = @languages
    end

    def generate_language_sitemap(language)
      sitemap_page = LanguageSitemapPage.new(@site, @site.source, '', "sitemap-#{language}.xml")
      sitemap_page.data['language'] = language
      sitemap_page.data['posts'] = posts_for_language(language)
      sitemap_page.data['pages'] = pages_for_language(language)
      @site.pages << sitemap_page
    end

    def posts_for_language(language)
      if language == @default_language
        # Include legacy posts (without lang attribute) for default language
        @site.posts.docs.select do |post|
          post_lang = post.data['lang'] || @default_language
          post_lang == language
        end
      else
        @site.posts.docs.select { |post| post.data['lang'] == language }
      end
    end

    def pages_for_language(language)
      @site.pages.select do |page|
        page_lang = page.data['lang'] || @default_language
        page_lang == language && !page.data['exclude_from_sitemap']
      end
    end
  end

  class SitemapIndexPage < Page
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'sitemap-index.xml')
    end
  end

  class LanguageSitemapPage < Page
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir  = dir
      @name = name

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'language-sitemap.xml')
    end
  end
end
