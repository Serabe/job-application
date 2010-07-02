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

  def url_for_file_column(object_name, method, suffix)
    "#{object_name}#{method}#{suffix}.jpg"
  end

  def profile_path(profile)
    profile.to_s
  end
  # End of the extra methods.
  
  def display_small_photo(profile, html = {}, options = {})
    display_photo(profile, image_size(profile, "32x32"), html, options)
  end

  def display_medium_photo(profile, html = {}, options = {})
    display_photo(profile, image_size(profile, "48x48"), html, options)
  end

  def display_large_photo(profile, html = {}, options = {}, link = true)
    display_photo(profile, image_size(profile, "64x64"), html, options, link)
  end

  def display_huge_photo(profile, html = {}, options = {}, link = true)
    display_photo(profile, image_size(profile, "200x200"), html, options, link)
  end

  def display_photo(profile, size, html = {}, options = {}, link = true)
    return image_tag("wrench.png") unless profile  # this should not happen

    show_default_image = !(options[:show_default] == false)
    html.reverse_merge!(:class => 'thumbnail', :size => size, :title => "Link to #{profile.name}")

    if profile && profile.user
      if profile.has_valid_photo?
        @user = profile.user
        img_tag = image_tag(url_for_file_column("user", "photo", size), html)
        if link
          return link_to(img_tag, profile_path(profile) )
        else
          return img_tag
        end
      else
        show_default_image ? default_photo(profile, size, {}, link) : 'NO DEFAULT'
      end
    end

    show_default_image ? default_photo(profile, size, {}, link) : 'NO DEFAULT'
  end

  def default_photo(profile, size, html={}, link = true)
    img_tag = if profile.user && profile.user.rep?
                image_tag("user190x119.jpg", html)
              else
                image_tag("user#{size}.jpg", html)
              end
    if link
      link_to(img_tag, profile_path(profile))
    else
      img_tag
    end
  end
end
