require 'nokogiri'

require 'caracal/core/models/list_style_model'
require 'caracal/core/models/list_model'
require 'caracal/renderers/xml_renderer'


module Caracal
  module Renderers
    class NumberingRenderer < XmlRenderer

      #-------------------------------------------------------------
      # Public Methods
      #-------------------------------------------------------------

      # This method produces the xml required for the `word/numbering.xml`
      # sub-document.
      #
      def to_xml
        builder = ::Nokogiri::XML::Builder.with(declaration_xml) do |xml|
          xml['w'].numbering root_options do
            
            # add abstract numbering definitions
            document.list_styles.each_with_index do |model, i|
              next if model.style_level != 0

              abstract_numbering_definition_id = i + 1
              xml['w'].abstractNum({ 'w:abstractNumId' => abstract_numbering_definition_id }) do
                xml['w'].name( { 'w:val' => model.style_name }) if model.style_name
                xml['w'].multiLevelType({ 'w:val' => model.formatted_level_type })
                
                level = model.style_level
                while s = document.find_list_style(model.style_type, model.style_name, level)
                  xml['w'].lvl({ 'w:ilvl' => s.style_level }) do
                    xml['w'].start({ 'w:val' => s.style_start })
                    xml['w'].numFmt({ 'w:val' => s.style_format })
                    xml['w'].pStyle({ 'w:val' => s.style_paragraph_style }) unless s.style_paragraph_style.nil?
                    xml['w'].lvlRestart({ 'w:val' => s.style_restart }) unless s.style_restart.nil?
                    xml['w'].lvlText({ 'w:val' => s.style_value })
                    xml['w'].lvlJc({ 'w:val' => s.style_align })
                    xml['w'].pPr do
                      xml['w'].ind(indentation_options(s)) unless indentation_options(s).nil?
                    end
                    xml['w'].rPr do
                      xml['w'].u({ 'w:val' => 'none' })
                    end
                  end
                  level += 1
                end
              end
            end

            # add a numbering definition for each abstract numbering definition
            document.list_styles.each_with_index do |model, i|
              next if model.style_level != 0

              # numbering definition that doesn't overrides its abstract numbering definition
              abstract_numbering_definition_id = numbering_definition_id = i + 1
              xml['w'].num({ 'w:numId' => numbering_definition_id }) do
                xml['w'].abstractNumId({ 'w:val' => abstract_numbering_definition_id })
              end
            end

            # add a numbering definition for each override used in the document
            document.abstract_numbering_definition_overrides.each do |abstract_numbering_definition_override|
              list_style_name, list_level, abstract_numbering_definition_id, numbering_definition_id = abstract_numbering_definition_override

              # numbering definition that overrides its abstract numbering definition to restart list_level from 1
              xml['w'].num({ 'w:numId' => numbering_definition_id }) do
                xml['w'].abstractNumId({ 'w:val' => abstract_numbering_definition_id })
                xml['w'].lvlOverride({ 'w:ilvl' => list_level }) do
                  xml['w'].startOverride({ 'w:val' => 1 })
                end
              end
            end
          end
        end

        builder.to_xml(save_options)
      end



      #-------------------------------------------------------------
      # Private Methods
      #-------------------------------------------------------------
      private

      def indentation_options(style)
        left    = style.style_left
        first   = style.style_indent
        hanging = style.style_hanging
        options = nil
        if [left, first, hanging].compact.size > 0
          options                  = {}
          options['w:left']        = left    unless left.nil?
          options['w:firstLine']   = first   unless first.nil?
          options['w:hanging']     = hanging unless hanging.nil?
        end
        options
      end

      def root_options
        {
          'xmlns:mc'  => 'http://schemas.openxmlformats.org/markup-compatibility/2006',
          'xmlns:o'   => 'urn:schemas-microsoft-com:office:office',
          'xmlns:r'   => 'http://schemas.openxmlformats.org/officeDocument/2006/relationships',
          'xmlns:m'   => 'http://schemas.openxmlformats.org/officeDocument/2006/math',
          'xmlns:v'   => 'urn:schemas-microsoft-com:vml',
          'xmlns:wp'  => 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing',
          'xmlns:w10' => 'urn:schemas-microsoft-com:office:word',
          'xmlns:w'   => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
          'xmlns:wne' => 'http://schemas.microsoft.com/office/word/2006/wordml',
          'xmlns:sl'  => 'http://schemas.openxmlformats.org/schemaLibrary/2006/main',
          'xmlns:a'   => 'http://schemas.openxmlformats.org/drawingml/2006/main',
          'xmlns:pic' => 'http://schemas.openxmlformats.org/drawingml/2006/picture',
          'xmlns:c'   => 'http://schemas.openxmlformats.org/drawingml/2006/chart',
          'xmlns:lc'  => 'http://schemas.openxmlformats.org/drawingml/2006/lockedCanvas',
          'xmlns:dgm' => 'http://schemas.openxmlformats.org/drawingml/2006/diagram'
        }
      end

    end
  end
end
