require File.dirname(__FILE__) + '/../spec_helper'

describe OpenMoneyHelper do
  
  describe "(#get_language_translated_spec)" do
    before(:each) do
      @field_spec = default_mutual_credit_currency(true,true)['fields']
    end
    it "should return the correct spec" do
      get_language_translated_spec(@field_spec['amount'],'description','en').should == 'Amount'
      get_language_translated_spec(@field_spec['amount'],'description','es').should == 'Cantidad'
    end
    it "should return the default language spec for unknown language" do
      get_language_translated_spec(@field_spec['amount'],'description','zz').should == 'Amount'
    end
  end
  
  describe "(#render_field)" do
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormOptionsHelper
    before(:each) do
      @field_spec = default_mutual_credit_currency(true,true)['fields']
    end
    it "should render a float field" do
      render_field(10,'amount',@field_spec['amount']).should == 
        "<input id=\"flow_spec[amount]\" name=\"flow_spec[amount]\" type=\"text\" value=\"10\" />"
    end
    it "should render an enum field" do
      render_field('true','taxable',@field_spec['taxable']).should == 
        "<select id=\"flow_spec[taxable]\" name=\"flow_spec[taxable]\"><option value=\"true\" selected=\"selected\">Yes</option>\n<option value=\"false\">No</option></select>"
      render_field('false','taxable',@field_spec['taxable']).should == 
        "<select id=\"flow_spec[taxable]\" name=\"flow_spec[taxable]\"><option value=\"true\">Yes</option>\n<option value=\"false\" selected=\"selected\">No</option></select>"
    end
#    it "render a unit field" do
#      render_field('USD','USD',@field_spec['amount']).should == "fish"
#    end
  end

  describe "(#get_field_names)" do
    before(:each) do
      @field_spec = default_mutual_credit_currency(true,true)['fields']
    end
    it "should return a hash of translated names for all the fields" do
      get_field_names(@field_spec,'fr').should == {"taxable"=>"Imposable", "amount"=>"Quantité", "description"=>"Description"}
      get_field_names(@field_spec,'en').should == {"taxable"=>"Taxable", "amount"=>"Amount", "description"=>"Description"}
    end
    it "should use a default language" do
      get_field_names(@field_spec).should == {"taxable"=>"Taxable", "amount"=>"Amount", "description"=>"Description"}
    end
    it "should use a default language if specification doesn't have language requested" do
      get_field_names(@field_spec,'zz').should == {"taxable"=>"Taxable", "amount"=>"Amount", "description"=>"Description"}
    end
    it "should take an option exclude array" do
      get_field_names(@field_spec,'en',[:amount,:taxable]).should =={"description"=>"Description"} 
    end
  end

  describe "(#history)" do
    before(:each) do
      @account_omrl = 'zippy.x'
      @currency_omrl = 'bucks.x'
    end
    
    it "should return an array of flows" do
      @flows = history(@account_omrl,@currency_omrl)
      @flows[0].instance_of?(Flow).should == true
      @flows.size.should == 3
    end
  end

  describe "(#render_history for default mutual credit)" do
    before(:each) do
      @account_omrl = 'zippy.x'
      @currency_omrl = 'bucks.x'
      @currency_spec = default_mutual_credit_currency(true,true)    
    end
    it "should return an array with a array of arrays of rendered cell values, and an array of header names" do
      (@flows,@fields) = render_history(history(@account_omrl,@currency_omrl),@account_omrl,@currency_spec)
      @fields.should == [{:_date => 'Date'},{:description => 'Description'},{:taxable => 'Tax?'},{:_with => 'With'},{:_if_with_accepter => '+'},{:_if_with_declarer => '-'}] #,{:_balance => 'Balance'},{:_volume => 'Volume'}
      f = @flows[1]
      @flows.size.should == 3
      f[:_date].instance_of?(Time).should == true
      f[:description].should == 'squids'
      f[:taxable].should == nil
      f[:amount].should == "32.00"
      f[:_with].should == 'test.x'
      f[:_if_with_accepter].should == ''
      f[:_if_with_declarer].should == "32.00"
#      f[:_balance].should == "NA"
 #     f[:_volume].should == "NA"      
    end
  end
  
    describe "(#render_history for default reputation)" do
      before(:each) do
        @account_omrl = 'zippy.x'
        @currency_omrl = 'rep.x'
        @currency_spec = default_reputation_currency('4stars')
      end
      it "should return an array with a array of arrays of rendered cell values, and an array of header names" do
        h = history(@account_omrl,@currency_omrl)
        puts h.inspect
        (@flows,@fields) = render_history(h,@account_omrl,@currency_spec)
        @fields.should == [{:_date => 'Date'},{:declaring_account => 'From'},{:accepting_account => 'To'},{:rating => 'Rating'}] 
        f = @flows[0]
        @flows.size.should == 2
        f[:_date].instance_of?(Time).should == true
        f[:declaring_account].should == 'zippy.x'
        f[:accepting_account].should == 'test.x'
        f[:rating].should == "***"
      end
    end

end