class PagamentoCertoBuilder < ActiveRecord::Base
  has_no_table

  def lw_pagto_certo(url = nil)
    gateway = Gateway.find_by_name("Pagamento Certo")
    gateway_option = gateway.gateway_options.first
    LwPagtoCerto.new(:chave_vendedor => gateway_option.gateway_option_values.first.value, :url_retorno => url)
  end

  def build(order, url)
    @lw = lw_pagto_certo(url)
    
    fill_comprador order.user
    fill_pagamento
    fill_pedido order
    @lw
  end
   
  def fill_comprador(user)
    @lw.comprador = {
      :Nome        => user.name,
      :Email       => user.email,
      :Cpf         => user.cpf,
      :Rg          => user.rg,
      :Ddd         => user.code_area,
      :Telefone    => user.phone,
      :TipoPessoa  => user.person_type
    }
    if user.person_type == "Juridica"
      @lw.comprador[:RazaoSocial] = user.razao_social
      @lw.comprador[:Cnpj] = user.cnpj
    end
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
    i = 1
    order.line_items.each do |item|
      @lw.pedido[:Itens][:"Item_#{i}"] = {
        :CodProduto    => item.variant.product.id,
        :DescProduto   => item.variant.product.name,
        :Quantidade    => item.variant.quantity,
        :ValorUnitario => (item.variant.price.to_f * 100).to_i,
        :ValorTotal    => (item.variant.quantity * item.variant.price.to_f * 100).to_i,
        }
      i += 1
    end
  end
end
