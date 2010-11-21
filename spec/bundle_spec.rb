require File.join(File.dirname(__FILE__), *%w[spec_helper])

describe "Bundle" do
  before(:all) do
    BundleMate::Bundle.local_bundle_path = '/tmp/bundles'
  end
  
  before(:each) do
    @bundle = BundleMate::Bundle.new('http://example.com/bundles/example_bundle.tmbundle')
  end
  
  it "should report installed if bundle folder exists" do
    File.stubs(:exist?).with("/tmp/bundles/example_bundle.tmbundle").returns(true)
    @bundle.should be_installed
  end
  
  it "should report not installed if bundle folder does not exist" do
    File.stubs(:exist?).with("/tmp/bundles/example_bundle.tmbundle").returns(false)
    @bundle.should_not be_installed
  end
  
  it "should return meta data from remote plist file" do
    plist = stub('io', :read => 'plist data')
    @bundle.stubs(:open).with("http://example.com/bundles/example_bundle.tmbundle/info.plist").returns(plist)
    Plist.stubs(:parse_xml).with('plist data').returns({'description' => 'an example bundle'})
    @bundle.meta_data('description').should == 'an example bundle'
  end
end

describe "Bundle", " when installing" do
  before(:all) do
    BundleMate::Bundle.local_bundle_path = '/tmp/bundles'
  end
  
  before(:each) do
    @bundle = BundleMate::Bundle.new('http://example.com/bundles/example_bundle.tmbundle')
  end
  
  it "should checkout remote bundle at HEAD to local bundle path" do
    @bundle.expects(:system).with("cd '/tmp/bundles' && svn co -rHEAD http://example.com/bundles/example_bundle.tmbundle")
    @bundle.install
  end
  
  it "should checkout specific revision if specified" do
    @bundle.expects(:system).with("cd '/tmp/bundles' && svn co -r1234 http://example.com/bundles/example_bundle.tmbundle")
    @bundle.install(1234)
  end
end

describe "Bundle", " when updating" do
  before(:all) do
    BundleMate::Bundle.local_bundle_path = '/tmp/bundles'
  end
  
  before(:each) do
    @bundle = BundleMate::Bundle.new('example_bundle')
  end
  
  it "should run a subversion update against local path for bundle" do
    @bundle.expects(:system).with("cd '/tmp/bundles/example_bundle.tmbundle' && svn up")
    @bundle.update
  end
end

describe "Bundle", " when uninstalling" do
  before(:all) do
    BundleMate::Bundle.local_bundle_path = '/tmp/bundles'
  end
  
  before(:each) do
    @bundle = BundleMate::Bundle.new('example_bundle')
  end
  
  it "should delete bundle folder from system" do
    FileUtils.expects(:rm_rf).with('/tmp/bundles/example_bundle.tmbundle')
    @bundle.uninstall
  end
end

describe "Asking for all installed_bundles" do
  it "should return a bundle for each locally installed bundle" do
    Dir.stubs(:[]).with("/tmp/bundles/**/*.tmbundle").returns(%w(
      bundle_one.tmbundle/ bundle_two.tmbundle/ bundle_three.tmbundle/
    ))
    bundles = BundleMate::Bundle.installed_bundles
    bundles.size.should == 3
    bundles[0].name.should == 'bundle_one'
    bundles[1].name.should == 'bundle_two'
    bundles[2].name.should == 'bundle_three'
  end
end