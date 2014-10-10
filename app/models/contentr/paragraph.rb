# coding: utf-8

module Contentr
  class Paragraph < ActiveRecord::Base
    include ActionView::Helpers::SanitizeHelper
    include ParagraphFields
    include ParagraphPublishing
    include ParagraphExtension

    default_scope ->{ order(position: :asc) }

    permitted_attributes :area_name, :position, :data, :unpublished_data,
      :content_block_to_display_id, {headers: []}

    belongs_to :page, class_name: 'Contentr::Page'
    belongs_to :content_block, class_name: 'Contentr::ContentBlock'

    # Validations
    validates :area_name, presence: true, unless: ->{self.content_block.present?}

    after_create do
      update_column(:position, self.id)
    end

    def summary()
      return 'Einige Felder des Paragraphen sind ungültig. Bitte ändern Sie die Werte.' unless self.form_fields.present?
      u ||= unpublished_changes?
      self.form_fields.map do |f|
        a = u ? self.unpublished_data[f[:name].to_s] : self.data[f[:name].to_s]
        next unless a.present?
        a = strip_tags(a)
        n = self.class.human_attribute_name(f[:name])
        "#{n}: #{a}"
      end.compact.join('; ').truncate(140, separator: /\s/)
    end


  end
end
