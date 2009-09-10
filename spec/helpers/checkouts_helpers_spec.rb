require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CheckoutsHelper do
  it "should not include payment" do
    helper.stub!(:current_user)
    helper.checkout_steps.should_not include("payment")
  end
end

