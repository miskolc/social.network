module ApplicationHelper

    # Returns the full title on a per-page basis.
	def full_title(page_title)
		base_title='Fresone'
		if page_title.empty?
			base_title
		else 
			"#{base_title} | #{page_title}"
		end		
	end

    def symbol_to_bootstrap_class(symbol)
        case symbol
        # :alert is used by Devise after successful sign up, sign in, etc    
        when :alert then "error" 
        else  symbol
        end   
    end    

end
