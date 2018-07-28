class CreateLogoLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :logo_links do |t|
    	t.string   :logo_url
      t.timestamps
    end
  end
end
