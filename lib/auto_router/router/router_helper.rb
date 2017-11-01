module AutoRouter::Router::RouterHelper
  @next_config = nil

  #TODO better name?
  ##
  # see #routeable for options
  def route(opts={})
    raise 'No method was defined since last RouterHelper.route. Did you mean routable ?' unless @next_config.nil?
    @next_config = opts
  end

  # shortcut methods for default mappings. See #route
  def route_index(opts={})
    route({via: :get, path: '', member: false}.merge(opts))
  end

  def route_new(opts={})
    route({via: :get, path: '/new', member: false}.merge(opts))
  end

  def route_create(opts={})
    route({via: :post, path: '', member: false}.merge(opts))
  end

  def route_show(opts={})
    route({via: :get, path: '', member: true}.merge(opts))
  end

  def route_edit(opts={})
    route({via: :get, path: '/edit', member: true}.merge(opts))
  end

  def route_update(opts={})
    route({via: [:patch, :put], path: '', member: true}.merge(opts))
  end

  def route_destroy(opts={})
    route({via: [:delete], path: '', member: true}.merge(opts))
  end

  ##
  # method: sym of controller method.
  # opts:
  #   via: what verb should be mapped, default:get. Examples: 'get', :get, [:get, :post], ['head']
  #   path: overwrite local path for method
  #   member: if is member or not. default: check if 'id' param is defined
  #   before: what before_filter should be applied for this method. Examples: :require_login, [:require_login]
  #   actions: actions for before|around|after|skip_before|etc*action filters.
  #     see: http://guides.rubyonrails.org/action_controller_overview.html#filters
  #     Example: {
  #         before_action: {filter: :require_login},
  #         around_action: {filter: :wrap_in_transaction},
  #         skip_before_action: {filter: :log_all_requests}
  #       }
  #TODO better name?
  def routeable(method, opts={})
    ctrlr_m = method.to_sym
    opts[:via] = Array.wrap(opts[:via] || :get).map{|hm|hm.to_sym}

    AutoRouter::Router.map_route(self, ctrlr_m, opts)
  end

  ##
  # set controller 'root' path
  def route_path(path)
    AutoRouter::Router.map_controller(self, path: path)
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
    self.public_instance_methods.select{|m|m.to_s.start_with?(AutoRouter::Router::METHOD_PREFIX)}
  end
end