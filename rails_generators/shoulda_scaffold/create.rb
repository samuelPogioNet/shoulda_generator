class Rails::Generator::Commands::Create
  def route_resources(*resources)
    nested_routes = resources.map{|r| ((r.kind_of? Array and r.length == 1) ? r[0] : r)}
    nested_routes.map! do |r|
      nr = [*r]
      logger.route "map.resources #{nr.join(".")}"
      route_nested([*nr[0...-1]], nr.last)
    end
    nested_routes *= "\n"

    sentinel = 'ActionController::Routing::Routes.draw do |map|'
    unless options[:pretend]
       gsub_file 'config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
        "#{match}\n#{nested_routes}\n"
      end
    end
  end

  def route_nested(namespaces, resource, depth = 1, parent_namespace = "map")
    if namespaces.length == 0
      "  "*depth + parent_namespace + ".resources " + resource.to_sym.inspect + "\n"
    else
      str = "  "*depth +  parent_namespace + ".namespace :#{namespaces[0].underscore} do |#{namespaces[0].underscore}|\n"
      str += route_nested(namespaces[1..-1], resource, depth+1, namespaces[0].underscore)
      str += "  "*depth + "end\n"
    end
  end
end