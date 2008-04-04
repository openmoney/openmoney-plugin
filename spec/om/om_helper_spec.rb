require File.dirname(__FILE__) + '/../spec_helper'

describe OpenMoneyHelper do
  describe "(#history)" do

    before(:each) do
      @account_omrl = 'zippy.x'
      @currency_omrl = 'bucks.x'
    end
    
    it "should return an array of flows" do
      @flows = history(@account_omrl,@currency_omrl)
      @flows[0].instance_of?(Flow).should == true
      @flows.size.should == 2
    end
    
  end
  describe "(#render_history)" do

    before(:each) do
      @account_omrl = 'zippy.x'
      @currency_omrl = 'bucks.x'
      @currency_spec = default_mutual_credit_currency(true,true)    
    end
    it "should return an array with a array of arrays of rendered cell values, and an array of header names" do
      (@flows,@fields) = render_history(history(@account_omrl,@currency_omrl),@account_omrl,@currency_spec)
      @fields.should == [{:_date => 'Date'},{:description => 'Description'},{:taxable => 'Tax?'},{:_with => 'With'},{:_if_with_accepter => '+'},{:_if_with_declarer => '-'},{:_balance => 'Balance'},{:_volume => 'Volume'}]
      f = @flows[1]
      @flows.size.should == 2
      puts @flows.inspect
      f[:_date].instance_of?(Time).should == true
      f[:description].should == 'squids'
      f[:taxable].should == nil
      f[:_with].should == 'test.x'
      f[:_if_with_accepter].should == ''
      f[:_if_with_declarer].should == "32.00"
      f[:_balance].should == "-32.00"
      f[:_volume].should == "32.00"      
    end
  end

end