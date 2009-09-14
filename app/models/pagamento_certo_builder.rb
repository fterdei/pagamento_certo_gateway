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
 
 private 
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
    }
  end
  
  def fill_pedido(order)
    @lw.pedido = {
      :Numero => order.number,
      :ValorSubTotal  => (order.total * 100).to_i,
      :ValorFrete     => order.shipment.cost,
      :ValorAcrescimo => (order.adjustment_total > 0 ? order.adjustment_total : 0),
      :ValorDesconto  => (order.adjustment_total < 0 ? - order.adjustment_total : 0),
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
        :Numero   => order.bill_address.number,
        :Bairro   => order.bill_address.neighborhood,
        :Cidade   => order.bill_address.city,
        :Cep      => order.bill_address.zipcode.to_s,
        :Estado   => order.bill_address.state.abbr,
      },
      :Entrega => {
        :Endereco => order.shipment.address.address1,
        :Numero   => order.shipment.address.number,
        :Bairro   => order.shipment.address.neighborhood,
        :Cidade   => order.shipment.address.city,
        :Cep      => order.shipment.address.zipcode.to_s,
        :Estado   => order.shipment.address.state.abbr,
      },
    }
    # i = 1
    # order.line_items.each do |item|
    #   @lw.pedido[:Itens][:"Item_#{i}"] = {:CodProduto => item.variant.product.id}
    #   i += 1
    # end
  end
end
