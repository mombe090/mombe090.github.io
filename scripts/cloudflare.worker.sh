#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

# Function to check if Ruby is installed
check_ruby() {
  if ! command -v ruby &> /dev/null; then
    log_error "Ruby is not installed. Please install Ruby 3.3+ first."
    exit 1
  fi

  local ruby_version
  ruby_version=$(ruby -v | awk '{print $2}')
  log_info "Ruby version: ${ruby_version}"
}

# Function to check if Bundler is installed
check_bundler() {
  if ! command -v bundle &> /dev/null; then
    log_warn "Bundler is not installed. Installing..."
    gem install bundler
  fi

  local bundler_version
  bundler_version=$(bundle -v | awk '{print $3}')
  log_info "Bundler version: ${bundler_version}"
}

# Function to install Ruby dependencies
install_ruby_requirements() {
  log_info "Installing Ruby dependencies..."

  check_ruby
  check_bundler

  # Install required gems
  log_info "Installing gems from Gemfile..."
  bundle config set --local path 'vendor/bundle'
  bundle install

  log_info "Ruby requirements installed successfully!"
}

# Function to build Jekyll site
build_jekyll() {
  log_info "Building Jekyll site for production..."

  # Ensure dependencies are installed
  if [ ! -d "vendor/bundle" ] && [ ! -d ".bundle" ]; then
    log_warn "Dependencies not found. Installing..."
    install_ruby_requirements
  fi

  # Clean previous build
  if [ -d "_site" ]; then
    log_info "Cleaning previous build..."
    rm -rf _site
  fi

  # Build with production environment
  log_info "Running Jekyll build..."
  JEKYLL_ENV=production bundle exec jekyll build -d _site

  # Check if build was successful
  if [ -d "_site" ] && [ -f "_site/index.html" ]; then
    log_info "Jekyll build completed successfully!"
    log_info "Site generated in _site directory"

    # Display build statistics
    local file_count
    file_count=$(find _site -type f | wc -l)
    log_info "Generated ${file_count} files"
  else
    log_error "Jekyll build failed!"
    exit 1
  fi
}

# Function to validate the build
validate_build() {
  log_info "Validating build..."

  if [ ! -d "_site" ]; then
    log_error "_site directory not found!"
    exit 1
  fi

  # Check for essential files
  local required_files=("index.html" "assets" "posts")
  for file in "${required_files[@]}"; do
    if [ ! -e "_site/${file}" ]; then
      log_warn "Expected file/directory not found: ${file}"
    fi
  done

  log_info "Build validation completed!"
}

# Function to clean build artifacts
clean_build() {
  log_info "Cleaning build artifacts..."

  rm -rf _site
  rm -rf .jekyll-cache
  rm -rf .jekyll-metadata

  log_info "Build artifacts cleaned!"
}

# Main function
main() {
  local command="${1:-}"

  case "${command}" in
    install)
      install_ruby_requirements
      ;;
    build)
      build_jekyll
      ;;
    validate)
      validate_build
      ;;
    clean)
      clean_build
      ;;
    full)
      install_ruby_requirements
      build_jekyll
      validate_build
      ;;
    *)
      echo "Usage: $0 {install|build|validate|clean|full}"
      echo ""
      echo "Commands:"
      echo "  install   - Install Ruby dependencies"
      echo "  build     - Build Jekyll site for production"
      echo "  validate  - Validate the build output"
      echo "  clean     - Clean build artifacts"
      echo "  full      - Run install, build, and validate"
      exit 1
      ;;
  esac
}

# Run main function with all arguments
main "$@"
