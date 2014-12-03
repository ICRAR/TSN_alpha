# This migration comes from acts_as_taggable_on_engine (originally 2)
class AddMissingUniqueIndices < ActiveRecord::Migration
  def self.up
    #remove duplicate tags
    #find all duplicates as seen by the database
    ActsAsTaggableOn::Tag.group(:name).select{'*'}.select{count('*').as 'group_count'}.all.select{|a| a.group_count > 1}.each do |tag|
      #for each group of duplicates load all tags
      dup_tags = ActsAsTaggableOn::Tag.where{name == tag.name}
      dup_tags.shift #save the first tag
      #for all others
      dup_tags.each do |dup_tag|
        dup_tag.destroy
      end
    end
    add_index :tags, :name, unique: true

    remove_index :taggings, :tag_id
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings,
              [:tag_id, :taggable_id, :taggable_type, :context, :tagger_id, :tagger_type],
              unique: true, name: 'taggings_idx'
  end

  def self.down
    remove_index :tags, :name

    remove_index :taggings, name: 'taggings_idx'
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end
end
