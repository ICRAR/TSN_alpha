class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.text :content
      t.boolean :moderated, default: false
      t.datetime :moderated_at
      t.belongs_to :profile
      t.belongs_to :commentable, polymorphic: true
      t.integer :parent_id #for closure_tree
      t.timestamps
    end

    add_index :comments, [:id], :unique => true, :name => "comment_id"
    add_index :comments, [:parent_id], :unique => false, :name => "comment_parent_id"
    add_index :comments, [:profile_id], :unique => false, :name => "comment_profile_id"
    add_index :comments, [:commentable_type,:commentable_id], :unique => false, :name => "comment_commentable"

    create_table :comment_hierarchies, :id => false do |t|
      t.integer  :ancestor_id, :null => false   # ID of the parent/grandparent/great-grandparent/... tag
      t.integer  :descendant_id, :null => false # ID of the target tag
      t.integer  :generations, :null => false   # Number of generations between the ancestor and the descendant. Parent/child = 1, for example.
    end

    # For "all progeny of…" and leaf selects:
    add_index :comment_hierarchies, [:ancestor_id, :descendant_id, :generations],
              :unique => true, :name => "comment_anc_desc_udx"

    # For "all ancestors of…" selects,
    add_index :comment_hierarchies, [:descendant_id],
              :name => "comment_desc_idx"
  end
end
