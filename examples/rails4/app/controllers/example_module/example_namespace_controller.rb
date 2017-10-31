module ExampleModule
  class ExampleNamespaceController < ActionController::Base
    include AutoRouter::Router
    #route_controller('/example_module/example_namespace') #automatic namespace recognition

    route
    def namespace_example
      render text: 'namespace_example'
    end
  end
end