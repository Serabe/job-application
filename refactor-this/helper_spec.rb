require 'rubygems'
require 'factory_girl'
require 'factories'
require 'spec'
require 'spec/autorun'
require 'redgreen'
require 'user_profile'
require 'helper'
require 'user'
require 'photo'

# Just for having a better written matcher, but not perfect though.
class String; alias :started_with? :start_with?; end

describe "Helper" do
  before(:each) do
    @helper = Helper.new
  end

  it "should respond to all image sizes" do
    %w{small medium large huge}.each do |size|
      @helper.should respond_to(:"display_#{size}_photo")
    end   
  end
  
  
  describe "display_photo" do
    it "should return the wrench if there is no profile" do
      @helper.display_photo(nil, "100x100", {}, {}, true).should == "img:wrench.png"
    end
        
    describe "With a profile, user and photo requesting a link" do
      before(:each) do
        @profile = UserProfile.new
        @profile.name = "Clayton"
        @user    = User.new
        @profile.user = @user
        @photo   = Photo.new
        @user.photo = @photo
        @profile.stub!(:has_valid_photo?).and_return(true)
      end
      it "should return a link" do
        @helper.display_photo(@profile, "100x100", {}, {}, true).should == "link:img:userphoto100x100.jpg"
      end
    end
    
    describe "With a profile, user and photo not requesting a link" do
      before(:each) do
        @profile = UserProfile.new
        @profile.name = "Clayton"
        @user    = User.new
        @profile.user = @user
        @photo   = Photo.new
        @user.photo = @photo
        @profile.stub!(:has_valid_photo?).and_return(true)
      end
      it "should just an image" do
        @helper.display_photo(@profile, "100x100", {}, {}, false).should == "img:userphoto100x100.jpg"
      end
    end
    
    describe "Without a user, but requesting a link" do
      before(:each) do
        @profile = UserProfile.new
        @profile.name = "Clayton"
      end
      it "return a default" do
        @helper.display_photo(@profile, "100x100", {}, {}, true).should == "link:img:user100x100.jpg"
      end
    end
    
    describe "When the user doesn't have a photo" do
      before(:each) do
        @profile = UserProfile.new
        @profile.name = "Clayton"
        @user    = User.new
        @profile.user = @user
        @profile.stub!(:has_valid_photo?).and_return(false)
      end
      describe "With a rep user" do
        before(:each) do
          @user.stub!(:rep?).and_return(true)
        end
        it "return a default link" do
          @helper.display_photo(@profile, "100x100", {}, {}, true).should == "link:img:user190x119.jpg"
        end
        
      end
      
      describe "With a regular user" do
        before(:each) do
          @user.stub!(:rep?).and_return(false)
        end
        it "return a default link" do
          @helper.display_photo(@profile, "100x100", {}, {}, true).should == "link:img:user100x100.jpg"
        end
      end
    end
    
    describe "When the user doesn't have a photo and we don't want to display the default" do
      before(:each) do
        @profile = UserProfile.new
        @profile.name = "Clayton"
        @user    = User.new
        @profile.user = @user
        @profile.stub!(:has_valid_photo?).and_return(false)
      end
      describe "With a rep user" do
        before(:each) do
          @user.stub!(:rep?).and_return(true)
        end
        it "don't return a default link" do
          @helper.display_photo(@profile, "100x100", {}, {:show_default => false}, true).should == "NO DEFAULT"
        end
        
      end
      
      describe "With a regular user" do
        before(:each) do
          @user.stub!(:rep?).and_return(false)
        end
        it "don't return a default link" do
          @helper.display_photo(@profile, "100x100", {}, {:show_default => false}, true).should == "NO DEFAULT"
        end
      end
    end
  end

  describe "link_to" do

    it "should return the parameter prefixed by link:" do
      @helper.link_to("some_path").should be_started_with("link:")
    end
  end

  describe "image_tag" do

    it "should return the first parameter prefixed by img:" do
      @helper.image_tag("a_file.jpg").should be_started_with("img:")
    end
  end

  describe "cond_link_to" do

    it "should not call link_to if the condition is false" do
      @helper.should_not_receive(:link_to)
      @helper.cond_link_to(false,"some text")
    end

    it "should call link_to if the condition is true" do
      arg = "some text"
      proc = Proc.new{}
      @helper.should_receive(:link_to).with(arg, &proc)
      @helper.cond_link_to(true,arg,&proc)
    end
  end
end
