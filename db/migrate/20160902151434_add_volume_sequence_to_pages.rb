class AddVolumeSequenceToPages < ActiveRecord::Migration
  def change
    change_table :pages do |t|
      t.rename :sequence, :issue_sequence
      t.integer  :volume_sequence  #original sequence in bound volume

    end
  end
end
