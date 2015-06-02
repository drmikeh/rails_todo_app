# TODO CRUD App in Rails with Manual AuthN and Associations

## Steps to reproduce

### Step 1 - Generate The Project

1a. Generate a new Rails project and initialize the GIT repo:
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

2a. Edit Gemfile and add the following gems:

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

2b. Commit your changes:

```bash
bundle install
git add -A
git commit -m "Added gems."
git tag step2
```

### Step 3 - Configure Scaffold Generator

3a. Install the custom templates:

```bash
rails generate bootstrap:install -f
```

3b. Add the following to `config/application.rb`:

```ruby
module TodoApp
  class Application < Rails::Application

    config.generators do |g|
      g.orm             :active_record
      g.template_engine :erb
    end
```

3c. Commit your changes:

```bash
git add -A
git commit -m "Configured custom templates for Scaffolding"
git tag step3
```

### Step 4 - Configure Project for Bootstrap SASS

4a. Rename the `application.css` file to `application.css.scss`, remove
`app/assets/stylesheets/bootstrap-generators.scss` and rename
`app/assets/stylesheets/bootstrap-variables.scss`:

```bash
mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss
rm app/assets/stylesheets/bootstrap-generators.scss
mv app/assets/stylesheets/bootstrap-variables.scss app/assets/stylesheets/_bootstrap-variables.scss
```

4b. Remove *everything* from `application.scss` and replace it with the following:

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

4c. Create the file `app/assets/stylesheets/_bootstrap-custom.scss` with the following content:

```sass
// custom settings for Twitter Bootstrap
$body-bg: #4af;
```

4d. Commit your changes:

```bash
git add -A
git commit -m "Configured for Bootstrap SASS"
git tag step4
```

### Step 5 - Create a Static Pages Controller and Views, the NavBar, and Flash Messages

```bash
rails g controller static_pages home about
```

5a. Edit `config/routes.rb` and replace the `static_pages` routes with the following:

```ruby
  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'
```

5b. Edit `app/views/static_pages/home.html.erb` and replace the content with:

```html
<div class="text-center jumbotron">
  <h1>Welcome to the TODO App</h1>
  <h3>This is the home page for the Rails TODO App with AuthN and AuthZ.</h3>
  <br/>
</div>
```

5c. Edit `app/views/static_pages/about.html.erb` and replace the content with:

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

5d. Edit `app/views/layouts/application.html.erb` to set a dynamic title and
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

5e. Create the file `app/views/layouts/_navigation.html.erb` with the following content:

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

5f. Create the file `app/views/layouts/_navigation_links.html.erb` with the following content:

```html
<li><%= link_to 'About', '/about' %></li>
```

5g. Create the file `app/views/layouts/_messages.html.erb`:

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

5h. Commit your changes:

```bash
git add -A
git commit -m "Added static pages, navbar, and flash messages."
git tag step5
```

### Step 6 - Add MVC CRUD for the TODOs

6a. Generate the MVC CRUD for TODOs:

```bash
rails g scaffold todo title:string completed:boolean
```

6b. Edit `db/migrate/<migration_script_name>` and add `null: false` to the
`title` and `completed` columns, for instance:

```ruby
      t.string :title, null: false
      t.boolean :completed, null: false
```

6c. Run the migration:

```bash
rake db:migrate
```

> Inspect the `config/routes.rb` file. A single line was added to configure
the 7 routes for our TODOs resource. That's nice!!!

6d. Edit `app/models/todo.rb` and add the following:

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

6e. Edit `app/views/layouts/_navigation_links.html.erb` and add a link to our todos view:

```html
  <li><%= link_to 'TODOs', todos_path %></li>
```

6f. Edit `app/views/todos/index.html.erb` and

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

6g. Edit `app/views/todos/show.html.erb` and add the created_at attribute:

```html
  <dt>Created:</dt>
  <dd><%= @todo.created_at %></dd>
```

6h. Edit `app/controllers/todos_controller.rb`

* replace
`@todos = Todo.all` with
`@todos = Todo.order(created_at: :desc)`

* replace all occurrances of
`redirect_to @todo` and `redirect_to todos_url` with
`redirect_to todos_path`

6i. Commit your changes:

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

### Let's talk about login id, passwords and session management:

* login_id               - we will use their email address
* password complexity    - we will use a REGEX
* password digest        - a one-way encryption so that passwords are not stored in plain text
* password confirmation  - make sure the user correctly creates their password
* keep user sessions     - use browser cookie containing a `remember_token` that is persisted in database

### Step 7 - Add MVC CRUD for User

7a. Scaffold out the MVC CRUD for a User

