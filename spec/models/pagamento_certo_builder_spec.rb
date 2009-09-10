require File.dirname(__FILE__) + '/../spec_helper'

describe PagamentoCertoBuilder do
  before(:each) do
    @lw = mock_model LwPagtoCerto
    @order = mock_model Order
    @pagamento_certo_builder = PagamentoCertoBuilder.new
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
    @lw.should_receive(:comprador=).with(hash_including(comprador_fisica))
    @pagamento_certo_builder.build @order
  end
end

