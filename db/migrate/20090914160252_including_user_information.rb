class IncludingUserInformation < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :rg, :string
    add_column :users, :cpf, :string
    add_column :users, :code_area, :string
    add_column :users, :phone, :string
    add_column :users, :person_type, :string
    add_column :users, :razao_social, :string
    add_column :users, :cnpj, :string
  end

  def self.down
    remove_column :users, :cnpj
    remove_column :users, :razao_social
    remove_column :users, :person_type
    remove_column :users, :phone
    remove_column :users, :code_area
    remove_column :users, :cpf
    remove_column :users, :rg
    remove_column :users, :name
  end
end