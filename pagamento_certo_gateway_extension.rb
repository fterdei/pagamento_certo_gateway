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

    # Add your extension tab to the admin.
    # Requires that you have defined an admin controller:
    # app/controllers/admin/yourextension_controller
    # and that you mapped your admin in config/routes

    #Admin::BaseController.class_eval do
    #  before_filter :add_yourextension_tab
    #
    #  def add_yourextension_tab
    #    # add_extension_admin_tab takes an array containing the same arguments expected
    #    # by the tab helper method:
    #    #   [ :extension_name, { :label => "Your Extension", :route => "/some/non/standard/route" } ]
    #    add_extension_admin_tab [ :yourextension ]
    #  end
    #end

    # make your helper avaliable in all views
    # Spree::BaseController.class_eval do
    #   helper YourHelper
    # end
  end
end

