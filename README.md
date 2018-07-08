
# What is pemu

pemu is a Protocol EMUlator.

# Installation

pemu depends on below packages.
- bindata
- thor

## install packages

	$ gem install bindata thor

or

	$ bundle install

# Usage

1. packetをYAML形式で保存する

1. 電文を投げる

	```
	$ ./bin/pemu.rb req trans -p 1234 -v 2
	```
    -iを指定しなければ./.ymlのYAMLデータを投げます。

