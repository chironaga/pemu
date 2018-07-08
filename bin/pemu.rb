#!/usr/bin/env ruby
require 'thor'
require_relative '../lib/example/parser'
require_relative '../lib/example/transfer'
require_relative '../lib/example/administration'

module Pemu

	class Req < Thor
		desc 'trans', 'Emulate transfer sequence'
		long_desc <<-LONGDESC
Using with specifing protocol sequence is below.
If you ommit protocol sequence then default sequence will be assigned
with specified version.
\x5$ #{$0} req trans -p1234 -v7 -s a,b,c,d,e

If you make sure of input data then use dry-run option
\x5$ #{$0} req trans -p1234 -v7 -d
		LONGDESC
		option :h, desc: 'To be connected host name', default: 'localhost'
		option :p, desc: 'To be connected port number', required: true, type: :numeric
		option :v, desc: 'Specify protocol version', required: true, type: :numeric, banner: '{1,2,3}'
		option :i, desc: 'Path to input sending data', default: '.yml'
		option :o, desc: 'Path to output receiving data', default: '.yml'
		option :d, desc: 'Enble dry run', type: :boolean, default: false
		option :s, desc: 'Specify protocol sequence', default: ''
		def trans
			Example::Protocol::Transfer.request(options)
		end

		desc 'admin', 'Emulate admin sequence'
		option :h, desc: 'To be connected host name', default: 'localhost'
		option :p, desc: 'To be connected port number', required: true, type: :numeric
		option :v, desc: 'Specify protocol version', required: true, type: :numeric, banner: '{1,2,3}'
		option :i, desc: 'Path to input sending data', default: '.yml'
		option :o, desc: 'Path to output receiving data', default: '.yml'
		option :d, desc: 'Enble dry run', type: :boolean, default: false
		option :s, desc: 'Specify protocol sequence', default: ''
		def admin
			Example::Protocol::Administration.request(options)
		end
	end

	class Res < Thor
		desc 'trans', 'Emulate transfer sequence'
		option :p, desc: 'To be connected port number', required: true, type: :numeric
		option :v, desc: 'Specify protocol version', required: true, type: :numeric, banner: '{1,2,3}'
		option :i, desc: 'Path to input sending data', default: '.yml'
		option :o, desc: 'Path to output receiving data', default: '.yml'
		option :d, desc: 'Enble dry run', type: :boolean, default: false
		option :s, desc: 'Specify protocol sequence', default: ''
		def trans
			Example::Protocol::Transfer.response(options)
		end

		desc 'admin', 'Emulate admin sequence'
		option :p, desc: 'To be connected port number', required: true, type: :numeric
		option :v, desc: 'Specify protocol version', required: true, type: :numeric, banner: '{1,2,3}'
		option :i, desc: 'Path to input sending data', default: '.yml'
		option :o, desc: 'Path to output receiving data', default: '.yml'
		option :d, desc: 'Enble dry run', type: :boolean, default: false
		option :s, desc: 'Specify protocol sequence', default: ''
		def admin
			Example::Protocol::Administration.response(options)
		end
	end

	class CLI < Thor
		register(Req, 'req', 'req COMMAND', 'Request sequence emulation')
		register(Res, 'res', 'res COMMAND', 'Response sequence emulation')

		desc 'parse', 'Parse captured data'
		option :i, desc: 'Path to input captured data.', required: true, banner: 'input'
		option :o, desc: 'Path to output parsed data.', banner: 'output', default: '.yml'
		def parse
			Example::Protocol::Parser.parse(options)
		end
	end
end

Pemu::CLI.start
