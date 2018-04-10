class MaskedTextFieldElement < CoreElement
    def self.type
        :masked_text_field
    end

    def assign_element_type
      @element_type = :input
    end

    def watir_element
      if @world.configuration['BROWSER'] == 'appium'
        super
      else
        @watir_element ||= browser.text_field(@locator_hash)
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

      # For a text field that immediately masks itself the best we can do is to compare the lengths
      if @world.configuration['BROWSER'] == 'appium'
        begin
          Watir::Wait.until(timeout: 1){watir_element.text.length == data.length}
        rescue
          raise "ERROR: Problem filling masked element [#{@name}] with [#{data}], length of value after fill was found as [#{watir_element.text.length}]"
        end
      else
        begin
          Watir::Wait.until(timeout: 1){watir_element.value.length == data.length}
        rescue
          raise "ERROR: Problem filling masked element [#{@name}] with [#{data}], length of value after fill was found as [#{watir_element.value.length}]"
        end
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