Given /^a new (\S+)(.*)$/ do |model_name, args|
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