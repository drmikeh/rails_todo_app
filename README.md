# TODO CRUD App in Rails with Manual AuthN and Associations

## Steps to reproduce

### Step 1 - Generate The Project

```bash
rails new --database=postgresql --skip-test-unit todo_app_auth
cd todo_app_auth
rake db:create db:migrate
git init
git add -A
git commit -m "Created Rails project."
git tag step1
```

### Step 2 - Add Gems

Edit Gemfile and add the following gems:

```ruby

gem 'bootstrap-generators', '~> 3.3.4'

gem 'bcrypt', '~> 3.1.7'                # uncomment this line

group :development, :test do
  # Use pry with Rails console
  gem 'pry-rails'

  # Better Rails Error Pages
  gem 'better_errors'
end
```

```bash
bundle install
git add -A
git commit -m "Added gems."
git tag step2
```
