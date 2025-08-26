/**
 * Multilingual Blog JavaScript Enhancements
 * Provides language persistence, smooth transitions, and enhanced UX
 */

(function() {
  'use strict';

  // Configuration
  const STORAGE_KEY = 'preferred_language';
  const DEFAULT_LANGUAGE = 'fr';
  const SUPPORTED_LANGUAGES = ['fr', 'en'];
  
  // Language preference management
  const LanguageManager = {
    
    /**
     * Get user's preferred language from localStorage
     */
    getPreferredLanguage() {
      if (typeof(Storage) !== "undefined") {
        return localStorage.getItem(STORAGE_KEY);
      }
      return null;
    },
    
    /**
     * Set user's preferred language in localStorage
     */
    setPreferredLanguage(language) {
      if (typeof(Storage) !== "undefined" && SUPPORTED_LANGUAGES.includes(language)) {
        localStorage.setItem(STORAGE_KEY, language);
        console.log('Language preference saved:', language);
      }
    },
    
    /**
     * Detect language from browser headers
     */
    detectBrowserLanguage() {
      if (navigator.language) {
        const browserLang = navigator.language.split('-')[0].toLowerCase();
        return SUPPORTED_LANGUAGES.includes(browserLang) ? browserLang : DEFAULT_LANGUAGE;
      }
      return DEFAULT_LANGUAGE;
    },
    
    /**
     * Get current page language
     */
    getCurrentLanguage() {
      // Check if page has language set in body data attribute or meta tag
      const bodyLang = document.body.getAttribute('data-lang');
      if (bodyLang && SUPPORTED_LANGUAGES.includes(bodyLang)) {
        return bodyLang;
      }
      
      // Check meta tag
      const metaLang = document.querySelector('meta[http-equiv="content-language"]');
      if (metaLang) {
        const lang = metaLang.getAttribute('content').split('-')[0].toLowerCase();
        if (SUPPORTED_LANGUAGES.includes(lang)) {
          return lang;
        }
      }
      
      // Extract from URL
      const pathLang = this.extractLanguageFromPath(window.location.pathname);
      if (pathLang) {
        return pathLang;
      }
      
      // Default
      return DEFAULT_LANGUAGE;
    },
    
    /**
     * Extract language from URL path
     */
    extractLanguageFromPath(path) {
      const match = path.match(/^\/([a-z]{2})\//);
      if (match && SUPPORTED_LANGUAGES.includes(match[1])) {
        return match[1];
      }
      return null;
    }
  };

  // Smooth transitions for language switching
  const TransitionManager = {
    
    /**
     * Add loading indicator during language switch
     */
    showLoadingIndicator() {
      // Remove existing indicator
      this.hideLoadingIndicator();
      
      const indicator = document.createElement('div');
      indicator.id = 'language-loading';
      indicator.innerHTML = `
        <div class="loading-spinner">
          <i class="fas fa-globe fa-spin"></i>
          <span>Switching language...</span>
        </div>
      `;
      
      // Add styles
      indicator.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.7);
        display: flex;
        justify-content: center;
        align-items: center;
        z-index: 9999;
        color: white;
        font-size: 1.1rem;
      `;
      
      const spinner = indicator.querySelector('.loading-spinner');
      spinner.style.cssText = `
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 1rem;
      `;
      
      document.body.appendChild(indicator);
    },
    
    /**
     * Hide loading indicator
     */
    hideLoadingIndicator() {
      const indicator = document.getElementById('language-loading');
      if (indicator) {
        indicator.remove();
      }
    },
    
    /**
     * Smooth page transition
     */
    smoothTransition(callback) {
      document.body.style.opacity = '0.7';
      document.body.style.transition = 'opacity 0.3s ease-out';
      
      setTimeout(() => {
        if (callback) callback();
      }, 150);
    }
  };

  // Language switcher functionality
  const LanguageSwitcher = {
    
    /**
     * Initialize language switcher
     */
    init() {
      this.setupEventListeners();
      this.highlightCurrentLanguage();
      this.checkLanguagePreference();
    },
    
    /**
     * Setup event listeners for language switching
     */
    setupEventListeners() {
      // Handle language option clicks
      document.addEventListener('click', (e) => {
        if (e.target.closest('.lang-option')) {
          e.preventDefault();
          const langOption = e.target.closest('.lang-option');
          const targetLang = langOption.getAttribute('data-lang');
          const targetUrl = langOption.getAttribute('href');
          
          this.switchLanguage(targetLang, targetUrl);
        }
      });
      
      // Handle keyboard navigation
      document.addEventListener('keydown', (e) => {
        if (e.altKey && e.key === 'l') { // Alt+L to toggle language
          e.preventDefault();
          this.toggleLanguage();
        }
      });
    },
    
    /**
     * Switch to target language
     */
    switchLanguage(targetLang, targetUrl) {
      if (!SUPPORTED_LANGUAGES.includes(targetLang)) {
        console.error('Unsupported language:', targetLang);
        return;
      }
      
      // Save preference
      LanguageManager.setPreferredLanguage(targetLang);
      
      // Show loading indicator
      TransitionManager.showLoadingIndicator();
      
      // Smooth transition
      TransitionManager.smoothTransition(() => {
        // Navigate to new URL
        window.location.href = targetUrl;
      });
      
      // Track language switch (if analytics is available)
      this.trackLanguageSwitch(targetLang);
    },
    
    /**
     * Toggle between available languages
     */
    toggleLanguage() {
      const currentLang = LanguageManager.getCurrentLanguage();
      const otherLang = SUPPORTED_LANGUAGES.find(lang => lang !== currentLang);
      
      if (otherLang) {
        const langOption = document.querySelector(`.lang-option[data-lang="${otherLang}"]`);
        if (langOption) {
          const targetUrl = langOption.getAttribute('href');
          this.switchLanguage(otherLang, targetUrl);
        }
      }
    },
    
    /**
     * Highlight current language in switcher
     */
    highlightCurrentLanguage() {
      const currentLang = LanguageManager.getCurrentLanguage();
      const langToggle = document.querySelector('.lang-toggle');
      
      if (langToggle) {
        langToggle.setAttribute('data-lang', currentLang);
        const langCode = langToggle.querySelector('.lang-code');
        if (langCode) {
          langCode.textContent = currentLang.toUpperCase();
        }
      }
    },
    
    /**
     * Check if user should be redirected based on language preference
     */
    checkLanguagePreference() {
      const preferredLang = LanguageManager.getPreferredLanguage();
      const currentLang = LanguageManager.getCurrentLanguage();
      
      // Don't auto-redirect, but show a notification if preferred language differs
      if (preferredLang && preferredLang !== currentLang) {
        this.showLanguageNotification(preferredLang);
      }
    },
    
    /**
     * Show language preference notification
     */
    showLanguageNotification(preferredLang) {
      // Check if translation exists
      const langOption = document.querySelector(`.lang-option[data-lang="${preferredLang}"]`);
      if (!langOption) return;
      
      const notification = document.createElement('div');
      notification.className = 'language-notification';
      notification.innerHTML = `
        <div class="notification-content">
          <i class="fas fa-info-circle"></i>
          <span>This page is also available in ${this.getLanguageName(preferredLang)}</span>
          <button class="switch-btn" data-lang="${preferredLang}" data-url="${langOption.href}">
            Switch
          </button>
          <button class="dismiss-btn">&times;</button>
        </div>
      `;
      
      // Add styles
      notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: var(--primary-color, #007bff);
        color: white;
        padding: 1rem;
        border-radius: 0.5rem;
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        z-index: 1000;
        max-width: 300px;
        animation: slideIn 0.3s ease-out;
      `;
      
      // Add animation styles
      const style = document.createElement('style');
      style.textContent = `
        @keyframes slideIn {
          from { transform: translateX(100%); opacity: 0; }
          to { transform: translateX(0); opacity: 1; }
        }
        .notification-content {
          display: flex;
          align-items: center;
          gap: 0.5rem;
          font-size: 0.9rem;
        }
        .switch-btn, .dismiss-btn {
          background: rgba(255,255,255,0.2);
          border: none;
          color: white;
          padding: 0.25rem 0.5rem;
          border-radius: 0.25rem;
          cursor: pointer;
          margin-left: auto;
        }
        .dismiss-btn {
          margin-left: 0.25rem;
          font-size: 1.1rem;
        }
        .switch-btn:hover, .dismiss-btn:hover {
          background: rgba(255,255,255,0.3);
        }
      `;
      document.head.appendChild(style);
      
      document.body.appendChild(notification);
      
      // Handle notification actions
      notification.querySelector('.switch-btn').addEventListener('click', () => {
        const lang = notification.querySelector('.switch-btn').getAttribute('data-lang');
        const url = notification.querySelector('.switch-btn').getAttribute('data-url');
        this.switchLanguage(lang, url);
      });
      
      notification.querySelector('.dismiss-btn').addEventListener('click', () => {
        notification.remove();
      });
      
      // Auto-dismiss after 5 seconds
      setTimeout(() => {
        if (notification.parentNode) {
          notification.remove();
        }
      }, 5000);
    },
    
    /**
     * Get display name for language
     */
    getLanguageName(lang) {
      const names = {
        'fr': 'French',
        'en': 'English'
      };
      return names[lang] || lang.toUpperCase();
    },
    
    /**
     * Track language switch for analytics
     */
    trackLanguageSwitch(targetLang) {
      // Google Analytics 4
      if (typeof gtag !== 'undefined') {
        gtag('event', 'language_switch', {
          'target_language': targetLang,
          'source_language': LanguageManager.getCurrentLanguage()
        });
      }
      
      // Google Analytics Universal
      if (typeof ga !== 'undefined') {
        ga('send', 'event', 'Language', 'Switch', targetLang);
      }
      
      console.log('Language switch tracked:', targetLang);
    }
  };

  // Search enhancement for multilingual content
  const SearchEnhancer = {
    
    /**
     * Initialize search enhancements
     */
    init() {
      this.setupSearchFilters();
    },
    
    /**
     * Setup language-specific search filters
     */
    setupSearchFilters() {
      const searchInput = document.querySelector('.search-input');
      if (searchInput) {
        const currentLang = LanguageManager.getCurrentLanguage();
        searchInput.setAttribute('data-lang', currentLang);
        
        // Add language filter to search results
        searchInput.addEventListener('input', this.filterSearchResults.bind(this));
      }
    },
    
    /**
     * Filter search results by current language
     */
    filterSearchResults(event) {
      const query = event.target.value.toLowerCase();
      const currentLang = LanguageManager.getCurrentLanguage();
      
      // This would integrate with your search implementation
      console.log('Search query:', query, 'Language:', currentLang);
    }
  };

  // Accessibility enhancements
  const AccessibilityEnhancer = {
    
    /**
     * Initialize accessibility enhancements
     */
    init() {
      this.addKeyboardShortcuts();
      this.enhanceScreenReaderSupport();
    },
    
    /**
     * Add keyboard shortcuts for accessibility
     */
    addKeyboardShortcuts() {
      document.addEventListener('keydown', (e) => {
        // Skip if user is typing in input fields
        if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
          return;
        }
        
        // Alt+L: Toggle language
        if (e.altKey && e.key === 'l') {
          e.preventDefault();
          LanguageSwitcher.toggleLanguage();
        }
      });
    },
    
    /**
     * Enhance screen reader support
     */
    enhanceScreenReaderSupport() {
      // Add language announcement for screen readers
      const currentLang = LanguageManager.getCurrentLanguage();
      document.documentElement.setAttribute('lang', currentLang);
      
      // Add aria-labels to language switcher
      const langToggle = document.querySelector('.lang-toggle');
      if (langToggle) {
        langToggle.setAttribute('aria-label', `Current language: ${LanguageSwitcher.getLanguageName(currentLang)}. Press to switch language.`);
      }
    }
  };

  // Initialize everything when DOM is ready
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Initializing multilingual blog enhancements...');
    
    LanguageSwitcher.init();
    SearchEnhancer.init();
    AccessibilityEnhancer.init();
    
    console.log('Multilingual blog enhancements initialized successfully');
  });

  // Handle page unload
  window.addEventListener('beforeunload', function() {
    TransitionManager.hideLoadingIndicator();
  });

  // Expose public API
  window.MultilingualBlog = {
    LanguageManager,
    LanguageSwitcher,
    TransitionManager,
    version: '1.0.0'
  };

})();
