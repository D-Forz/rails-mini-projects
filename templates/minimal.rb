# kill process on Mac OS X or Linux
run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [minimal](https://github.com/D-Forz/ruby-projects/tree/master/templates)
MARKDOWN

file "README.md", markdown_file_content, force: true

# Gemfile
########################################
inject_into_file "Gemfile", after: "platforms: %i[ mri mingw x64_mingw ]\n" do
  <<-RUBY
  gem "annotate"
  gem 'factory_bot_rails'
  gem 'rubocop-rails', require: false
  gem 'erb_lint', require: false

  gem "rspec-rails"
  gem "shoulda-matchers"
  RUBY
end

after_bundle do # rubocop:disable Metrics/BlockLength
  # Generators: db + rspec + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate(:controller, "pages", "home", "--skip-routes", "--no-test-framework")

  # Rspec
  ########################################
  run "rm -rf test"
  rails_command "generate rspec:install"
  run "mkdir spec/support"

  # Factories
  ########################################
  inject_into_file "spec/rails_helper.rb", after: "require 'rspec/rails'\n" do
    <<~RUBY
      require 'support/factory_bot'
      require 'support/shoulda_matchers'
    RUBY
  end

  file 'spec/support/factory_bot.rb', <<~RUBY
    require 'factory_bot'

    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY

  file 'spec/support/shoulda_matchers.rb', <<~RUBY
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
  RUBY

  # Routes
  ########################################
  route 'root to: "pages#home"'

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore .env file containing credentials.
    .env*
    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
    .Gemfile.lock
  TXT

  # Production env & github actions
  run "bundle lock --add-platform x86_64-linux"

  # Linters
  ########################################
  run "curl -L https://raw.githubusercontent.com/D-Forz/ruby-projects/master/templates/.rubocop.yml > .rubocop.yml"
  run "curl -L https://raw.githubusercontent.com/D-Forz/ruby-projects/master/templates/.erb-lint.yml > .erb-lint.yml"

  # Github Actions
  ########################################
  run "mkdir -p .github/workflows"
  run "curl -L https://raw.githubusercontent.com/D-Forz/ruby-projects/master/templates/.github/workflows/.lint.yml > .github/workflows/.lint.yml"
  run "curl -L https://raw.githubusercontent.com/D-Forz/ruby-projects/master/templates/.github/workflows/.tests.yml > .github/workflows/.tests.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with minimal setup'"
end
