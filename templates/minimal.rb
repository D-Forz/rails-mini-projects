# kill process on Mac OS X or Linux
run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [minimal](https://github.com/D-Forz/ruby-projects/templates)
MARKDOWN

file "README.md", markdown_file_content, force: true

# Gemfile
########################################
inject_into_file "Gemfile", after: "platforms: %i[ mri mingw x64_mingw ]\n" do
  <<-RUBY
  gem "rspec-rails"
  gem 'factory_bot_rails'
  RUBY
end

after_bundle do
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
    RUBY
  end

  file 'spec/support/factory_bot.rb', <<~RUBY
    require 'factory_bot'

    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
      config.before(:suite) do
        FactoryBot.find_definitions
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
  TXT

  # Rubocop
  ########################################
  run "curl -L https://raw.githubusercontent.com/D-Forz/ruby-projects/master/templates/.rubocop.yml > .rubocop.yml"

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with minimal setup'"
end
