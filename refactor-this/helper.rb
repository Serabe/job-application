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

  def self.add_size_for_photo(name, size)
    define_method "display_#{name}_photo" do |*args|
      raise ArgumentError, 'wrong number of arguments (0 for 1)' if args.empty?
      raise ArgumentError, 'wrong number of arguments (#{args.size} for 3)' if args.size > 3
      args.push *[{}]*(3-args.size)
      display_photo(arg[0], image_size(args[0], size), args[1], args[2])
    end
  end
  # End of the extra methods.

  add_size_for_photo :small, "32x32"
  add_size_for_photo :medium, "48x48"
  add_size_for_photo :large, "64x64"
  add_size_for_photo :huge, "200x200"
  
  def display_photo(profile, size, html = {}, options = {}, link = true)
    return image_tag("wrench.png") unless profile  # this should not happen

    html.reverse_merge!(:class => 'thumbnail', :size => size, :title => "Link to #{profile.name}")

    if profile.has_valid_photo?
      @user = profile.user # This is useless, unless it is been used
                           # in a view.
      cond_link_to(link, image_tag(url_for_file_column("user", "photo", size), html), profile_path(profile))
    else
      !(options[:show_default] == false) ? default_photo(profile, size, {}, link) : 'NO DEFAULT'
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
