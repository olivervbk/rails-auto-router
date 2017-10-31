class NestedController < ActionController::Base
  include AutoRouter::Router
  route_controller('/nest/:nest_id/nested')

  route

  def nested_example(nest_id, value)
    render text: "nested id:#{nest_id}:#{value}"
  end
end