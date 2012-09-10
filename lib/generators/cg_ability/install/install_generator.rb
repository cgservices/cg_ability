require 'rails/generators'

module CgAbility
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option "current-user-helper", :type => :string

      desc "Used to install CG Ability"

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def engine
        Rails::Engine.subclasses.first.instance
      end
      
      def engine_root_path
        engine.root
      end

      def application_controler_path
        File.join engine_root_path, engine.paths["app/controllers"] ,engine.railtie_namespace.to_s.downcase, 'application_controller.rb'
      end

      def determine_current_user_helper
        current_user_helper = options["current-user-helper"].presence ||
                              ask("What will be the current_user helper called in your app? [current_user]").presence ||
                              :current_user

        puts "Defining engine_user method inside ApplicationController..."

        ability_methods = %Q{
    def current_ability
      CgAbility::Ability.new(engine_user)
    end

    def engine_user
      #{current_user_helper}
    end
    helper_method :engine_user
}

        inject_into_file("#{application_controler_path}",
                         ability_methods,
                         :after => "ActionController::Base\n")
      end

      def add_dependencies_initializer
        path = "#{engine_root_path}/config/initializers/_dependencies.rb"
        if File.exists?(path)
          puts "Skipping config/initializers/_dependencies.rb creation. Make sure you add\n require 'cg_ability'\nto your dependencies."
        else
          puts "Adding dependencies initializer (config/initializers/_dependencies.rb)..."
          template "_dependencies.rb", path
        end
      end

      def finished
        output = "\n\n" + ("*" * 53)
        output += %Q{\nDone! CgAbility has been successfully installed. Yaaaaay!\n\n}
        output += "Thanks for using CgAbility!"
        puts output
      end
    end
  end
end
