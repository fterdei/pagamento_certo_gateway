class PagamentoCertoBuilder < ActiveRecord::Base
  has_no_table

  def lw_pagto_certo(url = nil)
    gateway = Gateway.find_by_name("Pagamento Certo")
    gateway_option = gateway.gateway_options.first
    LwPagtoCerto.new(:chave_vendedor => gateway_option.gateway_option_values.first.value, :url_retorno => url)
  end

  def build(order, url)
    @lw = lw_pagto_certo(url)
    
    fill_comprador order
    fill_pagamento
    fill_pedido order
    @lw
  end
 
 private 
  def fill_comprador(order)
    @lw.comprador = {
      :Nome        => order.user.login,
      :Email       => "fabiane.erdei@locaweb.com.br",
      :Cpf         => "88823923423",
      :Rg          => "123456780",
      :Ddd         => "11",
      :Telefone    => "35440444",
      :TipoPessoa  => "Fisica",
      :RazaoSocial => "Empresa da Fabiane",
      :Cnpj        => "0010090020000199"
    }
  end
  
  def fill_pagamento
    @lw.pagamento = {
      :Modulo => "Boleto"
      # :Tipo => "Visa",
    }
  end
  
  def fill_pedido(order)
    @lw.pedido = {
      :Numero => order.number,
      :ValorSubTotal  => (order.total * 100).to_i,
      :ValorFrete     => "000",
      :ValorAcrescimo => "000",
      :ValorDesconto  => "000",
      :ValorTotal     => (order.total * 100).to_i,
      :Itens => {
          :Item => {
             :CodProduto    => order.line_items.first.product.id,
             :DescProduto   => order.line_items.first.product.name,
             :Quantidade    => order.line_items.first.quantity,
             :ValorUnitario => (order.line_items.first.price.to_f * 100).to_i,
             :ValorTotal    => (order.line_items.first.quantity * order.line_items.first.price.to_f * 100).to_i,
          },
      },
      :Cobranca => {
        :Endereco => order.bill_address.address1,
        :Numero   => "123",
        :Bairro   => "Foo",
        :Cidade   => order.bill_address.city,
        :Cep      => order.bill_address.zipcode.to_s,
        :Estado   => 'SP',
      },
      :Entrega => {
        :Endereco => order.shipment.address.address1,
        :Numero   => "123",
        :Bairro   => "Foo",
        :Cidade   => order.shipment.address.city,
        :Cep      => order.shipment.address.zipcode.to_s,
        :Estado   => 'SP',
      },
    }
  end
end
