# Uncomment this if you reference any of your controllers in activate
# require_dependency 'application'

class PagamentoCertoGatewayExtension < Spree::Extension
  version "0.1"
  description "Pagamento Certo Gateway"
  url "http://www.pagamentocerto.com.br"

  # Please use pagamento_certo_gateway/config/routes.rb instead for extension routes.

  def self.require_gems(config)
   config.gem "akitaonrails-lw-pagto-certo", :lib => 'lw-pagto-certo', :source => 'http://gems.github.com', :version => '>=0.0.5'
   config.gem 'activerecord-tableless', :lib => 'tableless', :version => '>=0.1.0'
  end

  def activate
    User.class_eval do 
        attr_accessible :email, :password, :password_confirmation, :name, :cpf, :rg,  
                        :razao_social, :person_type, :code_area,  :phone
    end
    
    CheckoutsHelper.class_eval do
      alias :checkout_steps_alias :checkout_steps
      def checkout_steps
        checkout_steps = checkout_steps_alias
        checkout_steps.delete "payment"
        checkout_steps
      end
   end

   CheckoutsController.class_eval do
     protect_from_forgery :except => [:close]
     before_filter :load_data, :except => [:close]

     def close
       @order = Order.find_by_number(params[:order])
       flash[:notice] = t('order_processed_successfully')
       order_params = {:checkout_complete => true}
       order_params[:order_token] = @order.token unless @order.user
       session[:order_id] = nil if @order.checkout.completed_at
       redirect_to order_url(@order, order_params)
     end

     update do
       flash nil

       success.wants.html do
         if current_user
           current_user.update_attribute(:bill_address,  @order.bill_address)
           current_user.update_attribute(:ship_address,  @order.ship_address)
         end
         @pagamento_certo_builder = PagamentoCertoBuilder.new
         @lw = @pagamento_certo_builder.build(@order, url_for(:controller => "checkouts", :action => "close", :order => @order))
         consulta = @lw.inicia
         redirect_to "https://www.pagamentocerto.com.br/pagamento/pagamento.aspx?tdi=#{consulta[:id_transacao]} "
       end

       success.wants.js do
         @order.reload
         render :json => { :order_total => number_to_currency(@order.total),
                           :charges => charge_hash,
                           :credits => credit_hash,
                           :available_methods => rate_hash}.to_json,
                :layout => false
       end
     end
   end

  end
end




