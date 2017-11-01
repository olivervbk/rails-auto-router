module AutoRouter::Router

  require_relative 'router/router_helper'

  METHOD_PREFIX = 'autoroute_'

  @included_targets = []

  def self.included(target)
    app_clz = ActionController::Base
    raise "AutoRouter::Router - #{self} is not a #{app_clz}#" unless target < app_clz
    @included_targets << target
    target.extend(RouterHelper)
  end

  ##
  # helper method to list included targets
  def self.included_targets
    return @included_targets.dup #shouldnt be modified
  end

  ### -- route mapper
  @config = {}

  # internal!!
  def self.controller_config(clazz)
    return (@config[clazz] ||= {mappings: {}, path: nil})
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
  def self.route!(routes, opts={})
    autoload = opts[:autoload].nil? ? true : opts[:autoload]
    log_mappings = opts[:log].nil? ? true : opts[:log]

    Dir.glob(Rails.root.join('app/controllers', '**', '*.rb'), &method(:require)) if autoload

    @config.each do |ctrlr, config|
      ctrlr_mappings = config[:mappings]

      # .underscore already configures namespaces to slash ('/')
      resource_name = ctrlr.name.underscore.gsub('_controller', '').to_s
      controller_path = config[:path]
      ctrlr_mappings.each do |method_s, method_opts|
        method = ctrlr.public_instance_method(method_s)
        raise "#{self}.routeable: public instance method '#{method} not found'" if method.nil?

        method_params = method.parameters.map {|type, param| param}

        ## see RouterHelper#routeable
        via = method_opts[:via]
        method_path = method_opts[:path] || method_s
        is_member = method_opts[:member] || method_params.include?(:id)

        before_actions = method_opts[:before] || []
        actions = method_opts[:action] || {}

        ## create method wrapper in controller
        mapped_method = "#{METHOD_PREFIX}#{method_s}"
        if ctrlr.public_instance_method(mapped_method)
          raise "#{self}.routeable: method already exists: '#{mapped_method}'. Are you mapping the same method twice?"
        end

        ctrlr.class_eval {
          before_actions.each {|filter| before_action filter, only: mapped_method.to_sym}
          actions.each{|type, filter_params|
            filter = filter_params.delete(:filter)
            filtered = {only: mapped_method.to_sym}.merge(filter_params)
            send(type, filter, filtered)
          }

          define_method(mapped_method) {
            params = send(:params)
            #TODO validate required params? -> redirect_to some kind of error method?
            args = params.values_at(*method_params)
            send(method_s, *args)
          }
        }

        ## map created method inside routes
        default_ctrlr_path = (is_member ? resource_name.singularize : resource_name)
        res_path = controller_path.blank? ? default_ctrlr_path : controller_path

        resource_prefix = is_member ? "/#{res_path}/:id" : "/#{res_path}"
        match_path = (method_path.blank? ? resource_prefix : "#{resource_prefix}/#{method_path}").gsub('//', '/')
        to_path = "#{resource_name}##{mapped_method}"

        puts "#{self} -> match '#{match_path}', to: '#{to_path}', via: #{via}" if log_mappings

        routes.match match_path, to: to_path, via: via
      end
    end #do
  end #def

end #module
