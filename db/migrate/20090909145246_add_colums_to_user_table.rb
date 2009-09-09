class AddColumsToUserTable < ActiveRecord::Migration
  def self.up
    add_column :users, :nome, :string
    add_column :users, :cpf, :string
    add_column :users, :cnpj, :string
    add_column :users, :razao_social, :string
    add_column :users, :tipo, :string
  end

  def self.down
    remove_column :users, :nome
    remove_column :users, :cpf
    remove_column :users, :cnpj
    remove_column :users, :razao_social
    remove_column :users, :tipo
  end
end

