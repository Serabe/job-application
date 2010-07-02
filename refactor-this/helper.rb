require 'active_support/core_ext/hash/reverse_merge'

class Helper
  def self.foo
    "foo"
  end

  def image_size(profile, non_rep_size)
    if profile.user.rep?
      '190x114'
    else
      non_rep_size
    end
  end

  # Some methods I need to fake Rails behavior.
  def image_tag(file, options={})
    "img:#{file}"
  end

  def link_to(*args, &block)
    "link:#{args.first}"
  end

  def cond_link_to(cond, *args, &block)
    if cond
      link_to(*args, &block)
    else
      args.first
    end
  end

  def url_for_file_column(object_name, method, suffix)
    "#{object_name}#{method}#{suffix}.jpg"
  end

  def profile_path(profile)
    profile
  end

  class << self
    def method_missing(name, *args)
      super unless name.to_s =~ /^\w+_size$/ # Check name
      size_name = name.to_s[0..-6]

      # Check args
      raise ArgumentError, 'wrong number of arguments (#{args.size} for 1)' unless args.size == 1
      raise ArgumentError, 'argument must be a String matching \d+x\d+' unless args[0] =~ /^\d+x\d+$/

      # Create method
      define_method "display_#{size_name}_photo" do |*brgs|
        raise ArgumentError, 'wrong number of arguments (0 for 1)' if brgs.empty?
        raise ArgumentError, 'wrong number of arguments (#{brgs.size} for 3)' if brgs.size > 3
        brgs.push *[{}]*(3-brgs.size)
        display_photo(brgs[0], image_size(brgs[0], args[0]), brgs[1], brgs[2])
      end
    end
  end
  # End of the extra methods.

  small_size "32x32"
  medium_size "48x48"
  large_size "64x64"
  huge_size "200x200"
  
  def display_photo(profile, size, html = {}, options = {}, link = true)
    return image_tag("wrench.png") unless profile  # this should not happen

    html.reverse_merge!(:class => 'thumbnail', :size => size, :title => "Link to #{profile.name}")

    if profile.has_valid_photo?
      @user = profile.user # This is useless, unless it is been used
                           # in a view.
      cond_link_to(link, image_tag(url_for_file_column("user", "photo", size), html), profile_path(profile))
    else
      !(options[:show_default] == false) ? default_photo(profile, size, html, link) : ''
    end
  end

  def default_photo(profile, size, html={}, link = true)
    img_tag = if profile.user && profile.user.rep?
                image_tag("user190x119.jpg", html)
              else
                image_tag("user#{size}.jpg", html)
              end
    cond_link_to(link, img_tag, profile_path(profile))
  end
end
