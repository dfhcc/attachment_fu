# specific attachement_fu processor for yousty that call image magick directly
# on the command line.
module YoustyProcessor

  def self.included(base)
    base.send :extend, ClassMethods
    base.alias_method_chain :process_attachment, :processing
  end

  module ClassMethods
    # Yields a block containing an Image Science image for the given binar
    def with_image(file, &block)
      logger.info("Calling block w/ file #{file}")
      block.call file
    end
  end

  protected

    def process_attachment_with_processing
      return unless process_attachment_without_processing
      with_image do |img|
        resize_image_or_thumbnail! img
        callback_with_args :after_resize, img
      end if image?
    end


    def resize_image(img, size_options)
      # use minimagick for the actual resize
      mini = MiniMagick::Image.from_file(img)



      if self.respond_to?(:crop_x) and self.crop_x
        crop_ratio = mini[:width].to_f / Avatar::CROP_AREA_WIDTH.to_f
        crop_x_scaled = (self.crop_x.to_i * crop_ratio).to_i
        crop_y_scaled = (self.crop_y.to_i * crop_ratio).to_i
        crop_width_scaled = (self.crop_width.to_i * crop_ratio).to_i
        crop_height_scaled = (self.crop_height.to_i * crop_ratio).to_i
#        logger.info "WidthxHeight: #{mini[:width]}x#{mini[:height]}"
#        logger.info "Crop Ratio: #{crop_ratio}"
#        logger.info "Crop: #{crop_width_scaled}x#{crop_height_scaled}+#{crop_x_scaled}+#{crop_y_scaled}"
        mini.crop("#{crop_width_scaled}x#{crop_height_scaled}+#{crop_x_scaled}+#{crop_y_scaled}")
#        logger.info "Resize: #{size_options[0]}x#{size_options[1]}"
        mini.resize("#{size_options[0]}x#{size_options[1]}")
      else
        if size_options.is_a?(Array)
          resize = image_resize_value(mini[:width], mini[:height], size_options[0], size_options[1])
        else
          resize = size_options
        end

        mini.resize(resize)

        # crop image
        if extract_size_option(size_options, :crop)
          crop = image_crop_value(mini[:width], mini[:height], size_options[0], size_options[1])

          mini.crop(crop)
          #mini.set('page', "#{size_options[0]}x#{size_options[1]}+0+0")
        end
      end

      # write image
      mini.write(add_temp_path)

      # curve corners
      if self.attachment_options[:curve_radius] || extract_size_option(size_options, :curve_radius)
        # convert to png format to assure transparency support
        self.reset_filename
        self.content_type = 'image/png'
        cmd = "convert #{temp_path} #{add_temp_path}"
        execute cmd
        # create the rounded corners
        w, h = mini[:width], mini[:height]
        curve = self.attachment_options[:curve_radius] || extract_size_option(size_options, :curve_radius) || 10
        cmd = %{convert -size "#{[w, h].join('x')}" xc:none -fill white -draw "roundRectangle 0,0 #{w-1},#{h-1} #{curve},#{curve}" #{temp_path} -compose SrcIn -composite #{add_temp_path}}
        execute cmd
      else
        # convert picture to jpeg in all cases other than rounded corner pictures
        self.change_filename_to_jpg
        self.content_type = 'image/jpeg'
        cmd = "convert #{temp_path} #{add_temp_path}"
        execute cmd
      end
    end

    def extract_size_option(size_options, key)
      if size_options.is_a?(Array) && size_options[2]
        size_options[2][key]
      else
        nil
      end
    end

    # adds a new temp file to the temp file array managed by attachement_fu. To
    # access the _path_ of the tempfile, just call self.temp_path or use the
    # return value of this method.
    def add_temp_path
      self.temp_path=MiniMagick::ImageTempFile.new(self.filename.sub(/^.*\//,''))
      self.temp_path
    end

    # this was to develop a calculation method to use minimagick resize
    # and crop. see http://blog.craigambrose.com/past/2007/12/3/image_cropping_with_mini_magick/
    def image_crop_value(width, height, target_width, target_height)
      shave_x = ((width - target_width) / 2.0).round
      shave_y = ((height - target_height) / 2.0).round
      "#{target_width}x#{target_height}+#{shave_x}+#{shave_y}"
    end

    def image_resize_value(width, height, target_width, target_height)
      factor = [width / target_width.to_f, height / target_height.to_f].min
      w, h = width / factor, height / factor
      "#{w.round}x#{h.round}"
    end

    def execute(cmd)
      `#{cmd}`
      if $? != 0
        raise MiniMagick::MiniMagickError, "ImageMagick command failed: Error Given #{$?}. Cmd was\n#{cmd}"
      end
    end

    def change_filename_to_jpg
      return if self.filename.blank?
      self.filename.sub!(/\.\w{2,4}$/, '.jpg')
    end

    def reset_filename
      return if self.filename.blank?
      self.filename.sub!(/\.\w{2,4}$/, '.png')
    end

end
