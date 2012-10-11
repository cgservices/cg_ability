# CG Ability
A Gem for engine authorization. This gem extends the functionality of CanCan autorization gem. For a full set of options see CanCan documentation.

## Installation
### Specify dependency in your Gemfile
gem 'cg_ability', :git => "https://github.com/cgservices/cg_ability.git"

### Run the installer (from the dummy app)
    rails g cg_ability:install

#### Installing CgAbility
During installation you will be asked the following questions regarding your current user:
- What will be the current_user helper called in your app? [current_user]
If you don't know yet you'll have to set it later.

After install you will have 2 new functions in your Engine's application controller.
- current_abitily
- engine_user

### Requirements
CG Ability adds functions to your ApplicationController to identify the User from the Main Application. It asumes that your Main Application implements current_user for identifying the user that is logged in.

#### User model
Assuming your Engine doesn't have a user model you need to define where CgAbility can find the User class. You can do this by adding the following code to your lib/engine.rb
    mattr_accessor :user_class
  
    class << self
      def user_class
        if @@user_class.is_a?(Class)
          raise "Please use a string instead of Class."
        elsif @@user_class.is_a?(String)
          @@user_class.constantize
        end
      end
    end
    
### Usage
CG Ability looks in Engine.root/config for the yaml file defined in Engine.config.roles_yml. If this file is not found then Error will be raised.

    # config/initializers/x.rb
    module X
      class Engine < Rails::Engine
        config.roles_yml = "roles.yml"
      end
    end

To map Engine roles to Application roles CG Ability looks in Rails.root/config for the yaml file defined in Rails.application.config.engines_roles_map_yml

    # config/initializers/role_mappings.rb
    Dummy::Application.config.engines_roles_map_yml = "engines_roles_map.yml"

#### roles.yml
Engine roles are defined in roles.yml
Here's an example, the permission rules are the same as in CanCan, only that CG Ability expects them to be in a YAML file.

    roles:
      - admin
      - moderator
      - guest

    public_permissions: &public
      # public permissions goes here
      read: all

    permissions:
      admin:
        manage: all
      moderator:
        edit: 
          object: X::Contact
          options: 
            user_id: user.id
        <<: *public
      guest:
        <<: *public

#### engines_roles_map.yml
To match Application roles to Engine roles there is a engines_roles_map.yml
Each Engine has an entry in the YAML and the mapping is setup as: 
- application_role: engine_role

Here's an example

X::Engine:
  guru: moderator
  noob: guest
