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

### Step 5 - Create a Static Pages Controller and Views, the NavBar, and Flash Messages

```bash
rails g controller static_pages home about
```

Edit `config/routes.rb` and replace the `static_pages` routes with the following:

```ruby
  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'
```

Edit `app/views/static_pages/home.html.erb` and replace the content with:

```html
<div class="text-center jumbotron">
  <h1>Welcome to the TODO App</h1>
  <h3>This is the home page for the Rails TODO App with AuthN and AuthZ.</h3>
  <br/>
</div>
```

Edit `app/views/static_pages/about.html.erb` and replace the content with:

```html
<% provide(:title, 'About') %>
<h2>A Simple TODO App with User Authentication</h2>
<h4>Technologies include:</h4>
<ul>
  <li>Ruby 2.2</li>
  <li>Rails 4.2</li>
  <li>PostgreSQL 9.4</li>
  <li>Bootstrap 3.3</li>
</ul>
```

Edit `app/views/layouts/application.html.erb` to set a dynamic title and
replace the body with that provided below:

```html
    <title><%= full_title(yield(:title)) %></title>
```

```html
  <body>
    <header>
      <%= render 'layouts/navigation' %>
    </header>
    <main role="main">
       <%= render 'layouts/messages' %>
       <%= yield %>
    </main>
  </body>
```

Create the file `app/views/layouts/_navigation.html.erb` with the following content:

```html
<%# navigation styled for Bootstrap 3.0 %>
<nav class="navbar navbar-default navbar-fixed-top">
  <div class="container">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
        <span class="sr-only">Toggle navigation</span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <%= link_to 'Home', root_path, class: 'navbar-brand' %>
    </div>
    <div class="collapse navbar-collapse">
      <ul class="nav navbar-nav navbar-right">
        <%= render 'layouts/navigation_links' %>
      </ul>
    </div>
  </div>
</nav>
```

Create the file `app/views/layouts/_navigation_links.html.erb` with the following content:

```html
<li><%= link_to 'About', '/about' %></li>
```

Create the file `app/views/layouts/_messages.html.erb`:

```html
<%# Rails flash messages styled for Bootstrap 3.0 %>
<% flash.each do |name, msg| %>
  <% if msg.is_a?(String) %>
    <div class="alert alert-<%= name.to_s == 'notice' ? 'success' : 'danger' %>">
      <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
      <%= content_tag :div, msg, :id => "flash_#{name}" %>
    </div>
  <% end %>
<% end %>
```

Commit your changes:

```bash
git add -A
git commit -m "Added static pages, navbar, and flash messages."
git tag step5
```

### Step 6 - Add MVC CRUD for the TODOs

Generate the MVC CRUD for TODOs:

```bash
rails g scaffold todo title:string completed:boolean
rake db:migrate
```

> Inspect the `config/routes.rb` file. A single line was added to configure
the 7 routes for our TODOs resource. That's nice!!!

Edit `app/models/todo.rb` and add the following:

```ruby
class Todo < ActiveRecord::Base
  validates :title, presence: true

  before_save :default_values

  private

  def default_values
    self.completed ||= false
    nil                           # required so that TX will not rollback!!!
  end
end
```

Edit `app/views/layouts/_navigation_links.html.erb` and add a link to our todos view:

```html
  <li><%= link_to 'TODOs', todos_path %></li>
```

Edit `app/views/todos/index.html.erb` and

* edit the `<h1>` tag
* add a `todos` CSS class to the outer `div`
* add the `Show`, `Edit`, and `Destroy` labels on the table headers
* replace the boolean `completed` value with an icon

```html
<h1>Here are your TODOs</h1>
...
<div class="table-responsive todos">
...
        <th>Show</th>
        <th>Edit</th>
        <th>Destroy</th>
...
          <% if todo.completed %>
          <td><span class="glyphicon glyphicon-ok"></span></td>
          <% else %>
          <td></td>
          <% end %>
```

Edit `app/views/todos/show.html.erb` and add the created_at attribute:

```html
  <dt>Created:</dt>
  <dd><%= @todo.created_at %></dd>
```

Edit `app/controllers/todos_controller.rb`

* replace
`@todos = Todo.all` with
`@todos = Todo.order(created_at: :desc)`

* replace all occurrances of
`redirect_to @todo` and `redirect_to todos_url` with
`redirect_to todos_path`

Commit your changes:

```bash
git add -A
git commit -m "Created MVC CRUD for a list of TODOs."
git tag step6
```

### Intermission

Let's reflect on what we have done:

* Created a Rails app
* Added some favorite gems
* Added custom scaffolding templates
* Configured for Bootrap and SASS
* Created some static pages, a navbar, and flash message support
* Created MVC CRUD for a list of TODOs

But we have one *major* problem: how do we support multiple users each with
their own TODO list?
