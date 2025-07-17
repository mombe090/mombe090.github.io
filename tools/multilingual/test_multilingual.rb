#!/usr/bin/env ruby

# Comprehensive Multilingual Test Suite
# Tests all aspects of the multilingual blog implementation

require 'net/http'
require 'uri'
require 'json'
require 'nokogiri'

class MultilingualTestSuite
  def initialize(base_url = 'http://localhost:4000')
    @base_url = base_url
    @languages = ['fr', 'en']
    @default_language = 'fr'
    @errors = []
    @warnings = []
    @passed = 0
    @failed = 0
  end

  def run_all_tests
    puts "🧪 Starting Comprehensive Multilingual Test Suite..."
    puts "=" * 60

    test_site_accessibility
    test_language_detection
    test_url_structure
    test_language_switcher
    test_seo_optimization
    test_content_fallbacks
    test_navigation_localization
    test_404_page
    test_performance

    print_results
  end

  private

  def test_site_accessibility
    puts "\n🌐 Testing site accessibility..."
    
    response = make_request('/')
    if response.code == '200'
      log_pass("Homepage accessible")
    else
      log_fail("Homepage not accessible: #{response.code}")
    end

    @languages.each do |lang|
      url = lang == @default_language ? '/' : "/#{lang}/"
      response = make_request(url)
      
      if response.code == '200'
        log_pass("#{lang.upcase} homepage accessible")
      else
        log_fail("#{lang.upcase} homepage not accessible: #{response.code}")
      end
    end
  end

  def test_language_detection
    puts "\n🔍 Testing language detection..."
    
    # Test Accept-Language header detection
    ['fr-FR,fr;q=0.9', 'en-US,en;q=0.9', 'es-ES,es;q=0.9'].each do |accept_lang|
      response = make_request('/', { 'Accept-Language' => accept_lang })
      
      if response.code == '200'
        doc = Nokogiri::HTML(response.body)
        html_lang = doc.at('html')&.attr('lang')
        
        expected_lang = case accept_lang
                       when /^fr/ then 'fr'
                       when /^en/ then 'en'
                       else @default_language
                       end
        
        if html_lang == expected_lang
          log_pass("Language detection working for #{accept_lang}")
        else
          log_fail("Expected lang #{expected_lang}, got #{html_lang} for #{accept_lang}")
        end
      end
    end
  end

  def test_url_structure
    puts "\n🔗 Testing URL structure..."
    
    # Test legacy French URLs (backward compatibility)
    legacy_urls = ['/posts/kind/', '/posts/headlamp/', '/posts/k3s/']
    legacy_urls.each do |url|
      response = make_request(url)
      if response.code == '200' || response.code == '302'
        log_pass("Legacy URL #{url} accessible")
      else
        log_warn("Legacy URL #{url} not accessible: #{response.code}")
      end
    end

    # Test new multilingual URLs
    new_urls = ['/fr/posts/', '/en/posts/']
    new_urls.each do |url|
      response = make_request(url)
      if response.code == '200'
        log_pass("New multilingual URL #{url} accessible")
      else
        log_fail("New multilingual URL #{url} not accessible: #{response.code}")
      end
    end
  end

  def test_language_switcher
    puts "\n🔄 Testing language switcher..."
    
    response = make_request('/')
    if response.code == '200'
      doc = Nokogiri::HTML(response.body)
      
      # Check for language switcher presence
      switcher = doc.css('.language-switcher, #language-switcher').first
      if switcher
        log_pass("Language switcher found")
        
        # Check for language links
        @languages.each do |lang|
          lang_link = switcher.css("a[data-lang='#{lang}'], a[hreflang='#{lang}']").first
          if lang_link
            log_pass("#{lang.upcase} language link found")
          else
            log_fail("#{lang.upcase} language link missing")
          end
        end
      else
        log_fail("Language switcher not found")
      end
    end
  end

  def test_seo_optimization
    puts "\n🎯 Testing SEO optimization..."
    
    @languages.each do |lang|
      url = lang == @default_language ? '/' : "/#{lang}/"
      response = make_request(url)
      
      if response.code == '200'
        doc = Nokogiri::HTML(response.body)
        
        # Check hreflang tags
        hreflang_tags = doc.css('link[rel="alternate"][hreflang]')
        if hreflang_tags.any?
          log_pass("Hreflang tags found for #{lang.upcase}")
          
          @languages.each do |target_lang|
            hreflang_tag = hreflang_tags.find { |tag| tag['hreflang'] == target_lang }
            if hreflang_tag
              log_pass("Hreflang tag for #{target_lang.upcase} found")
            else
              log_fail("Hreflang tag for #{target_lang.upcase} missing")
            end
          end
        else
          log_fail("No hreflang tags found for #{lang.upcase}")
        end

        # Check lang attribute
        html_lang = doc.at('html')&.attr('lang')
        if html_lang == lang
          log_pass("HTML lang attribute correct for #{lang.upcase}")
        else
          log_fail("HTML lang attribute incorrect for #{lang.upcase}: expected #{lang}, got #{html_lang}")
        end
      end
    end
  end

  def test_content_fallbacks
    puts "\n🔄 Testing content fallbacks..."
    
    # Test accessing non-existent language content
    response = make_request('/es/posts/')
    if response.code == '404' || response.code == '302'
      log_pass("Non-existent language properly handled")
    else
      log_warn("Non-existent language response: #{response.code}")
    end
  end

  def test_navigation_localization
    puts "\n📍 Testing navigation localization..."
    
    @languages.each do |lang|
      url = lang == @default_language ? '/' : "/#{lang}/"
      response = make_request(url)
      
      if response.code == '200'
        doc = Nokogiri::HTML(response.body)
        
        # Check for localized navigation
        nav_items = doc.css('nav a, .navbar a, #sidebar a')
        if nav_items.any?
          log_pass("Navigation found for #{lang.upcase}")
        else
          log_warn("No navigation found for #{lang.upcase}")
        end
      end
    end
  end

  def test_404_page
    puts "\n❌ Testing 404 page..."
    
    response = make_request('/non-existent-page')
    if response.code == '404'
      doc = Nokogiri::HTML(response.body)
      
      # Check if 404 page has language switcher
      if doc.css('.language-switcher, #language-switcher').any?
        log_pass("404 page has language switcher")
      else
        log_warn("404 page missing language switcher")
      end
      
      log_pass("404 page accessible")
    else
      log_fail("404 page not working properly: #{response.code}")
    end
  end

  def test_performance
    puts "\n⚡ Testing performance..."
    
    start_time = Time.now
    response = make_request('/')
    load_time = Time.now - start_time
    
    if load_time < 2.0
      log_pass("Homepage loads quickly (#{load_time.round(2)}s)")
    elsif load_time < 5.0
      log_warn("Homepage loads slowly (#{load_time.round(2)}s)")
    else
      log_fail("Homepage loads too slowly (#{load_time.round(2)}s)")
    end

    # Check for JavaScript errors (basic check)
    if response.code == '200'
      doc = Nokogiri::HTML(response.body)
      if doc.css('script[src*="multilingual"]').any?
        log_pass("Multilingual JavaScript loaded")
      else
        log_warn("Multilingual JavaScript not found")
      end
    end
  end

  def make_request(path, headers = {})
    uri = URI("#{@base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = 10
    
    request = Net::HTTP::Get.new(uri)
    headers.each { |key, value| request[key] = value }
    
    begin
      http.request(request)
    rescue => e
      log_fail("Request failed for #{path}: #{e.message}")
      OpenStruct.new(code: '500', body: '')
    end
  end

  def log_pass(message)
    puts "  ✓ #{message}"
    @passed += 1
  end

  def log_fail(message)
    puts "  ❌ #{message}"
    @failed += 1
    @errors << message
  end

  def log_warn(message)
    puts "  ⚠️ #{message}"
    @warnings << message
  end

  def print_results
    puts "\n" + "=" * 60
    puts "TEST RESULTS"
    puts "=" * 60
    
    puts "✅ PASSED: #{@passed}"
    puts "❌ FAILED: #{@failed}" if @failed > 0
    puts "⚠️ WARNINGS: #{@warnings.length}" if @warnings.any?
    
    if @errors.any?
      puts "\n🚨 ERRORS:"
      @errors.each_with_index { |error, i| puts "#{i+1}. #{error}" }
    end
    
    if @warnings.any?
      puts "\n⚠️ WARNINGS:"
      @warnings.each_with_index { |warning, i| puts "#{i+1}. #{warning}" }
    end
    
    puts "\n📝 OVERALL STATUS:"
    if @failed == 0
      puts "🎉 All critical tests passed! The multilingual blog is working correctly."
    else
      puts "💥 Some tests failed. Please address the errors above."
    end
    
    puts "=" * 60
  end
end

# Run the test suite
if __FILE__ == $0
  test_suite = MultilingualTestSuite.new
  test_suite.run_all_tests
end
