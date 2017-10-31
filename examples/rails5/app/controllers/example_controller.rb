class ApplicationController < ActionController::Base
  #protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token

  include AutoRouter::Router

  # route root path. Default would be 'examples'(collection) and 'example'(member)
  route_path('/example-route')


  ### SIMPLE EXAMPLES

  # simple get, without params
  route
  def simple_get; debug_response end

  # simple get , referencing method name instead
  routeable :referenced_get
  def referenced_get; debug_response end

  # get expecting param 'value'
  route
  def get_with_param(value); debug_response end

  # simple value post
  route via: 'post'
  def simple_post(value); debug_response end

  # simple get on member(identified by having param 'id')
  route
  def simple_member_get(id); debug_response end



  ### DEFAULT MAPPINGS

  route_index
  def index; debug_response end

  route_show
  def show(id); debug_response end

  route_update
  def update(id, value); debug_response end

  #other: route_new, route_create, route_edit, route_destroy



  ### ADVANCED EXAMPLES

  # responds to HEAD /example-route/:id/metadata
  route via:[:options], path: 'metadata', member: true
  def default_metadata; debug_response end


  protected

  # helper method to debug calls
  def debug_response
    calling_method = caller_locations(1,1).first.try(:label)
    keys = self.method(calling_method).parameters.map{|_type, param| param.to_s}
    params_str = keys.map{|k| [k, params[k]] }.map{|k,v|"- '#{k}': '#{v}'"}.join("\n")
    render plain: "#{request.method}:'#{calling_method}'\n#{params_str}"
  end
end
