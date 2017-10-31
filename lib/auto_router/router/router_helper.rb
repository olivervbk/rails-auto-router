module AutoRouter::Router::RouterHelper
  @next_config = nil

  #TODO better name?
  def route(opts={})
    raise 'No method was defined since last RouterHelper.route. Did you mean routable ?' unless @next_config.nil?
    @next_config = opts
  end

  # shortcut methods for default mappings
  def route_index
    route via: :get, path: '', member: false
  end

  def route_new
    route via: :get, path: '/new', member: false
  end

  def route_create
    route via: :post, path: '', member: false
  end

  def route_show
    route via: :get, path: '', member: true
  end

  def route_edit
    route via: :get, path: '/edit', member: true
  end

  def route_update
    route via: [:patch, :put], path: '', member: true
  end

  def route_destroy
    route via: [:delete], path: '', member: true
  end

  ##
  # method: sym of controller method.
  # opts:
  #   via: 'get', :get, [:get, :post], ['head']
  #   path: overwrite local path for method
  #   member: if is member or not. default is check if 'id' param is defined
  #TODO better name?
  def routeable(method, opts={})
    ctrlr_m = method.to_sym
    opts[:via] = Array.wrap(opts[:via] || :get).map{|hm|hm.to_sym}

    Router.map_route(self, ctrlr_m, opts)
  end

  ##
  # set controller 'root' path
  def route_path(path)
    Router.map_controller(self, path: path)
  end

  def method_added(method)
    if @next_config
      routeable(method, @next_config)
      @next_config = nil
    end
  end

  ##
  # helper method to list mapped methods
  def autoroute_methods
    self.public_instance_methods.select{|m|m.to_s.start_with?(Router::METHOD_PREFIX)}
  end
end