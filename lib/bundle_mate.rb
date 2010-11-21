require 'rubygems'

module BundleMate
  MACROMATES_REPOSITORY = 'http://svn.textmate.org/trunk/Bundles'
  
  def self.reload_textmate_bundles!
    system("osascript -e 'tell app \"TextMate\" to reload bundles'")
  end
  
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 1
    TINY  = 2

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end

class String
  def sanitize_html
    gsub(/<\/?[^>]*>/, "")
  end
end

%w( bundle_mate/bundle
    bundle_mate/application ).each { |lib|
  
  require File.join(File.dirname(__FILE__), lib) 
}

BundleMate::Bundle.local_bundle_path = File.expand_path("~/Library/Application Support/TextMate/Bundles")