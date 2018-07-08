require 'bindata'
require 'yaml'

module Example
	module Protocol

		class Command < BinData::Record
			endian :big

			def send(io)
				write(io)
			end

			def recv(io)
				puts ""
				puts "<<<<< Receiving"
				BinData::trace_reading(STDOUT) do
					read(io)
				end
			end

			def assign(val)
				#clear
				assign_fields(val)
			end

			def assign_random_data
				instantiate_all_objs
				@field_objs.each do |o|
					r = o.eval_parameter(:range)
					s = o.eval_parameter(:length)
					if r != nil
						if o.class == BinData::String
							o.assign r.split(",").sample
						else
							a = r.split("-")
							o.assign rand a[0].to_i .. a[1].to_i
						end
					else
						o.assign [*('a'..'z'),*('A'..'Z'),*('1'..'9')].sample(rand(s)+1).join if o.class == BinData::String
					end
				end
			end

			def to_yaml
				eval(inspect).to_yaml
			end
		end

		module V1

			class ExampleA < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
			end

			class ExampleB < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
				bit8 :debug, :initial_value=>0
			end

		module V2
			include V1

			class ExampleC < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
			end

			class ExampleD < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
				bit8 :debug, :initial_value=>0
			end

		module V3
			include V2

			class ExampleE < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
			end

			class ExampleF < BinData::Record
				endian :big
				uint16 :len, :length=>2, :initial_value=>lambda{self.num_bytes - 2}
				bit8 :debug, :initial_value=>0
			end
		end

	end
end

