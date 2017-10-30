module AutoRouter
  module Router
    module RouterHelper
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

    METHOD_PREFIX = 'autoroute_'

    @included_targets = []

    def Router.included(target)
      app_clz = ActionController::Base
      raise "AutoRouter::Router - #{self} is not a #{app_clz}#" unless target < app_clz
      @included_targets << target
      target.extend(RouterHelper)
    end

    def self.extended(target)
      raise "AutoRouter::Router - Extended in '#{target}'. This shouldn't be done?"
    end

    def self.included_targets
      return @included_targets.dup #shouldnt be modified
    end

    ### -- route mapper
    @config = {}

    # internal!!
    def self.controller_config(clazz)
      return (@config[clazz] ||= {mappings:{}, path: nil} )
    end

    def self.map_controller(clazz, opts={})
      ctrlr_cfg = controller_config(clazz)
      ctrlr_cfg[:path] = opts[:path] unless opts[:path].nil?
    end

    def self.map_route(clazz, method, opts={})
      ctrlr_mappings = controller_config(clazz)[:mappings]
      raise "AutoRouter::Router - mapping already exists: #{clazz}##{method}" if ctrlr_mappings.include?(method)
      ctrlr_mappings[method] = opts
    end

    ### -- apply config!
    # routes: self in Rails.application.routes.draw
    # opts:
    #   autoload(true) - autoloads controllers to check mapped methods
    def self.route!(routes,opts={})
      autoload = opts[:autload] || true
      Dir.glob(Rails.root.join('app/controllers', '**', '*.rb'), &method(:require)) if autoload

      @config.each do |ctrlr, config|
        ctrlr_mappings = config[:mappings]

        resource_name = ctrlr.name.underscore.gsub('_controller', '').to_s
        controller_path = config[:path]
        ctrlr_mappings.each do |method_s, method_opts|
          method = ctrlr.public_instance_method(method_s)
          raise "#{self}.routeable: public instance method '#{method} not found'" if method.nil?

          method_params = method.parameters.map{|type,param| param}
          mapped_method = "#{METHOD_PREFIX}#{method_s}"
          ctrlr.class_eval{
            define_method(mapped_method){
              params = send(:params)
              #TODO validate required params? -> redirect_to some kind of error method?
              args = params.values_at(*method_params)
              send(method_s, *args)
            }
          }

          ## see RouterHelper#routeable
          via = method_opts[:via]
          method_path = method_opts[:path] || method_s
          is_member = method_opts[:member] || method_params.include?(:id)

          #TODO add support for controller namespaces...
          default_ctrlr_path = (is_member ? resource_name.singularize : resource_name)
          res_path = controller_path.blank? ? default_ctrlr_path : controller_path

          resource_prefix = is_member ? "/#{res_path}/:id" : "/#{res_path}"
          match_path = (method_path.blank? ? resource_prefix : "#{resource_prefix}/#{method_path}").gsub('//','/')
          to_path = "#{resource_name}##{mapped_method}"

          #TODO check log?
          puts "routes -> match '#{match_path}', to: '#{to_path}', via: #{via}"

          #TODO improve route generation to prefer rails defaults instead of hardcoded ones.
          routes.match match_path, to: to_path, via: via
        end
      end
    end
  end
end
