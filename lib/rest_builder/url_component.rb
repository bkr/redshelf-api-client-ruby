module RestBuilder
  
  class UrlComponent
    attr_reader :folder, :id

    def initialize(folder, *args)
      @folder = folder
      @id = args.first
    end

    def to_s
      [@folder, @id].compact.join("/")
    end
    
    def class_name
      @folder.to_s.singularize.camelize
    end
  end
  
end