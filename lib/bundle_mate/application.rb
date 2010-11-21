require 'simpleconsole'
require 'fileutils'

module BundleMate #:nodoc:
  class Application < SimpleConsole::Application #:nodoc:
    
    def self.run(input)
      super(input, Controller, View)
    end
    
    class Controller < SimpleConsole::Controller
      params :string  => {:u => :url},
             :int     => {:r => :revision},
             :bool    => {:y => :noprompt}
      
      before_filter :prepare_environment
      before_filter :create_local_repository, :only => [:install]
      after_filter  :reload_textmate_bundles, :only => [:install, :uninstall, :update]
      
      def default
        render :action => :help
      end
      
      def list
        @bundle_list = Bundle.remote_bundle_list
      end
      
      def info
        @bundle = Bundle.from_macromates(params[:id])
        @description = @bundle.meta_data('description').sanitize_html
      end
      
      def install
        if params[:url] 
          @bundle = Bundle.new(params[:url])
        else
          @bundle = Bundle.from_macromates(params[:id])
        end
        
        if @bundle.installed?
          puts "\n** #{@bundle.name} bundle is already installed. Use 'update' command instead. **\n\n"
        else
          revision = params[:revision] || 'HEAD'
          puts "\n** Installing #{@bundle.name} (revision: #{revision}) **\n\n"
          @result = @bundle.install(revision)
        end
      end
      
      def update
        @bundle = Bundle.from_macromates(params[:id])
        @result = @bundle.update
      end
      
      def update_all
        Bundle.installed_bundles.each do |bundle|
          puts "\n** Updating #{bundle.name} bundle. **"
          bundle.update
        end
      end
      
      def uninstall
        @bundle = Bundle.from_macromates(params[:id])
        uninstall_method = params[:noprompt] ? :uninstall : :uninstall_with_confirmation
        
        unless @bundle.installed?
          @already_uninstalled = true
        else
          @result = @bundle.send(uninstall_method)
        end
      end
      
      private        
        def prepare_environment
          ENV['LC_CTYPE'] = 'en_US.UTF-8'
          ENV['LC_ALL'] = nil
        end
        
        def create_local_repository
          FileUtils.mkdir_p(BundleMate::Bundle.local_bundle_path)
        end

        def reload_textmate_bundles
          BundleMate.reload_textmate_bundles!
        end
    end
    
    class View < SimpleConsole::View
      def list
        puts "\n** AVAILABLE BUNDLES **\n\n"
        @bundle_list.each { |name| puts "- #{name}" }
        puts "\nA total of #{@bundle_list.length} bundles were found."
      end
      
      def info
        puts "\n** #{@bundle.name} Bundle **"
        puts "#{@description}\n\n"
      end
      
      def install
        if @result
          puts "\n** #{@bundle.name} bundle installed successfully. **"
        else
          puts "\n** AN ERROR OCCURRED INSTALLING #{@bundle.name} BUNDLE **"
        end
      end
      
      def update
        if @result
          puts "\n** #{@bundle.name} bundle updated successfully. **"
        else
          puts "\n** AN ERROR OCCURRED UPDATING #{@bundle.name} BUNDLE **"
        end
      end
      
      def uninstall
        if @already_uninstalled
          puts "\n** #{@bundle.name} bundle is not installed. **\n\n"
          return
        end
        if @result
          puts "\n** #{@bundle.name} bundle uninstalled successfully. **"
        else
          puts "\n** #{@bundle.name} could not be uninstalled. **"
        end
      end
      
      def help
        version = BundleMate::VERSION::STRING
        
        puts %(
Bundlemate Utility #{version}
========================
             
Bundlemate is a command utility for managing TextMate bundles.

  Usage:
    bundlemate command [args] [options]

  Available commands:
    list               # List available bundles in the remote repository.
    info [name]        # Display the bundle description.
    install [name]     # Install bundle [name]. Use --url to specify the exact URL of a bundle.
    update [name]      # Download the latest updates for bundle [name]
    uninstall [name]   # Remove bundle [name] completely
    update_all         # Update all installed bundles
    help               # Displays this help text
    
  Options:
    -y (--noprompt)    # Automatically confirm any prompts.
    
  Examples:
    # installing bundles
    bundlemate install Ruby
    bundlemate install --url svn://rubyforge.org/var/svn/rspec/trunk/RSpec.tmbundle
    bundlemate install --url svn://rubyforge.org/var/svn/rspec/trunk/RSpec.tmbundle --revision 1234

    # update an existing bundle
    bundlemate update Ruby    
    
    # remove a bundle completely
    bundlemate uninstall Ruby
        
  Note:
    It is not necessary to reload TextMate's bundles manually, bundlemate
    will do this automatically when installing/updating/uninstalling a bundle.
        )
      end
    end
    
  end
end