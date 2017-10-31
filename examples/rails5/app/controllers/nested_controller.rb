class NestedController < ActionController::Base
  include AutoRouter::Router
  route_path('/nest/:nest_id/nested')

  route
  def nested_example(nest_id, value)
    render plain: "nested id:#{nest_id}:#{value}"
  end
end