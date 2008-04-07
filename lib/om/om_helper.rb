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
  	currency_spec['history_header'] = {
      'en' => [{:_date => 'Date'},{:_with => 'With'},{:_if_with_accepter => '+'},{:_if_with_declarer => '-'}], #,{:_balance => 'Balance'},{:_volume => 'Volume'}
      'es' => [{:_date => 'Fecha'},{:_with => 'Con'},{:_if_with_accepter => '+'},{:_if_with_declarer => '-'}], #,{:_balance => 'Balance'},{:_volume => 'Volumen'}
      'fr' => [{:_date => 'Jour'},{:_with => 'Avec'},{:_if_with_accepter => '+'},{:_if_with_declarer => '-'}], #,{:_balance => 'Balance'},{:_volume => 'Volume'}
	  }
  	currency_spec['history_row'] = [
  	  ':_date',':_with',':_if_with_accepter(amount)',':_if_with_declarer(amount)'#,':_balance',':_volume'
  	]
	  if taxable
	    currency_spec['history_header']['en'].insert(1,{:taxable => 'Tax?'})
	    currency_spec['history_header']['es'].insert(1,{:taxable => 'Imponible?'})
	    currency_spec['history_header']['fr'].insert(1,{:taxable => 'Imposable?'})
    	currency_spec['history_row'].insert(1,':taxable')
    end
  	if description
	    currency_spec['history_header']['en'].insert(1,{:description => 'Description'})
	    currency_spec['history_header']['es'].insert(1,{:description => 'Descripción'})
	    currency_spec['history_header']['fr'].insert(1,{:description => 'Description?'})
    	currency_spec['history_row'].insert(1,':description')
	  end
  	currency_spec['input_form'] = {
  	  'en' => ":declaring_account acknowledges :accepting_account#{description ? ' for :description' : '' } in the amount of :amount #{taxable ? '(taxable :taxable) ' : ''}:acknowledge_flow",
      'es' => ":declaring_account reconoce :accepting_account#{description ? ' por :description' : '' } en la cantidad de :amount #{taxable ? '(ingreso imponible :taxable) ' : ''} :acknowledge_flow",
  	  'fr' => ":declaring_account remercie :accepting_account#{description ? 'pour :description' : '' } et lui verse la somme de :amount #{taxable ? '(imposable :taxable) ' : ''}:acknowledge_flow"
	  }
  	currency_spec['summary_form'] = {
      'en' => "Balance: :balance, Volume :volume",
      'es' => "Balance: :balance, Volumen :volume",
      'fr' => "Balance: :balance, Volumen :volume"
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
          'en' => [['Good',"1"],['Bad',"2"]],
          'es' => [['Bueno',"1"],['Malo',"2"]],
        },
    		"2yesno" => {
    		  'en' => [['Yes',"2"],['No',"1"]],
    		  'es' => [['Si',"2"],['No',"1"]],
    		},
    		"3qual" => {
    		  'en' => [['Good',"3"],['Average',"2"],['Bad',"1"]],
    		  'es' => [['Bueno',"3"],['Mediano',"2"],['Malo',"1"]],
    		},
    		"4qual" => {
    		  'en' => [['Excellent',"4"],['Good','3'],['Average','2'],['Bad','1']],
    		  'es' => [['Excellente','4'],['Bueno','3'],['Mediano','2'],['Malo','1']],
    		},
    		"3stars" => [['***','3'],['**','2'],['*','1']],
    		"4stars" => [['****','4'],['***','3'],['**','2'],['*','1']],
    		"5stars" => [['*****','5'],['****','4'],['***','3'],['**','2'],['*','1']],
    		"3" => ('1'..'3').to_a,
    		"4" => ('1'..'4').to_a,
    		"5" => ('1'..'5').to_a,
    		"10" => ('1'..'10').to_a
      }[rating_type]
    }      
    currency_spec = {}
    currency_spec['fields'] = {
    	'rate' => {
        'type' => 'submit',
    	},
      'rating' => r,
    }
  	currency_spec['history_header'] = {
      'en' => [{:_date => 'Date'},{:declaring_account => 'From'},{:accepting_account => 'To'},{:rating => 'Rating'}],
      'es' => [{:_date => 'Fecha'},{:declaring_account => 'De'},{:accepting_account => 'Para'},{:rating => 'Calificacion'}],
      'fr' => [{:_date => 'Jour'},{:declaring_account => 'De'},{:accepting_account => 'Á'},{:rating => 'Rating'}]
	  }
  	currency_spec['history_row'] = [
  	  ':_date',':declaring_account',':accepting_account',':rating'#,':_balance',':_volume'
  	]
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
  def input_form(field_values,currency_spec,options = {})
    language = options[:language] ||= OpenMoneyDefaultLanguage
    pre_specified_fields = options[:pre_specified_fields]
    
    field_spec = currency_spec["fields"]
    form = currency_spec["input_form"][language]
    form ||= currency_spec["input_form"][OpenMoneyDefaultLanguage]
    form.gsub(/:([a-zA-Z0-9_-]+)/) do |m|
      field_name = $1
      if pre_specified_fields && pre_specified_fields.has_key?(field_name)
        pre_specified_fields[field_name]
      else
        render_field(field_values[field_name],field_name,get_field_spec(field_name,field_spec),language)
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
  
  def get_field_names(fields_spec,language = OpenMoneyDefaultLanguage,except = nil)
    field_names = {}
    n = fields_spec.keys
    n = n - except.map {|e| e.to_s} if except
    n.each do |field_name|
      fspec = get_field_spec(field_name,fields_spec)
      if !['unit','submit'].include?(fspec['type'])
        field_description = get_language_translated_spec(fspec,'description',language)
        field_names[field_name] = field_description
      end
    end
    field_names
  end
  
  def get_language_translated_spec(spec,spec_name,language)
    s = spec[spec_name]
    if s.is_a?(Hash)
      if s.has_key?(language)
        s = s[language] 
      else
        s = s[OpenMoneyDefaultLanguage]
      end
    end
    s
  end

  ################################################################################
  # renders and individual field in the input form specification according to choosen language
  def render_field(field_value,field_name,field_spec,language = OpenMoneyDefaultLanguage)
    html_field_name = "flow_spec[#{field_name}]"

    field_description = get_language_translated_spec(field_spec,'description',language)

    field_type = field_spec['type']
    case 
    when field_spec['values_enum']
      enum = field_spec['values_enum']
      if enum.is_a?(Hash)
        enum = enum[enum.has_key?(language) ? language : OpenMoneyDefaultLanguage ]
      end
      select_tag(html_field_name,options_for_select(enum,field_value))
    when field_type == "boolean"
      select_tag(html_field_name,options_for_select([[l('Yes'), "true"], [l('No'), "false"]],field_value))
    when field_type == "submit"
      submit_tag(field_description,:id=>"commit") << '<span id="commit_processing" style="display:none">Processing...</span>'
    when field_type == "text"
      text_field_tag(html_field_name,field_value)
    when field_type == "float"
      text_field_tag(html_field_name,field_value)
    when field_type == "unit"
      UnitToHTMLMap[field_name]
    else
      text_field_tag(field_name,field_value)
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
  def history(account_omrl,currency_omrl,options = {})
    config = {
      :count => 20,
      :page => 0,
    }.update(options)
    params = {:in_currency => currency_omrl }
    params[:with] = account_omrl if account_omrl
    flows = Flow.find(:all, :params => params)
  end
  
  ################################################################################
  # helper that returns an array of rendered flows according to a currency specification
  # as well as the header field names in the correct language.
  def render_history(flows,account_omrl,currency_spec,options = {})
    config = {
      :language  => OpenMoneyDefaultLanguage,
      :sort_order => nil
    }.update(options)
    history_row = currency_spec['history_row']

    f = []
    language = config[:language]
    field_specs = currency_spec["fields"]

    # load the fspecs into a has to be used in rendering the values
    field_names_as_symbols = []
    fspecs = {}
    field_specs.keys.each {|field| fspecs[field] = get_field_spec(field,field_specs)}
        
    flows.each do |flow|
      the_flow = {}
      used_fields = {}
      flow_attributes = flow.get_specification
      history_row.each do |cell|
        if cell =~ /:([a-zA-Z0-9_-]+)(\((.*)\))*/
          field = $1
          used_fields[field] = 1
          params = $3
          if field =~ /^_/
            cell_value = case field
            when '_date'
              flow.created_at
            when '_with'
               flow.specification_attribute('declaring_account') == @account_omrl ? render_field_value(flow,'accepting_account',fspecs['accepting_account'],language) : render_field_value(flow,'declaring_account',fspecs['declaring_account'],language)
            when '_balance'
              'NA'
            when '_volume'
              'NA'
            when '_if_with_accepter'
              flow.specification_attribute('accepting_account') == @account_omrl ? render_field_value(flow,params,fspecs[params],language) : ''
            when '_if_with_declarer'
              flow.specification_attribute('declaring_account') == @account_omrl ? render_field_value(flow,params,fspecs[params],language) : ''
            else
              "#{field} not implemented"
            end
          else            
            cell_value = render_field_value(flow,field,fspecs[field],language)
          end
          the_flow[field.intern] = cell_value
        end
      end
      (field_specs.keys - the_flow.keys {|fi| fi.to_s}).each {|fl| the_flow[fl.intern] = render_field_value(flow,fl,fspecs[fl],language)}
      f << the_flow
    end
    
#    sort_order = config[:sort_order]
#    if sort_order =~ /^-(.*)/
#      reverse = true
#      sort_order = $1
#    end
#    if sort_order == nil or sort_order == ''
#      flows = flows.sort_by {|a| a.created_at}.reverse
#    else
#      flows = flows.sort_by {|a| a.specification_attribute(sort_order)}
#    end
#    flows = flows.reverse if reverse
    history_header = get_language_translated_spec(currency_spec,'history_header',language)
    [f,history_header]
  end
  
  def render_field_value(flow,field,fspec,language)
    value = flow.specification_attribute(field)
    return value if fspec.nil?
    field_type = fspec['type']
    case 
    when fspec['values_enum']
      enum = fspec['values_enum']
      if enum.is_a?(Hash)
        enum = enum[enum.has_key?(language) ? language : OpenMoneyDefaultLanguage ]
      end
      Hash[*enum.map {|x| x.reverse}.flatten][value]
    when field_type == "boolean"
      #TODO localize
      value
    when field_type == "text"
      value
    when field_type == "float"
       sprintf("%.2f",value)
    else
      value
    end
  end  
end