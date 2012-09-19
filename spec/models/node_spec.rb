# coding: utf-8

require 'spec_helper'

describe Contentr::Node do
  after(:all) do
    Contentr::Node.delete_all
  end

  it "create a single node" do
    node = Contentr::Node.create!(name: "Node1")
  end

  it "always has a name" do
    page = Contentr::Node.new(name: '')
    page.should_not be_valid
  end

  it "has an auto generated slug" do
    page = Contentr::Node.create!(name: "Node1")
    page.slug.should eql "node1"
  end

  it "slug can be set to a custom value" do
    page = Contentr::Node.create!(name: 'Node1', slug: 'test-page')
    page.slug.should eql 'test-page'
  end

  its 'slug matches the format /^[a-z0-9\s-]+$/' do
    page = Contentr::Node.new(:name => 'Some other Page')

    ['abc', '123', '123abc', 'abc123', 'abc-123', 'abc_123', 'abc+123', 'abc_123', 'öäüß'].each do |p|
      page.slug = p
      page.should be_valid, page.errors.full_messages.join('; ')
    end
  end

  its 'slug is unique within the parent scope' do
    page1 = Contentr::Node.create!(:name => 'Some Page', :slug => 'it-page')
    page2 = Contentr::Node.new(:name => 'Some other Page', :slug => 'it-page')
    page2.should_not be_valid
    assert_equal page2.errors.first[0], :slug
    assert_equal page2.errors.first[1], 'is already taken'
    # .. but we can use the same slug in another parent scope
    page2 = Contentr::Node.new(:name => 'Some other Page', :slug => 'it-page', :parent => page1)
    page2.should be_valid, page2.errors.full_messages.join('; ')
  end

  it 'has a generated path' do
    page1 = Contentr::Node.create!(:name => 'Page 1', :slug => 'page1')
    page2 = Contentr::Node.create!(:name => 'Page 2', :slug => 'page2', :parent => page1)
    page3 = Contentr::Node.create!(:name => 'Page 3', :slug => 'page3', :parent => page2)
    page1.url_path.should eql '/page1'
    page2.url_path.should eql '/page1/page2'
    page3.url_path.should eql '/page1/page2/page3'
  end

  its 'path can\'t be set manually' do
    page = Contentr::Node.create!(:name => 'Page 1', :slug => 'page1')
    page.url_path.should eql '/page1'
    lambda { page.url_path = 'this_is_not_allowed' }.should raise_error(RuntimeError)
  end

  it 'one can find a node by path' do
    page1 = Contentr::Node.create!(:name => 'Page 1', :slug => 'page1')
    page2 = Contentr::Node.create!(:name => 'Page 2', :slug => 'page2', :parent => page1)
    page3 = Contentr::Node.create!(:name => 'Page 3', :slug => 'page3', :parent => page2)
    Contentr::Node.find_by_path('/page1').should_not be_nil
    Contentr::Node.find_by_path('/page1/page2').should_not be_nil
    Contentr::Node.find_by_path('/page1/page2/page3').should_not be_nil
    Contentr::Node.find_by_path('/no_such_page').should be_nil
  end
end