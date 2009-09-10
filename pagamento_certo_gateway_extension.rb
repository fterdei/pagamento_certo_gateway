# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PagamentoCertoGatewayExtension < Spree::Extension
  version "0.1"
  description "Pagamento Certo Gateway"
  url "http://www.pagamentocerto.com.br"

  # Please use pagamento_certo_gateway/config/routes.rb instead for extension routes.

 def self.require_gems(config)
   config.gem "akitaonrails-lw-pagto-certo", :lib => 'lw-pagto-certo', :source => 'http://gems.github.com', :version => '>=0.0.5'
 end

  def activate
    CheckoutsHelper.class_eval do
      alias :checkout_steps_alias :checkout_steps
      def checkout_steps
        checkout_steps = checkout_steps_alias
        checkout_steps.delete "payment"
        checkout_steps
      end
   end

  end
end

