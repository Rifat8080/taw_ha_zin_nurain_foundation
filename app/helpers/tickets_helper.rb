module TicketsHelper
	# Returns a CSS class string for the status badge based on ticket status
	def status_badge_class(status)
		base = "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium"

		case status.to_s.downcase
		when 'active'
			"#{base} bg-green-100 text-green-800"
		when 'used'
			"#{base} bg-blue-100 text-blue-800"
		when 'cancelled', 'refunded'
			"#{base} bg-red-100 text-red-800"
		else
			"#{base} bg-gray-100 text-gray-800"
		end
	end
end
