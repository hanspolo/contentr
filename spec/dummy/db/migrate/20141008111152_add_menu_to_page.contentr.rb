# This migration comes from contentr (originally 20142)
class AddMenuToPage < ActiveRecord::Migration
  def change
    change_table :contentr_pages do |t|
      t.references :menu
    end
  end
end
