module CgAbility
  class Ability
    include CanCan::Ability
    
    class << self
      def engine
        Rails::Engine.subclasses.first.instance
      end

      def roles
        app_roles = Ability.load_roles
        app_roles['roles']
      end

      def permissions
        app_roles = Ability.load_roles
        app_roles['permissions']
      end

      def roles_map
        roles_map = Ability.load_roles_map
        roles_map[Rails::Engine.subclasses.first.to_s]
      end

      def load_roles(file=engine.config.roles_yml)
        begin
          @@roles ||= YAML.load_file("#{engine.root}/config/#{file}")
        rescue
          raise "You need to define a roles.yml in your engine/config"
        end
      end

      def load_roles_map(file=Rails.application.config.engines_roles_map_yml)
        begin
          @@roles_map ||= YAML.load_file("#{Rails.root}/config/#{file}")
        rescue
          raise "You need to define a engine roles mapping in you application/config"
        end
      end
    end

    def initialize(user)
      return nil if user.blank?
      return nil unless mapped_role = Ability.roles_map[user.role.to_s]
      return nil unless permissions = Ability.permissions[mapped_role]
      

      permissions.each do |action, object|
        if object.is_a?(Hash)
          model = object["object"]
          options = object["options"]

          options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = eval(v); memo}
        else
          model = object
          options = {}
        end

        can action.to_sym, model == 'all'? model.to_sym : model.constantize, options
      end
    end
  end
end