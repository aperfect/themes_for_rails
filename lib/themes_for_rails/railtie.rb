# encoding: utf-8
module ThemesForRails
  class Railtie < ::Rails::Railtie

    config.themes_for_rails = ActiveSupport::OrderedOptions.new

    config.to_prepare do
      ThemesForRails::Railtie.config.themes_for_rails.each do |key, value|
        ThemesForRails.config.send "#{key}=".to_sym, value
      end
      
      # Adding theme stylesheets path to sass, automatically. 
      ThemesForRails.add_themes_path_to_sass if ThemesForRails.config.use_sass?
      
      ActiveSupport.on_load(:action_view) do
        include ThemesForRails::ActionView
      end

      ActiveSupport.on_load(:action_controller) do
        include ThemesForRails::ActionController
      end

      ActiveSupport.on_load(:action_mailer) do
        include ThemesForRails::ActionMailer
      end
    end

    # pulling assets paths from themes_on_rails gem
    initializer "themes_for_rails.assets_path" do |app|
      Dir.glob("#{Rails.root}/themes/*/assets/*").each do |dir|
        puts 'Adding to assets paths: '+dir
        app.config.assets.paths << dir
      end
    end

    if !Rails.env.development? && !Rails.env.test?
      initializer "themes_for_rails.precompile" do |app|
        app.config.assets.precompile += [ Proc.new { |path, fn| fn =~ /themes/ && !%w(.js .css).include?(File.extname(path)) } ]
        app.config.assets.precompile += Dir["themes/*"].map { |path| "#{path.split('/').last}/all.js" }
        app.config.assets.precompile += Dir["themes/*"].map { |path| "#{path.split('/').last}/all.css" }
      end
    end # end themes_on_rails code
    
    rake_tasks do
      load "tasks/themes_for_rails.rake"
    end
  end
end