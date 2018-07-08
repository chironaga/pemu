require_relative './protocol'
require_relative './packet'
require 'socket'
require 'pp'

module Example
	module Protocol

		class Transfer
			def self.request(*options)
				host = options[0]['h']
				port = options[0]['p']
				version = options[0]['v']
				input = options[0]['i']
				output = options[0]['o']
				dryrun = options[0]['d']
				sequence = options[0]['s']

				sender = Sender.new(version, sequence, input)
				sender.request(host, port, dryrun)
			end

			def self.response(*options)
				port = options[0]['p']
				version = options[0]['v']
				input = options[0]['i']
				output = options[0]['o']
				dryrun = options[0]['d']
				sequence = options[0]['s']

				receiver = Receiver.new(version, sequence, input)
				receiver.response(port, dryrun)
			end
		end

		class Sender
			def initialize(version, sequence, input)
				@version = version

				seq = sequence.split(',')
				if seq.size > 0
					@sequence = seq.map{|c| c.upcase}
				else
					case @version
					when 1
						@sequence =  %w(A B C)
					when 2
						@sequence =  %w(X Y Z)
					end
				end

				@packet_loader = PacketLoader.new(version, input)
			end

			def request(host, port, dryrun = false)
				if dryrun
					puts host
					puts port
					@sequence.each do |c|
						packet = @packet_loader.load(c)
						pp packet
					end
				else
					TCPSocket.open(host, port) do |sd|
						@sequence.each do |c|
							packet = @packet_loader.load(c)
							packet.send(sd)
							discard(sd)
						end
					end
				end
			end

			def discard(sd, show: false, capture: false)
				c = sd.recv(1, Socket::MSG_PEEK)
				case c
				when 'Q', 'W', 'E'
					cmd = eval("V#{@version}::#{c}_R.new")
				else
					cmd = eval("V#{@version}::#{c}.new")
				end
				cmd.recv(sd)
			end
		end

		class Receiver
			def initialize(version, sequence, input)
				@version = version

				seq = sequence.split(',')
				if seq.size > 0
					@sequence = seq.map{|c| c.upcase}
				else
					case @version
					when 1
						@sequence =  %w(A B C)
					when 2
						@sequence =  %w(D E F)
					end
				end

				@packet_loader = PacketLoader.new(version, input)
			end

			def response(port, dryrun = false)
				if dryrun
					puts port
					@sequence.each do |c|
						packet = @packet_loader.load(c)
						pp packet
					end
				else
					tcp = TCPServer.open(port)
					tcp.listen(5)
					# [todo] - handle simultaneous access
					sd = tcp.accept
					@sequence.each do |c|
						discard(sd)
						packet = @packet_loader.load(c)
						packet.send(sd)
					end
					sd.close
				end
			end

			# [todo] - output captured data for testing
			def discard(sd, show: false, capture: false)
				c = sd.recv(1, Socket::MSG_PEEK)
				begin
					cmd = eval("V#{@version}::#{c}.new")
					cmd.recv(sd)
				rescue Exception => e
					submsg = "\nReceived invalid packet: #{c}"
					raise e.class, e.message + submsg, caller
				end
			end
		end

	end
end

