require File.join(Gem::Specification.find_by_name("railties").full_gem_path, "lib/rails/generators/erb/scaffold/scaffold_generator")

module Erb
  module Generators
    class ScaffoldGenerator
      # Enhance the Rails scaffold generator

      def add_to_navigation
        append_to_file "app/views/shared/_left_nav.html.erb" do
         "\n<li class=\"nav-item\">
            <%= link_to \"#{plural_table_name.titleize}\", #{index_helper(type: :path)}, class: \"nav-link \#{active_class(\"#{index_helper(type: :path)}\")} \" %>
         </li>"
        end
      end

    end
  end
end