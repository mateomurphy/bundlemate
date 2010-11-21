require 'plist'
require 'open-uri'
require 'fileutils'

module BundleMate

  class Bundle
    attr_reader :name
    
    def initialize(bundle_url)
      @url = bundle_url
      @name = File.basename(bundle_url, '.tmbundle')
    end
    
    def installed?
      File.exist?(local_path)
    end
    
    def meta_data(key)
      (@meta_data ||= remote_plist)[key]
    end
    
    def install(revision = 'HEAD')
      system("cd '#{self.class.local_bundle_path}' && svn co -r#{revision} #{remote_url}")
    end
    
    def update
      system("cd '#{local_path}' && svn up")
    end
    
    def uninstall_with_confirmation
      with_confirmation("About to remove #{local_path}.") do
        uninstall
      end
    end
  
    def uninstall
      FileUtils.rm_rf(local_path)
    end
  
    class << self
      attr_accessor :local_bundle_path
      
      def from_macromates(bundle_name)
        new(File.join(BundleMate::MACROMATES_REPOSITORY, bundle_name + '.tmbundle'))
      end
      
      def installed_bundles
        Dir["#{local_bundle_path}/**/*.tmbundle"].map do |bundle_path|
          new(File.basename(bundle_path, '.tmbundle'))
        end
      end
      
      def remote_bundle_list(repository = BundleMate::MACROMATES_REPOSITORY)
        `svn ls #{repository}`.split("\n").map do |bundle|
          bundle_name = bundle.match(/(.*)\.tmbundle\/$/)[1]
        end
      end
    end
    
    private
      def with_confirmation(confirmation_message, &block)
        puts confirmation_message
        print "Proceed? "
        input = $stdin.gets.strip
        yield if input =~ /^(yes|Yes|y|Y)/
      end
    
      def local_path
        File.join(self.class.local_bundle_path, bundle_file_name)
      end
      
      def bundle_file_name
        @name + '.tmbundle'
      end
      
      def remote_plist
        plist_xml = open(File.join(remote_url, 'info.plist')).read
        Plist.parse_xml(plist_xml)
      end
      
      def remote_url
        URI.encode(@url)
      end
  end
  
end