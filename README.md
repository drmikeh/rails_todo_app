# TODO CRUD App in Rails with Manual AuthN and Associations

## Steps to reproduce

### Step 1 - Generate The Project

Generate a new Rails project and initialize the GIT repo:
> Note that the `rails new` command will create a new subdirectory for you

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

Commit your changes:

```bash
bundle install
git add -A
git commit -m "Added gems."
git tag step2
```

### Step 3 - Configure Scaffold Generator

Install the custom templates:

```bash
rails generate bootstrap:install -f
```

Add the following to `config/application.rb`:

```ruby
module TodoApp
  class Application < Rails::Application

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
    end
```

Commit your changes:

```bash
git add -A
git commit -m "Configured custom templates for Scaffolding"
git tag step3
```

### Step 4 - Configure Project for Bootstrap SASS

Rename the `application.css` file to `application.css.scss`, remove
`app/assets/stylesheets/bootstrap-generators.scss` and rename
`app/assets/stylesheets/bootstrap-variables.scss`:

```bash
mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss
rm app/assets/stylesheets/bootstrap-generators.scss
mv app/assets/stylesheets/bootstrap-variables.scss app/assets/stylesheets/_bootstrap-variables.scss
```

Remove *everything* from `application.scss` and replace it with the following:

```sass
// "bootstrap-sprockets" must be imported before "bootstrap" and "bootstrap/variables"
@import "bootstrap-variables.scss";
@import "bootstrap-custom.scss";
@import "bootstrap-sprockets.scss";
@import "bootstrap.scss";

body {
  padding-top: $navbar-height + 10px;
}

.page-header {
  a.btn {
    float: right;
  }

  a.btn + a.btn {
    margin-right: 8px;
  }
}

input[type="radio"], input[type="checkbox"] {
  width: initial;
  height: initial;
  margin-top: 7px;
}

main {
  margin: 20px;
}

.todos {
  max-width: 800px;
  th, td {
    text-align:center
  }
}
```

Create the file `app/assets/stylesheets/_bootstrap-custom.scss` with the following content:

```sass
// custom settings for Twitter Bootstrap
$body-bg: #4af;
```

Commit your changes:

```bash
git add -A
git commit -m "Configured for Bootstrap SASS"
git tag step4
```

