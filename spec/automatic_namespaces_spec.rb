require "pathname"

rails_dir = Pathname.new(File.expand_path("fixtures/rails-7.0", __dir__))
Dir.chdir(rails_dir)
require_relative rails_dir.join("config/environment") # boot rails here

RSpec.describe AutomaticNamespaces do

  it "creates a namespace for each pack" do
    expect(defined?(Jackets)).to eq("constant")
  end

  it 'can find classes that ARE in an automatic namespace pack' do
    expect(defined?(Jackets::ClothingController)).to eq("constant")
    expect(defined?(Jackets::Summer)).to eq("constant")
    expect(defined?(Jackets::Winter)).to eq("constant")
  end

  it 'can find classes that are NOT in an automatic namespace pack' do
    expect(defined?(Pants::Jeans)).to eq("constant")
  end

  xit 'can find classes that are in an automatic namespace pack which use namespace override' do
    expect(defined?(ShoesUI::Sneakers)).to eq("constant")
  end
end
