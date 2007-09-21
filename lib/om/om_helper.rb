######################################################################################
# Copyright (C) 2007 Eric Harris-Braun (eric -at- harris-braun.com), et al
# This software is distributed according to the MIT License
######################################################################################

module OpenMoneyHelper

  UnitToHTMLMap = {
    'USD' => '$',
    'EUR' => '&euro;',
    'CAD' => '$',
    'AUD' => '$',
    'NZD' => '$',
    'S' => '&pound;',
    'MXP' => 'p',
    'YEN' => '&yen;',
    'CHY' => 'Yuan',
    'T-h' => 'h',
    'T-m' => 'm',
    'T-s' => 's',
    'kwh' => 'kwh',
    'lb' => 'lb',
    'oz' => 'oz',
    'kg' => 'kg',
    'g' => 'g',
    'mi' => 'mi',
    'ft' => 'ft',
    'in' => 'in',
    'km' => 'km',
    'm' => 'm',
    'cm' => 'cm',
    'mm' => 'mm',
    'other' => '&curren;'
  }
    
  UnitToLanguage = {
    'en' => [
  		['USD' , 'US Dollar'],
  		['EUR' , 'Euro'],
  		['CAD' , 'Canadian Dollar'],
  		['AUD' , 'Australian Dollar'],
  		['NZD' , 'New Zeland Dollar'],
  		['S' , 'Sterling Pound'],
  		['MXP' , 'Mexican Peso'],
  		['YEN' , 'Yen'],
  		['CHY' , 'Yuan'],
  		['T-h' , 'Time:hours'],
  		['T-m' , 'Time:minutes'],
  		['T-s' , 'Time:seconds'],
  		['kwh' , 'Kilowatt Hours'],
  		['lb' , 'Pounds'],
  		['oz' , 'Ounces'],
  		['kg' , 'Kilograms'],
  		['g' , 'Grams'],
  		['mi' , 'Miles'],
  		['ft' , 'Feet'],
  		['in' , 'Inches'],
  		['km' , 'Kilometers'],
  		['m' , 'Meters'],
  		['cm' , 'Centimeters'],
  		['mm' , 'Milimeters'],
  		['other' , 'other'],      
    ]
  }
  def default_mutal_credit_currency_fields(taxable=true,unit='USD')
    fields = {
      'amount' => {
        'type' => 'float',
        'description' => {
          'en' => 'Amount',
          'es' => 'Cantidad',
          'fr' => 'Quantité'
        }
      },
    	'description' => {
        'type' => 'text',
        'description' => {
          'en' => 'Description',
          'es' => 'Descripción',
          'fr' => 'Description'
        }
      },
    	'acknowledge_flow' => {
        'type' => 'submit',
        'description' => {
          'en' => 'Acknowledge Flow',
          'es' => 'Reconoce el Flujo',
          'fr' => 'Confirmer la Transaction'
        }
    	},
    	unit => 'unit'
    }
    fields['taxable'] = {
      'type' => 'boolean',
      'description' => {
        'en' => 'Taxable',
        'es' => 'Ingreso Imponible',
        'fr' => 'Imposable',
      },
      'values_enum' => {
        'en' => [['Yes','true'],['No','false']],
        'es' => [['Si','true'],['No','false']],
        'fr' => [['Oui','true'],['Non','false']]
      }
    } if taxable
    fields
  end
  
  def default_mutual_credit_currency(taxable=true,unit='USD')
    currency_spec = {}
    currency_spec['fields'] = default_mutal_credit_currency_fields(taxable,unit)
  	currency_spec['summary_type'] = 'balance(amount)'
  	currency_spec['input_form'] = {
  	  'en' => ":declaring_account acknowledges :accepting_account for :description in the amount of :amount #{taxable ? '(taxable :taxable) ' : ''}:acknowledge_flow",
      'es' => ":declaring_account reconoce :accepting_account por :description en la cantidad de :amount #{taxable ? '(ingreso imponible :taxable) ' : ''} :acknowledge_flow",
  	  'fr' => ":declaring_account remercie :accepting_account pour :description et lui verse la somme de :amount #{taxable ? '(imposable :taxable) ' : ''}:acknowledge_flow"
  	}
  	currency_spec
  end
  def currency_select(html_field_name,selected,account = nil)
    c = Currency.find(:all).collect{|e| e.omrl.chop}
    select_tag(html_field_name,options_for_select(c,selected))
  end

  def contexts_select(html_field_name,selected)
    c = Entity.find(:all, :conditions => "entity_type = 'context' ").collect{|e| e.omrl.chop}
    select_tag(html_field_name,options_for_select(c,selected))
  end

  def unit_of_measure_select(html_field_name,selected = nil)
    select_tag(html_field_name, unit_of_measure_options_for_select)
  end
  
  def unit_of_measure_options_for_select(language = 'en')
    l = UnitToLanguage[language]
    l ||= UnitToLanguage['en']
    l.collect {|o| unit = o[0];%Q|<option value="#{unit}">#{o[1]} (#{UnitToHTMLMap[unit]})</option>|}.join("\n")
  end


  ################################################################################
  # Helper to convert the currency spec into an html form
  # options:
  #  +langauge
  #  +pre_specified_fields: hash used to to display values (like a declaring_account)
  #   instead of asking the user for them.
  def input_form(currency_spec,options = {})
    language = options[:language] ||= 'en'
    pre_specified_fields = options[:pre_specified_fields]
    
    field_spec = currency_spec["fields"]
    form = currency_spec["input_form"][language]
    form ||= currency_spec["input_form"]['en']
    form.gsub(/:([a-zA-Z0-9_-]+)/) do |m| 
      if pre_specified_fields && pre_specified_fields.has_key?($1)
        pre_specified_fields[$1]
      else
        render_field($1,field_spec,language)
      end
    end
  end

  ################################################################################
  # get_field_spec interprets the field spec according to type.  It allows the field spec
  # to be:
  # 1- a string which is the type. In which case the type is set and the description
  #    becomes a capitalized version of the field name
  # 2- an Array, in which the array is exepected to be the values enumeration for for
  #    the field (and the description is again pulled from the field name)
  # 3- or a has in which case, the only thing that's done is that the description is
  #    generated from the field name if it's missing.
  def get_field_spec(field_name,field_spec)
    fspec = field_spec[field_name]
    fspec ||= field_name
    case
    when fspec.is_a?(String)
      fspec = {'type' => fspec}
    when fspec.is_a?(Array)
      fspec = {'values_enum' => fspec}
    end
    fspec['description'] ||= field_name.gsub(/_/,' ').capitalize
    fspec
  end

  ################################################################################
  # renders and individual field in the input form specification according to choosen language
  def render_field(field_name,field_spec,language = 'en')
    fspec = get_field_spec(field_name,field_spec)

    html_field_name = "flow_spec[#{field_name}]"

    field_description = fspec['description']
    field_description = field_description[language] if field_description.is_a?(Hash)

    field_type = fspec['type']
    case 
    when fspec['values_enum']
      enum = fspec['values_enum']
      if enum.is_a?(Hash)
        enum = enum[enum.has_key?(language) ? language : 'en' ]
      end
      select_tag(html_field_name,options_for_select(enum,@params[field_name]))
    when field_type == "boolean"
      select_tag(html_field_name,options_for_select([[l('Yes'), "true"], [l('No'), "false"]],@params[field_name]))
    when field_type == "submit"
      submit_tag(field_description)
    when field_type == "text"
      text_field_tag(html_field_name,@params[field_name])
    when field_type == "float"
      text_field_tag(html_field_name,@params[field_name])
    when field_type == "unit"
      UnitToHTMLMap[field_name]
    else
      text_field_tag(field_name,@params[field_name])
    end
  end

  ################################################################################
  # Helper that returns the flows summary of a currency
  def summary(account,currency_omrl,options = {})
    language = options[:language] ||= 'en'
    currency_spec = account.currency_specification(currency_omrl)
    if currency_spec.has_key?('summaries')
      s = currency_spec['summaries'][account.omrl]

      form = currency_spec["summary_form"][language]
      form ||= currency_spec["summary_form"]['en']
      form.gsub(/:([a-zA-Z0-9_-]+)/) do |m| 
        s[$1]
      end
    else
      nil
    end
  end

  ################################################################################
  # Helper that returns the flows of a currency as specified by the options
  # as well as the header field names in the correct language.
  def history(account, currency_omrl,options = {})
    config = {
      :language  => 'en',
      :sort_order => nil,
      :count => 20,
      :page => 0,
    }.update(options)
    sort_order = config[:sort_order]
        
    account_omrl = account.omrl
    flows = Flow.find(:all, :params => { :with => account_omrl, :in_currency => currency_omrl })
    fields = account.currency_specification(currency_omrl)['fields']
    f = {}

    fields.keys.each do |name|
      fspec = get_field_spec(name,fields)
      type = fspec['type']
      if type != 'submit'  && type != 'unit'
        field_description = fspec['description']
        field_description = field_description[config[:language]] if field_description.is_a?(Hash)
        f[name] = field_description
      end
    end
    if sort_order =~ /^-(.*)/
      reverse = true
      sort_order = $1
    end
    if sort_order == nil or sort_order == ''
      flows = flows.sort_by {|a| a.created_at}.reverse
    else
      flows = flows.sort_by {|a| a.specification_attribute(sort_order)}
    end
    flows = flows.reverse if reverse
    [flows,f]
  end
end