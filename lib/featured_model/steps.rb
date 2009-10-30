Given /^a new (\S+)(.*) with:$/ do |model_name, args, attr_table|
  combined_args = args
  attr_table.raw.each do |attr_array|
    attr_name = attr_array[0]
    attr_value = attr_array[1]
    attr_phrase = " with #{attr_name} \"#{attr_value}\""
    combined_args += attr_phrase
  end
  create_dynamic_instance model_name, combined_args
end

Given /^a new (\S+)(.*[^:])$/ do |model_name, args|
  create_dynamic_instance model_name, args
end

def create_dynamic_instance model_name, args
  attributes = {}
  parsing_state = ""
  args.scan(/(for|with|and) ([^\"]+) "([^\"]*)"/).each do |declaration|
    join_word, key, value = declaration
    parsing_state = join_word unless join_word == 'and'

    case parsing_state
    when 'with' ; attributes[key.gsub(/ /, '_').to_sym] = value
    when 'for'
      associated_model, lookup_attribute = key.split(' with ').map {|x| x.gsub(/ /, '_')}
      fk_name = associated_model
      klass = Address

      # TODO: Pick up these aliases dynamically from the ActiveRecord declarations.
      # it should not live here
      if associated_model == 'address'
        fk_name = 'shipping_address'
      else
        klass = associated_model.classify.constantize
      end

      attributes[fk_name + '_id'] = klass.first(:conditions => {lookup_attribute => value}).id
    else        ; raise('unknown join word "%s"' % parsing_state)
    end
  end
  send("create_#{model_name}".to_sym, attributes)
end