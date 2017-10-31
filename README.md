# rails-auto-router
Java Spring / C# WebMVC like Action mappings for Rails 4/5

### THIS IS A PROOF OF CONCEPT ###
Please help development or share feedback. 
The idea is to define the route mappings inside the controllers instead of in the routes.rb file.

Reference of how it is done in Spring: https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping

# Getting started
## Install
Add to **Gemfile**:

`gem 'auto_router', '0.1.0', git: 'https://github.com/olivervbk/rails-auto-router.git', tag: 'v0.1.0'`

and run

`bundle install`

## Configure
Add to controller, like the example:
```ruby

class ExampleController < ActionController::Base
  include AutoRouter::Router
  route_path('/custom-path') # defeault would be controller name, this case '/example', '/examples'
  
  route #uses the next defined method. Should map to GET:'/examples/static'
  def static
    render plain: 'it works!'
  end
  
  route method: 'post' #can receive options. Since has 'id' as parameter, maps to POST:'/example/:id/test_post'
  def test_post(id, value, optional=nil)
    render plain: "test_post: '#{id}' - '#{value}' - '#{optional}'"
  end
  
  route_show
  def show(id)
    render plain: "show #{id}"
  end
  
  routeable :test_get #routeable needs the method name. Maps to GET:'/example/:id/test_get'
  def test_get(id, value, optional=nil)
    render plain: "test_get: '#{id}' - '#{value}' - '#{optional}'"
  end
end
```

Afterwards, call in **config/routes.rb**

```ruby
Rails.application.routes.draw do
  AutoRouter::Router.route!(self)
end
```

** For more examples, see example projects (Rails 4 and Rails 5) **

# How does it work?!!!
When `AutoRouter::Router.route!(self)` is called, the controllers (`app/controllers/**/*.rb`) are loaded. The included module `AutoRouter::Router` maps the controllers and adds the configured methods to the configuration.

For every mapped method, another method called 'autorouter_<method_name>' is created inside the controller, which will receive the action, obtain the parameters and call the original mapped method.

This plugin should be able to coexist with traditional routing.

# TO DO
1. configure support for before_action/before_filter 
2. fix name to rails_auto_router since it is really on rails plugin ?
3. publish 'stable' version.
4. validate required/optional params in functions, needs to call an error function?
5. able to configure custom behaviours depending on param names ('current_user', 'member' call special methods)


## Contributing
Sure, just send me a pull request with the changes :)

Feedback appreciated.
