class GatewayPagamentoCertoOption < ActiveRecord::Migration
  def self.up
    chave_vendedor = GatewayOption.create(:name => "Chave Vendedor", :description => "Sua chave de vendedor")
    Gateway.create(:name => "Pagamento Certo", :description => "Pagamento Certo Locaweb", :gateway_options => [chave_vendedor])
  end

  def self.down
    GatewayOption.destroy_all(:name => "Chave Vendedor")
    Gateway.destroy_all(:name => "Pagamento Certo")
  end
end

