require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoCertoBuilder do
  before(:each) do
    @lw = mock_model LwPagtoCerto
    @user = mock_model User, :login => "Fabiane"
    @order = mock_model Order, :user => @user
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

  it "should fill order informations" do
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
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"
  end
end
