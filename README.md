# rails-auto-router
Java Spring / C# WebMVC like Action mappings for Rails 4

### THIS IS A PROOF OF CONCEPT ###
Please help development or share feedback. I would say this isn't even usable for development in the current state.

The idea is to define the route mappings inside the controllers instead of in the routes.rb file.

Reference of how it is done in Spring: https://docs.spring.io/spring/docs/current/spring-framework-reference/web.html#mvc-ann-requestmapping

# Getting started
## Install
Add to **Gemfile**:

`gem 'auto_router', '0.1.X', git: 'https://github.com/olivervbk/rails-auto-router.git'`

and run

`bundle install`

## Configure
Add to controller, like the example:
```ruby

class ExampleController < ActionController::Base
  include AutoRouter::Router
  
  route #uses the next defined method. Should map to '/examples/static'
  def static
    render text: 'it works!'
  end
  
  route method: 'post' #can receive options. Since has 'id' as parameter, maps to '/example/:id/test_post'
  def test_post(id, value, optional=nil)
    render text: "test_post: '#{id}' - '#{value}' - '#{optional}'"
  end
  
  routeable :test_get #routeable needs the method name. Maps to '/example/:id/test_get'
  def test_get(id, value, optional=nil)
    render text: "test_get: '#{id}' - '#{value}' - '#{optional}'"
  end
end
```

Afterwards, call in **config/routes.rb**

```ruby
Rails.application.routes.draw do
  AutoRouter::Router.route!(self)
end
```

# How does it work?!!!
When `AutoRouter::Router.route!(self)` is called, the controllers (`app/controllers/\*\*/\*.rb`) are loaded. The included module `AutoRouter::Router` remembers the mapped controllers and adds the configured methods to the configuration.

For every mapped method, another method called 'autorouter_<method_name>' is created which will receive the action, obtain the parameters and call the original mapped method.

This plugin should be able to coexist with traditional routing.

# TO DO
1. create an example app to test different kinds of mappings
2. fix name to rails_auto_router since it is really on rails plugin
3. test configurations for controller (controller non-default path)
4. use better rails route configuration, instead of hardconfig with 'match'
5. allow resource for namespaces. Should be able to configure the paths for the namespaces?!
6. use default rails route configuration for \[:new,:update,:destroy,...\]
7. publish 'stable' version.
8. validate required/optional params in functions, needs to call an error function?

## Contributing
Sure, just send me a pull request with the changes :)

Feedback appreciated.
