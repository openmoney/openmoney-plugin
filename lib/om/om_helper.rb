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
  def default_mutual_credit_currency_fields(description=true,taxable=false,unit='USD')
    fields = {
      'amount' => {
        'type' => 'float',
        'description' => {
          'en' => 'Amount',
          'es' => 'Cantidad',
          'fr' => 'Quantité'
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
    fields['description'] = {
      'type' => 'text',
      'description' => {
        'en' => 'Description',
        'es' => 'Descripción',
        'fr' => 'Description'
      }
    } if description
  	
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
  
  def default_mutual_credit_currency(description=true,taxable=false,unit='USD')
    currency_spec = {}
    currency_spec['fields'] = default_mutual_credit_currency_fields(description,taxable,unit)
  	currency_spec['summary_type'] = 'balance(amount)'
  	currency_spec['input_form'] = {
  	  'en' => ":declaring_account acknowledges :accepting_account#{description ? ' for :description' : '' } in the amount of :amount #{taxable ? '(taxable :taxable) ' : ''}:acknowledge_flow",
      'es' => ":declaring_account reconoce :accepting_account#{description ? ' por :description' : '' } en la cantidad de :amount #{taxable ? '(ingreso imponible :taxable) ' : ''} :acknowledge_flow",
  	  'fr' => ":declaring_account remercie :accepting_account#{description ? 'pour :description' : '' } et lui verse la somme de :amount #{taxable ? '(imposable :taxable) ' : ''}:acknowledge_flow"
  	}
  	currency_spec['summary_form'] = {
      'en' => "Balance: :balance, Volume :volume",
      'es' => "Balance: :balance, Volumen :volume"
  	}
  	currency_spec
  end
  
  def default_reputation_currency(rating_type)
    r = { 
      'type' => 'integer',
      'description' => {
        'en' => 'Rating',
        'es' => 'Calificacíon'
      },
      'values_enum' =>   {
    		"2qual" => {
          'en' => [['Good',1],['Bad',2]],
          'es' => [['Bueno',1],['Malo',2]],
        },
    		"2yesno" => {
    		  'en' => [['Yes',2],['No',1]],
    		  'es' => [['Si',2],['No',1]],
    		},
    		"3qual" => {
    		  'en' => [['Good',3],['Average',2],['Bad',1]],
    		  'es' => [['Bueno',3],['Mediano',2],['Malo',1]],
    		},
    		"4qual" => {
    		  'en' => [['Excellent',4],['Good',3],['Average',2],['Bad',1]],
    		  'es' => [['Excellente',4],['Bueno',3],['Mediano',2],['Malo',1]],
    		},
    		"3stars" => [['***',3],['**',2],['*',1]],
    		"4stars" => [['****',4],['***',3],['**',2],['*',1]],
    		"5stars" => [['*****',5],['****',4],['***',3],['**',2],['*',1]],
    		"3" => (1..3).to_a,
    		"4" => (1..4).to_a,
    		"5" => (1..5).to_a,
    		"10" => (1..10).to_a
      }[rating_type]
    }      
    currency_spec = {}
    currency_spec['fields'] = {
    	'rate' => {
        'type' => 'submit',
    	},
      'rating' => r,
    }
  	currency_spec['summary_type'] = 'average(rating)'
  	currency_spec['input_form'] = {
  	  'en' => ":declaring_account rates :accepting_account as :rating :rate",
  	  'es' => ":declaring_account califica :accepting_account como :rating :rate"
  	}
  	currency_spec['summary_form'] = {
  	  'en' => ":Overall rating: :average_accepted (from :count_accepted total ratings)",
      'es' => "Calificacíon: :average_accepted (de :count_accepted calificacíones)"
  	}
  	currency_spec    
  end
  
  def currency_select(html_field_name,selected,account = nil)
    c = Currency.find(:all).collect{|e| e.omrl}
    select_tag(html_field_name,options_for_select(c,selected))
  end

  def contexts_select(html_field_name,selected)
    c = Entity.find(:all, :conditions => "entity_type = 'context' ").collect{|e| e.omrl}
    select_tag(html_field_name,options_for_select(c,selected))
  end

  def unit_of_measure_select(html_field_name,selected = nil)
    select_tag(html_field_name, unit_of_measure_options_for_select)
  end
  
  def unit_of_measure_options_for_select(language = OpenMoneyDefaultLanguage)
    l = UnitToLanguage[language]
    l ||= UnitToLanguage[OpenMoneyDefaultLanguage]
    l.collect {|o| unit = o[0];%Q|<option value="#{unit}">#{o[1]} (#{UnitToHTMLMap[unit]})</option>|}.join("\n")
  end


  ################################################################################
  # Helper to convert the currency spec into an html form
  # options:
  #  +langauge
  #  +pre_specified_fields: hash used to to display values (like a declaring_account)
  #   instead of asking the user for them.
  def input_form(currency_spec,options = {})
    language = options[:language] ||= OpenMoneyDefaultLanguage
    pre_specified_fields = options[:pre_specified_fields]
    
    field_spec = currency_spec["fields"]
    form = currency_spec["input_form"][language]
    form ||= currency_spec["input_form"][OpenMoneyDefaultLanguage]
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
  def render_field(field_name,field_spec,language = OpenMoneyDefaultLanguage)
    fspec = get_field_spec(field_name,field_spec)

    html_field_name = "flow_spec[#{field_name}]"

    field_description = fspec['description']
    field_description = field_description[language] if field_description.is_a?(Hash)

    field_type = fspec['type']
    case 
    when fspec['values_enum']
      enum = fspec['values_enum']
      if enum.is_a?(Hash)
        enum = enum[enum.has_key?(language) ? language : OpenMoneyDefaultLanguage ]
      end
      select_tag(html_field_name,options_for_select(enum,@params[field_name]))
    when field_type == "boolean"
      select_tag(html_field_name,options_for_select([[l('Yes'), "true"], [l('No'), "false"]],@params[field_name]))
    when field_type == "submit"
      submit_tag(field_description,:id=>"commit") << '<span id="commit_processing" style="display:none">Processing...</span>'
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
  def render_summary(summary_form,summary,options = {})
    return '' if summary.nil?
    language = options[:language] ||= OpenMoneyDefaultLanguage

    form = summary_form[language]
    form ||= summary_form[OpenMoneyDefaultLanguage]
    form.gsub(/:([a-zA-Z0-9_-]+)/) do |m| 
      summary[$1]
    end
  end
  
  ################################################################################
  # Helper that returns the flows of a currency as specified by the options
  # as well as the header field names in the correct language.
  def history(account_omrl,currency_omrl,currency_spec,options = {})
    config = {
      :language  => OpenMoneyDefaultLanguage,
      :sort_order => nil,
      :count => 20,
      :page => 0,
    }.update(options)
    sort_order = config[:sort_order]
    params = {:in_currency => currency_omrl }
    params[:with] = account_omrl if account_omrl
    flows = Flow.find(:all, :params => params)
    fields = currency_spec['fields']
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