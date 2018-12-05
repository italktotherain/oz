class TextFieldElement < CoreElement
    def self.type
        :text_field
    end

    def assign_element_type
        @element_type = :input
    end

    def watir_element
      if @world.configuration['BROWSER'] == 'appium'
        super
      else
        @watir_element ||= parent.text_field(@locator_hash)
      end
    end

    def value
        assert_active
        watir_element.value
    end

    def fill(data)
      assert_active
      @world.logger.action "Filling [#{@name}] with [#{data}]"
      manually_clear if @world.configuration["BROWSER"] == "internet_explorer"
      @world.configuration['BROWSER'] == 'appium' ? watir_element.send_keys(data) : watir_element.set(data)

      begin
        if @world.configuration['BROWSER'] == 'appium'
          Watir::Wait.until(timeout: 1){watir_element.text == data}
        else
          Watir::Wait.until(timeout: 1){watir_element.value == data}
        end
      rescue
        raise "ERROR: Problem filling element [#{@name}] with [#{data}] value after fill was found as [#{watir_element.value}]"
      end
      @world.ledger.record_fill(@name, data)
      super
    end

    def manually_clear
      watir_element.click
      browser.send_keys(:end)
      watir_element.value.size.times do
          browser.send_keys(:backspace) unless watir_element.value == ""
      end
    end

end