import 'sync.just'

set shell := ['bash', '-eu', '-o', 'pipefail', '-c']

port := '4000'

default:
  just install
  just serve

install:
  mise exec ruby@3 -- bundle install

serve host='0.0.0.0' port=port:
  mise exec ruby@3 -- bundle exec jekyll serve --host {{host}} --port {{port}} --livereload

build:
  JEKYLL_ENV=production mise exec ruby@3 -- bundle exec jekyll b -d _site

test:
  bash tools/test.sh
