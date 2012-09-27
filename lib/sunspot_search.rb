$:.unshift(File.join(File.dirname(__FILE__), "sunspot_search"))

%w{ searchable attribute_handler version proc}.each{ |filename|
  require filename
}

module SunspotSearch
  def self.included(base)
    base.class_eval do
      include Searchable
    end
  end

::Proc.send(:include, Proc)
end


