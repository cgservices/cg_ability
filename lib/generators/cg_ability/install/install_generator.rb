require 'rails/generators'

module CgAbility
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class_option "current-user-helper", :type => :string
      class_option "current-engine-helper", :type => :string

      desc "Used to install CG Ability"

      def self.source_root
        @source_root ||= File.expand_path('../templates', __FILE__)
      end

      def determine_current_engine_helper
        current_engine_helper = options["current-engine-helper"].presence ||
                                ask("What is the name of your engine (this is ussually the name of your module? [Engine]").presence ||
                                "Engine"
        @engine_name = "#{current_engine_helper}"

        if engine = Rails::Engine.subclasses.detect{|e| e.to_s == @engine_name}
          @engine = engine.instance
        else
         raise "Could not find given Engine. Please check the Engine name and try again."
        end
      end

      def application_controler_path
        File.join @engine.root, @engine.paths["app/controllers"], @engine.railtie_namespace.to_s.downcase, 'application_controller.rb'
      end

      def determine_current_user_helper
        current_user_helper = options["current-user-helper"].presence ||
                              ask("What will be the current_user helper called in your app? [current_user]").presence ||
                              :current_user

        puts "Defining engine_user method inside ApplicationController..."

        ability_methods = %Q{
    def current_ability
      CgAbility::Ability.new(engine_user, "#{@engine_name}")
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
        path = "#{@engine.root}/config/initializers/_dependencies.rb"
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
