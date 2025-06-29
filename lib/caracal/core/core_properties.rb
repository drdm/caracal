module Caracal
  module Core

    # This module encapsulates all the functionality related to setting the
    # document's core properties.
    #
    module CoreProperties
      def self.included(base)
        base.class_eval do

          #-------------------------------------------------------------
          # Configuration
          #-------------------------------------------------------------

          # accessors
          attr_accessor :title
          attr_accessor :subject
          attr_accessor :author
          attr_accessor :category
          attr_accessor :keywords
          attr_accessor :comments
        end
      end
    end

  end
end
