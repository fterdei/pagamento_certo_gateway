require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoCertoBuilder do
  before(:each) do
    @lw = mock_model LwPagtoCerto
    @user = mock_model User, :login => "Fabiane"
    @product = mock_model Product, :id => 1, :name => "Relogio"
    @address = mock_model Address, :address1 => "Rua X", :city => "SP", :zipcode => "01234567"
    @line_item = mock_model LineItem, :product => @product, :quantity => 1, :price => 121.00
    @shipment = mock_model Shipment, :address => @address
    @order = mock_model Order, :user => @user, :number => 1, :total => 12.0, :line_items => [@line_item],
                               :bill_address => @address, :shipment => @shipment
    @pagamento_certo_builder = PagamentoCertoBuilder.new
    
  end

  it "should give me an instance of lwpagtocerto" do
    @gateway = mock_model Gateway
    @gateway_option = mock_model GatewayOption
    @gateway_option_value = mock_model GatewayOptionValue

    @gateway.stub!(:gateway_options).and_return([@gateway_option])
    @gateway_option.stub!(:gateway_option_values).and_return([@gateway_option_value])
    @gateway_option_value.stub!(:value).and_return("ABCD")

    Gateway.should_receive(:find_by_name).with("Pagamento Certo").and_return(@gateway)
    LwPagtoCerto.should_receive(:new).with(:chave_vendedor => "ABCD", :url_retorno => nil).and_return(@lw)
    @pagamento_certo_builder.lw_pagto_certo.should == @lw
  end

  it "should fill order informations with comprador fisica" do
    comprador_fisica = {
      :Nome => "Fabiane",
      :Email => "fabiane.erdei@locaweb.com.br",
      :Cpf => "88823923423",
      :Rg => "123456780",
      :Ddd => "11",
      :Telefone => "35440444",
      :TipoPessoa => "Fisica"
    }
    @pagamento_certo_builder.should_receive(:lw_pagto_certo).with("http://locaweb.com.br").and_return(@lw)
    @lw.should_receive(:comprador=).with(hash_including(comprador_fisica))
    @lw.stub!(:pagamento=)
    @lw.stub!(:pedido=)
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"
  end
  
  it "should fill order informations with comprador juridica" do
    comprador_juridica = {
      :Nome => "Fabiane",
      :Email => "fabiane.erdei@locaweb.com.br",
      :Cpf => "88823923423",
      :Rg => "123456780",
      :Ddd => "11",
      :Telefone => "35440444",
      :TipoPessoa => "Juridica",
      :RazaoSocial => "Empresa da Fabiane",
      :Cnpj        => "0010090020000199"
      
    }
    @pagamento_certo_builder.should_receive(:lw_pagto_certo).with("http://locaweb.com.br").and_return(@lw)
    @lw.should_receive(:comprador=).with(hash_including(comprador_juridica))
    @lw.stub!(:pagamento=)
    @lw.stub!(:pedido=)
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"
  end
  
end
