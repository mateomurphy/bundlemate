require File.join(File.dirname(__FILE__), *%w[spec_helper])

module BundleMate
  
  describe Application, " when invoking the list command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
        
    it "should print bundle list to STDOUT" do
      Bundle.stubs(:remote_bundle_list).returns(%w(bundle_one bundle_two))
      BundleMate::Application.run(%w(list))
      
      @recorder.rewind
      output = @recorder.read
      output.should match(/bundle_one/)
      output.should match(/bundle_two/)
    end    
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end
  
  describe Application, " when invoking the info command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
    
    it "should download bundle information from repository and display its description" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.stubs(:meta_data).with('description').returns('My awesome bundle')
      BundleMate::Application.run(%w(info Ruby))
      
      @recorder.rewind
      output = @recorder.read
      output.should match(/My awesome bundle/)
    end
    
    it "should sanitize bundle of html description before displaying" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.stubs(:meta_data).with('description').returns(description = 'My <b>awesome</b> bundle')
      BundleMate::Application.run(%w(info Ruby))
      
      @recorder.rewind
      output = @recorder.read
      output.should match(/My awesome bundle/)
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end
  
  describe Application, " when invoking the install command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
        
    it "should install bundle from Macromates repository at HEAD revision" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:install).with('HEAD')
      BundleMate::Application.run(%w(install Ruby))
    end
    
    it "should print error message and not try and install bundle if bundle is already installed" do
      bundle = stub('bundle', :installed? => true, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:install).never
      BundleMate::Application.run(%w(install Ruby))
      @recorder.rewind
      output = @recorder.read
      output.should match(/already installed/)
    end
    
    it "should print error message if bundle installation fails" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:install).returns(false)
      BundleMate::Application.run(%w(install Ruby))
      @recorder.rewind
      output = @recorder.read
      output.should match(/ERROR OCCURRED INSTALLING/)
    end
    
    it "should install bundle from specific URL if specified" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:new).with('svn://myrepo.org/Ruby.tmbundle').returns(bundle)
      bundle.expects(:install).with(anything).returns(true)
      BundleMate::Application.run(%w(install --url svn://myrepo.org/Ruby.tmbundle))
    end
    
    it "should install bundle at specific revision if specified" do
      bundle = stub('bundle', :installed? => false, :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:install).with(1234)
      BundleMate::Application.run(%w(install Ruby --revision 1234))
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end
  
  describe Application, " when invoking the update command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
        
    it "should print bundle list to STDOUT" do
      bundle = stub('bundle', :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:update).returns(true)
      BundleMate::Application.run(%w(update Ruby))
      
      @recorder.rewind
      output = @recorder.read
      output.should match(/updated successfully/)
    end
    
    it "should print an error message if update fails" do
      bundle = stub('bundle', :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:update).returns(false)
      BundleMate::Application.run(%w(update Ruby))
      
      @recorder.rewind
      output = @recorder.read
      output.should match(/ERROR OCCURRED UPDATING/)
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end
  
  describe Application, " when invoking the update_all command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
    
    it "should update all installed bundles" do
      bundle = stub('bundle', :name => 'Ruby')
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      Bundle.stubs(:installed_bundles).returns([
          b1 = stub_everything('bundle'),
          b2 = stub_everything('bundle'),
          b3 = stub_everything('bundle')
        ])
      [b1, b2, b3].each { |bundle| bundle.expects(:update) }
      BundleMate::Application.run(%w(update_all))
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end
  
  describe Application, " when invoking the uninstall command" do
    
    before(:each) do
      $stdout = @recorder = StringIO.new
      BundleMate.stubs(:reload_textmate_bundles!)
    end
        
    it "should uninstall the specified bundle with confirmation" do
      bundle = stub('bundle', :name => 'Ruby', :installed? => true)
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:uninstall_with_confirmation).returns(true)
      BundleMate::Application.run(%w(uninstall Ruby))
    end
    
    it "should uninstall the specified bundle without confirmation if the -y switch is set" do
      bundle = stub('bundle', :name => 'Ruby', :installed? => true)
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:uninstall).returns(true)
      BundleMate::Application.run(%w(uninstall Ruby -y))
    end
    
    it "should display an error if the specified bundle is not installed" do
      bundle = stub('bundle', :name => 'Ruby', :installed? => false)
      Bundle.stubs(:from_macromates).with('Ruby').returns(bundle)
      bundle.expects(:uninstall).never
      BundleMate::Application.run(%w(uninstall Ruby))
    end
    
    after(:each) do
      $stdout = STDOUT
    end
    
  end

end