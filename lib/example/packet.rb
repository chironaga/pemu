require_relative './protocol'
require 'yaml'

module Example
	module Protocol

		class Packet
			attr_reader :name
			def initialize(version, file)
				@version = version
				@file = file
				@name = File.basename(file).sub(/\.yml/, '')
				@commands = load
			end

			def dequeue
				payload = @commands.shift
				payload ||= reload.shift
			end

			def load
				a = []
				File.open(@file) do |f|
					File.read(f).split('---').each do |v|
						h = YAML.load(v)
						next unless h
						command = eval("V#{@version}::#{@name}.new")
						command.assign(h)
						a << command
					end
				end
				a
			end

			def reload
				@commands = load
			end
		end

		class PacketLoader
			def initialize(version, input)
				@packets = {}
				Dir.glob(File.join(input, '*.yml')).each do |f|
					packet = Packet.new(version, f)
					@packets[packet.name] = packet
				end
			end

			def load(command)
				begin
					@packets[command].dequeue
				rescue
					raise RuntimeError, "Packet data `#{command}' is not found."
				end
			end
		end

	end
end
