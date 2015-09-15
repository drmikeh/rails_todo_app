# TODO CRUD App in Rails

This is a simple Rails App for a TODO list. This app uses the following technologies:

* [Ruby 2.2](https://www.ruby-lang.org/)
* [Rails 4.2](http://rubyonrails.org/)
* [PostgreSQL 9.4](http://www.postgresql.org/)
* [Twitter Bootstrap 3.3](http://getbootstrap.com/)
* [SASS 3.4](http://sass-lang.com/)
* [bootstrap-generators 3.3](https://github.com/decioferreira/bootstrap-generators)

We begin by building a simple Rails TODO app that uses SASS and Twitter Bootstrap for styling, and then add Authentication, Session Management, and Authorization. For educational purposes we are not using a 3rd party authentication library but we instead will build our own authentication and authorization as we go. For those who would like to investigate a 3rd party library for authentication and authorization, I recommend taking a look at [Devise](http://devise.plataformatec.com.br/).

The steps below will demonstrate how to create this project from scratch:

* [Step 1 - Generate The Project](#step-1---generate-the-project)
* [Step 2 - Add Gems](#step-2---add-gems)
* [Step 3 - Configure Scaffold Generator](#step-3---configure-scaffold-generator)
* [Step 4 - Configure the Project for SASS and Bootstrap](#step-4---configure-the-project-for-sass-and-bootstrap)
* [Step 5 - Create a Static Pages Controller and Views, the NavBar, and the Flash Messages Support](#step-5---create-a-static-pages-controller-and-views-the-navbar-and-the-flash-messages-support)
* [Step 6 - Add MVC CRUD for the TODOs](#step-6---add-mvc-crud-for-the-todos)
* [Intermission](#intermission)
* [Step 7 - Add MVC CRUD for User](#step-7---add-mvc-crud-for-user)
* [Step 8 - Create a Sessions Controller](#step-8---create-a-sessions-controller)
* [Step 9 - Add a Nice Bootswatch Theme](#step-9---add-a-nice-bootswatch-theme)
* [Bonus LAB Material](#bonus-lab-material)
* [Step 10 - Patch Security Holes](#step-10---patch-security-holes)

## Steps to reproduce

### Step 1 - Generate The Project

1a. Generate a new Rails project and initialize the GIT repo:
> Note that the `rails new` command will create a new subdirectory for you.

```bash
rails new --database=postgresql --skip-test-unit todo_app_auth
cd todo_app_auth
rake db:create
git init
git add -A
git commit -m "Created Rails project."
git tag step1
```

### Step 2 - Add Gems

In this step we add some nice gems to help us with Rails development:

* [bootstrap-generators](https://github.com/decioferreira/bootstrap-generators) - adds Twitter Bootstrap styling to our rails generated views, see further discussion in Step 3 below.
* [pry-rails](https://github.com/rweng/pry-rails) - causes `rails console` to open `pry` instead of `irb`
* [better_errors](https://github.com/charliesome/better_errors) - provides improved Rails error pages

2a. Edit the `Gemfile` and add the following gems:

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

For this project we will be using rails generators to scaffold some of our MVC code. We will also be using the SASS/SCSS version of [Twitter Bootstrap](http://getbootstrap.com/) for styling.

Unfortunately, the out-of-the-box rails generators produce views that are not easily compatible with Twitter Bootstrap. So we need to customize the generators to produce view code that contains Bootstrap styling. Fortunately there exist a gem called [bootstrap-generators](https://github.com/decioferreira/bootstrap-generators) that will assist us in this task.

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

### Step 4 - Configure the Project for SASS and Bootstrap

We will be using SASSy CSS (SCSS) for our styling and importing the Twitter Bootstrap SCSS files into our main `application.css.scss` file.

The `bootstrap:install` command from Step 3 created the files `bootstrap-generators.scss` and `bootstrap-variables.scss`. We will be removing `bootstrap-generators.scss` and putting that code in our `application.css.scss` file. We will also rename `bootstrap-variables.scss` to add an '_' prefix to the name to signify that it is a SASS partial file.

We will also create the file `_bootstrap-custom-variables.scss` to hold any custom Bootstrap variables assignments we may want to define.

4a. Rename the `application.css` file to `application.css.scss`, remove
`app/assets/stylesheets/bootstrap-generators.scss` and rename
`app/assets/stylesheets/bootstrap-variables.scss`:

```bash
mv app/assets/stylesheets/application.css app/assets/stylesheets/application.css.scss
rm app/assets/stylesheets/bootstrap-generators.scss
mv app/assets/stylesheets/bootstrap-variables.scss app/assets/stylesheets/_bootstrap-variables.scss
```

4b. Remove *everything* from `application.css.scss` and replace it with the following:

```sass
// "bootstrap-sprockets" must be imported before "bootstrap" for the icon fonts to work.
@import "bootstrap-variables.scss";
@import "bootstrap-custom-variables.scss";
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
  margin: 20px auto;
  width: 800px;
}

.todos {
  th, td {
    text-align:center
  }
}
```

4c. Create the file `app/assets/stylesheets/_bootstrap-custom-variables.scss` with the following content:

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

### Step 5 - Create a Static Pages Controller and Views, the NavBar, and the Flash Messages Support

We will generate a `static-pages-controller` and its related views that define two static pages: a *home* page and an *about* page. We will also move the *navbar* that was generated in Step 2 via the `rails generate bootstrap:install -f` command into a separate `html` partial file along with creating a partial file to hold just the *navbar* links. Finally we will create a *messages* `html` partial file for styling the Rails generated flash messages / alerts that indicate when an action was successful or failed.

5a. Generate the `static-pages-controller` and its related views:

```bash
rails g controller static_pages home about
```

5b. Edit `config/routes.rb` and replace the `static_pages` routes with the following:

```ruby
  root to: 'static_pages#home'
  match '/about', to: 'static_pages#about', via: 'get'
```

5c. Edit `app/views/static_pages/home.html.erb` and replace the content with:

```html
<div class="text-center jumbotron">
  <h1>Welcome to the TODO App</h1>
  <h3>This is the home page for the Rails TODO App with AuthN and AuthZ.</h3>
  <br/>
</div>
```

5d. Edit `app/views/static_pages/about.html.erb` and replace the content with:

```html
<% provide(:title, 'About') %>
<h2>A Simple TODO App with User Authentication</h2>
<h4>Technologies include:</h4>
<ul>
  <li><a href="https://www.ruby-lang.org/">Ruby 2.2</a></li>
  <li><a href="http://rubyonrails.org/">Rails 4.2</a></li>
  <li><a href="http://www.postgresql.org/">PostgreSQL 9.4</a></li>
  <li><a href="http://getbootstrap.com/">Twitter Bootstrap 3.3</a></li>
  <li><a href="http://sass-lang.com/">SASS 3.4</a></li>
  <li><a href="https://github.com/decioferreira/bootstrap-generators">bootstrap-generators 3.3</a></li>
</ul>
```

5e. Edit `app/views/layouts/application.html.erb` to set a dynamic title and replace the body with that provided below:

```html
    <title><%= full_title(yield(:title)) %></title>
```

```html
  <body>
    <header>
      <%= render 'layouts/navigation' %>
    </header>
    <main role="main" class="container-fluid">
       <%= render 'layouts/messages' %>
       <%= yield %>
    </main>
  </body>
```

5f. Create the file `app/views/layouts/_navigation.html.erb` with the following content:

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

5g. Create the file `app/views/layouts/_navigation_links.html.erb` with the following content:

```html
<li><%= link_to 'About', '/about' %></li>
```

5h. Create the file `app/views/layouts/_messages.html.erb`:

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

5i. Edit the file `app/helpers/application_helper.rb` and set the content to:

```ruby
module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "TODO App"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
end
```

5j. Commit your changes:

```bash
git add -A
git commit -m "Added static pages, navbar, and flash messages."
git tag step5
```

### Step 6 - Add MVC CRUD for the TODOs

We are finally ready to generate the MVC CRUD code for our TODOs list.

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
* replace the boolean `completed` value with a link and an icon

```html
<h1>Here are your TODOs</h1>
...
<div class="table-responsive todos">
...
        <th>Show</th>
        <th>Edit</th>
        <th>Destroy</th>
...
        <!-- <td><%= todo.completed %></td> -->
        <td>
        <%= link_to("/todos/#{todo.id}/toggle_completed") do %>
          <% if todo.completed %>
            <span class="glyphicon glyphicon-ok"></span>
          <% else %>
            <span class="glyphicon glyphicon-unchecked"></span>
          <% end %>
         <% end %>
        </td>
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

* add a `toggle_completed` method:

```ruby
def toggle_completed
  @todo.completed = !@todo.completed
  respond_to do |format|
    if @todo.save
      format.html { redirect_to todos_path }
      format.json { render :show, status: :ok, location: @todo }
    else
      # show some error message
    end
  end
end
```

6i. Add a route for the `toggle_completed` action:

Edit `config/routes.rb` and add the following line:

```ruby
  match 'todos/:id/toggle_completed', to: 'todos#toggle_completed', via: 'get'
```

6j. Commit your changes:

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

But we have one *major* problem: how do we support multiple users each with their own TODO list? To do that we need to add Authentication, Authorization, and Session Management to our app. But first, lets discuss some security concepts:

Let's talk about login id, passwords and session management:

* login_id               - we will use their email address
* password complexity    - we will use a REGEX
* password digest        - a one-way encryption so that passwords are not stored in plain text
* password confirmation  - make sure the user correctly creates their password
* keep user sessions     - use browser cookie containing a `remember_token` that is persisted in database

### Step 7 - Add MVC CRUD for User

To add AuthN/AuthZ and Session Management, we first need to add a User model and its associated MVC CRUD operations to our app.

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

7d. Edit the `add_user_ref_to_todos` migration script and add a not-null constraint: `null: false`

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

  validate :password_complexity

  def self.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def password_complexity
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
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

7h. Edit `app/controllers/users_controller.rb` and near the bottom replace the following line:

```ruby
params.require(:user).permit(:first_name,
                             :last_name,
                             :email,
                             :password_digest,
                             :remember_token)
```

with

```ruby
params.require(:user).permit(:first_name,
                             :last_name,
                             :email,
                             :password,
                             :password_confirmation)
```

7i. Edit `app/views/users/_form.html.erb` and change the `password_digest` and `remember_token` input labels and fields to:

```html
  <div class="form-group">
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

7k. Edit `app/views/users/new.html.erb` and remove the `Back` button and replace `<h1>New user</h1>` with `<h1>Sign Up</h1>`

7l. Edit `app/views/users/show.html.erb` and remove the `Back` button and the `password_digest` and `remember_token` fields.

7m. Commit your changes:

```bash
git add -A
git commit -m "Added MVC CRUD for User"
git tag step7
```

### Step 8 - Create a Sessions Controller

In this step we will create a `SessionsController` to handle our *sign-in* via its `new` and `create` actions and *sign-out* via its `destroy` action. We will also modify the `UsersController` so that its `new` and `create` actions will handle *sign-up* (i.e. registration). We will also create a `SessionsHelper` module to provide common authentication and session management support. Finally we will add dynamically controlled navigation links so that the appropriate links appear on the `navbar` depending on whether the user is currently signed in.

8a. Create `app/controllers/sessions_controller.rb` and `app/views/sessions/new.html.erb`

```bash
rails g controller sessions new create destroy
```

8b. Edit `app/views/sessions/new.html.erb` and insert the following content:

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

8c. Add the following to `app/helpers/sessions_helper.rb`:

```ruby
module SessionsHelper

  def sign_in(user)
    # save a cookie on their computer
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    # update our database with their cookie info
    user.update_attribute(:remember_token, User.digest(remember_token))
    # set a current_user variable equal to user
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  # set the current_user from the remember_token cookie
  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token  = User.digest(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  # check if the specified user is the current user
  def current_user?(user)
    user == current_user
  end

  # security check, ensure user is signed in, if not, redirect to signin page.
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Please sign in."
    end
  end

  def sign_out
    current_user.update_attribute(:remember_token,
                                  User.digest(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end

  # redirect back to the original requested view or to default
  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  # store the current location to support the redirect_back feature
  def store_location
    session[:return_to] = request.url if request.get?
  end
end
```

8d. Edit `app/controllers/sessions_controller.rb` to have the following content:

```ruby
class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      sign_in user
      redirect_back_or todos_path
    else
      flash.now[:error] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end
```

8e. Edit `app/controllers/users_controller.rb`:

Modify the `create` method to call the `sign_in` helper method and change the `redirect_to` target path and notice:

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

8f. Edit `config/routes.rb` and replace

```ruby
  get 'sessions/new'
  get 'sessions/create'
  get 'sessions/destroy'
```
with

```ruby
  resources :sessions, only:[:new, :create, :destroy]
```

and add the following:

```ruby
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
```

8g. Edit `app/controllers/application_controller.rb` and add the following line:

```ruby
  include SessionsHelper
```

8h. Edit `app/controllers/static_pages_controller.rb` and add a redirect to the
  `home` action:

```ruby
  def home
    redirect_to todos_path if signed_in?
  end
```

8i. Edit `app/controllers/todos_controller.rb`:

* add `before_action :signed_in_user`
* edit the `index` method:

```ruby
  def index
    @todos = current_user.todos.order(created_at: :desc)
  end
```

 * edit the `create` method to associate the user to a newly created Todo:

```ruby
  def create
    @todo = Todo.new(todo_params)
    @todo.user = current_user       # associate the new todo to the current_user
    ...
```

8j. Update `app/views/layouts/_navigation_links.html.erb` to match the following:

```html
<% if signed_in? %>
  <li><%= link_to 'TODOs', todos_path %></li>
  <li><%= link_to @current_user, user_path(@current_user) %></li>
  <li><%= link_to 'Sign out', signout_path, method: 'delete' %></li>
<% else %>
  <li><%= link_to 'Sign up', signup_path %></li>
  <li><%= link_to 'Sign in', signin_path %></li>
<% end %>
<li><%= link_to 'About', '/about' %></li>
```

8k. Edit `app/views/static_pages/home.html.erb` and add the following buttons to the bottom of the jumbotron:

```html
  <br/>
  <%= link_to "Sign up now!", signup_path, class: "btn btn-large btn-primary" %>
  <%= link_to "Sign in",      signin_path, class: "btn btn-large btn-primary" %>
```

8l. Commit your changes:

```bash
git add -A
git commit -m "Create the Sessions Controller, Sessions Helper, and navigation links."
git tag step8
```

### Step 9 - Add a Nice Bootswatch Theme

In this step we will add a [Bootswatch](https://bootswatch.com/) theme to our project, but instead of copying the bootswatch css into our project we will use a SASSy version of Bootswatch called [Bootswatch-Sass](https://github.com/log0ymxm/bootswatch-scss).

9a. Create the following files:

* _superhero-variables.scss - content from [Superhero Variables](https://raw.githubusercontent.com/log0ymxm/bootswatch-scss/master/superhero/_variables.scss)
* _superhero.scss - content from [Superhero Overrides](https://github.com/log0ymxm/bootswatch-scss/blob/master/superhero/_bootswatch.scss)

9b. Modify the imports in `app/assets/stylesheets/application.css.scss`:

```sass
@import "superhero-variables.scss";
@import "bootstrap-variables.scss";
@import "bootstrap-custom-variables.scss";
@import "bootstrap-sprockets.scss";
@import "bootstrap.scss";
@import "superhero.scss";
```

9c. Modify `app/views/todos/index.html.erb` and replace

```html
<table class="table table-striped table-bordered table-hover">
```

with

```html
<table class="table table-hover">
```

9d. Commit your changes:

```bash
git add -A
git commit -m "Added superhero Bootswatch theme."
git tag step9
```

### Bonus LAB Material

* Check for security holes and fix them:
  - See what routes a user can manually enter into the browser even if the
    user is not logged in
  - Can a user edit the account of another user? Can a user change another
    user's password?
  - See if a user can manually enter the URL for a TODO that is not one of
    their TODOs. Can the user edit or delete TODOs that they do not own?
* Change the UX:
  - Add a nice background image.
  - Try using other Bootswatch themes.
  - Change the NavBar.
* Add some more information to a user, such as `phone`, `city` and `state`, `occupation`, etc.
* Add some more attributes to a TODO, such as a `due_date` and a `priority`.
* Add a set of `keywords` to a Todo. There should be a `many-to-many` relationship between `todos` and `keywords` and the code should *not* create duplicate keywords.
* Replace the manual authentication with a gem like [Devise](http://devise.plataformatec.com.br/).


### Step 10 - Patch Security Holes

10a. Edit `app/controllers/users_controller.rb` and do the following:

* Add the following before actions:

```ruby
   before_action :signed_in_user, only: [:index, :show, :edit, :update, :destroy]
   before_action :verify_correct_user, only: [:show, :edit, :update, :destroy]
```

* Add the `verify_correct_user` private method:

```ruby
     def verify_correct_user
       user = User.find_by(id: params[:id])
       redirect_to root_url, notice: 'Access Denied!' unless current_user?(user)
     end
```

10b. Edit `app/controllers/todos_controller.rb` and do the following:

* Add the following before actions:

```ruby
  before_action :signed_in_user
  before_action :set_todo, only: [:toggle_completed, :show, :edit, :update, :destroy]
  before_action :verify_correct_user, only: [:show, :edit, :update, :destroy]
```

* Add the `verify_correct_user` private method:

```ruby
     def verify_correct_user
       @todo = current_user.todos.find_by(id: params[:id])
       redirect_to root_url, notice: 'Access Denied!' if @todo.nil?
     end
```
