require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoCertoBuilder do
  before(:each) do
    setup_mocks
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
      :Cpf => "0123456789",
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
    @user.stub!(:person_type).and_return("Juridica")
    comprador_juridica = {
      :Nome => "Fabiane",
      :Email => "fabiane.erdei@locaweb.com.br",
      :Cpf => "0123456789",
      :Rg => "123456780",
      :Ddd => "11",
      :Telefone => "35440444",
      :TipoPessoa => "Juridica",
    }
    
    @pagamento_certo_builder.should_receive(:lw_pagto_certo).with("http://locaweb.com.br").and_return(@lw)
    @lw.should_receive(:comprador=).with(hash_including(comprador_juridica))
    @lw.stub!(:pagamento=)
    @lw.stub!(:pedido=)
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"
  end
  
  it "should fill order informations with pagamento" do
    pagamento = { :Modulo => "Boleto"}
    @pagamento_certo_builder.should_receive(:lw_pagto_certo).with("http://locaweb.com.br").and_return(@lw)    
    @lw.stub!(:comprador=)
    @lw.stub!(:pedido=)
    @lw.should_receive(:pagamento=).with(pagamento)
    
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"  
  end

  it "should fill order informations with pedido" do
    @pagamento_certo_builder.should_receive(:lw_pagto_certo).with("http://locaweb.com.br").and_return(@lw)        
    @lw.stub!(:comprador=)
    @lw.stub!(:pagamento=)
    @lw.should_receive(:pedido=).with(setup_pedido)
    
    
    @pagamento_certo_builder.build @order, "http://locaweb.com.br"  
  end
  
  def setup_pedido
    pedido = {
      :Numero => 1,
      :ValorSubTotal  => 12100,
      :ValorFrete     => "200",
      :ValorAcrescimo => "000",
      :ValorDesconto  => "000",
      :ValorTotal     => 12400,
      :Itens => Hash.new,
      :Cobranca => {
        :Endereco => "Rua X",
        :Numero   => "123",
        :Bairro   => "Itaim",
        :Cidade   => "SP",
        :Cep      => "01234567",
        :Estado   => "SP",
      },
      :Entrega => {
        :Endereco => "Rua X",
        :Numero   => "123",
        :Bairro   => "Itaim",
        :Cidade   => "SP",
        :Cep      => "01234567",
        :Estado   => "SP",
      },
    }    
  end
  
  def setup_mocks
    @lw = mock_model LwPagtoCerto, :comprador => Hash.new, :pagamento => Hash.new, :pedido => {:Itens => Hash.new}
    @product = mock_model Product, :id => 1, :name => "Relogio"
    @variant = mock_model Variant, :product => @product, :quantity => 1, :price => 121.00
    @user = mock_model User, :login => "Fabiane",
                             :name => "Fabiane", 
                             :email => "fabiane.erdei@locaweb.com.br",
                             :cpf => "0123456789", 
                             :rg => "123456780",
                             :code_area => "11",
                             :phone => "35440444",
                             :person_type => "Fisica",
                             :razao_social => "Empresa da Fabiane",
                             :cnpj => "0123456789"
    @state = mock_model State, :abbr => "SP"
    @address = mock_model Address, :address1 => "Rua X", 
                                   :city => "SP", 
                                   :zipcode => "01234567", 
                                   :number => "123", 
                                   :neighborhood => "Itaim", 
                                   :state => @state
    @line_item = mock_model LineItem, :product => @product, 
                                      :quantity => 1, 
                                      :price => 121.00, 
                                      :variant => @variant
    @charge = mock_model Charge, :amount => 2.0
    @shipment = mock_model Shipment, :address => @address, :charge => @charge
    @order = mock_model Order, :user => @user, 
                               :number => 1, 
                               :item_total => 121.00, 
                               :line_items => [@line_item],
                               :bill_address => @address, 
                               :shipment => @shipment,
                               :total => 124.00,
                               :adjustment_total => 1.0
    @pagamento_certo_builder = PagamentoCertoBuilder.new
  end
  
end