```bash
rails g scaffold user first_name:string last_name:string email:string:uniq password_digest:string remember_token:string
```

7b. Edit the `create_users` migration script and add `null: false` to the
`first_name`, `last_name`, `email`, and `password_digest` columns.

7c. Create a migration to add a relationship from `todo` to `user`:

```bash
rails g migration AddUserRefToTodos user:references
```

7d. Edit the `add_user_ref_to_todos` migration script and add a not-null
constraint: `null: false`

7e. Run the migrations:

```bash
rake db:migrate
```

and inspect the file `db/schema.rb` to ensure that the model / table looks correct.

7f. Edit `app/models/user.rb` and add the following:

```ruby
class User < ActiveRecord::Base

  has_many :todos, dependent: :destroy

  before_save { email.downcase! }

  validates :first_name, :last_name, presence: true

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 80 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password

  validates :password, length: { minimum: 8, maximum: 20 }

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def to_s
    email
  end
end
```

7g. Edit `app/models/todo.rb` and add the following line:

```ruby
belongs_to :user
```

7h. Edit `app/controllers/users_controller.rb` and near the bottom replace the
following line:

`params.require(:user).permit(:first_name, :last_name, :email, :password_digest, :remember_token)` with
`params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)`

7i. Edit `app/views/users/_form.html.erb` and change the `password_digest` and
`remember_token` input labels and fields to:

```html
    <%= f.label :password, class: "col-sm-2 control-label" %>
    <div class="col-sm-10">
      <%= f.password_field :password, class: "form-control" %>
    </div>
  </div>
  <div class="form-group">
    <%= f.label :password_confirmation, class: "col-sm-2 control-label" %>
    <div class="col-sm-10">
      <%= f.password_field :password_confirmation, class: "form-control" %>
    </div>
  </div>
```

7j. Edit `app/views/users/edit.html.erb` and remove the `Back` button

7k. Edit `app/views/users/new.html.erb` and remove the `Back` button and replace
`<h1>New user</h1>` with `<h1>Sign Up</h1>`

7l. Edit `app/views/users/show.html.erb` and remove the `Back` button and the
`password_digest` and `remember_token` fields.

7m. Commit your changes:

```bash
git add -A
git commit -m "Added MVC CRUD for User"
git tag step6
```

### What's Left

* Create `app/controllers/sessions_controller.rb` and `app/views/sessions/new.html.erb`

```bash
rails g controller sessions new create destroy
```

Edit `app/views/sessions/new.html.erb` and insert the following content:

```html
<% provide(:title, "Sign in") %>
<h1>Sign in</h1>

<div class="row">
  <div class="span6 offset3">
    <%= form_for(:session, url: sessions_path) do |f| %>

      <%= f.label :email %>
      <%= f.text_field :email %>

      <%= f.label :password %>
      <%= f.password_field :password %>

      <%= f.submit "Sign in", class: "btn btn-large btn-primary" %>
    <% end %>

    <p>New user? <%= link_to "Sign up now!", signup_path %></p>
  </div>
</div>
```

* Create SessionsHelper module

Nx. Edit `app/controllers/users_controller.rb`:

* modify the `create` method to call the `sign_in` helper method that we will
  soon write and change the `redirect_to` target path and notice:

```ruby
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        sign_in @user
        format.html { redirect_to root_path, notice: 'Welcome!' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```


* Edit `config/routes.rb` and add the following:

```ruby
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
```

* Edit `app/controllers/application_controller.rb` and add the following line:

```ruby
  include SessionsHelper
```

* Edit `app/controllers/static_pages_controller.rb` and add a redirect to the
  `home` action:

```ruby
  def home
    redirect_to todos_path if signed_in?
  end
```

* Edit `app/controllers/todos_controller.rb`:
  - add `before_action :signed_in_user`
  - add the user to a newly created Todo:

```ruby
  def create
    @todo = Todo.new(todo_params)
    @todo.user = current_user       # associate the new todo to the current_user
    ...
```

* Update `app/views/layouts/_navigation_links.html.erb`:

```html
<% if signed_in? %>
  <li><%= link_to @current_user, user_path(@current_user) %></li>
  <li><%= link_to 'Sign out', signout_path, method: 'delete' %></li>
<% else %>
  <li><%= link_to 'Sign up', signup_path %></li>
  <li><%= link_to 'Sign in', signin_path %></li>
<% end %>
```

* Edit `app/views/static_pages/home.html.erb` and add the following buttons
  to the bottom of the jumbotron:

```html
  <%= link_to "Sign up now!", signup_path, class: "btn btn-large btn-primary" %>
  <%= link_to "Sign in",      signin_path, class: "btn btn-large btn-primary" %>
```


