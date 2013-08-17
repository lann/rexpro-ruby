# Rexpro

[![Build Status](https://travis-ci.org/lann/rexpro-ruby.png)](https://travis-ci.org/lann/rexpro-ruby)

Tested against rexster-server-2.4.0 on Ruby 1.9.3 and 2.0.0.

https://github.com/tinkerpop/rexster/wiki/RexPro

## Installation

**NOTE: Version 1.x breaks compatibility with rexster-server-2.3 and below!**

Use 0.x gem versions for older versions of rexster, or follow the protocol-0
branch which may still recieve critical updates.

Add this line to your application's Gemfile:

    gem 'rexpro'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rexpro

## Usage

```ruby
require 'rexpro'

client = Rexpro::Client.new(host: 'localhost', port: 8184) # defaults

response = client.execute('g.v(2)', graph_name: 'tinkergraph')

response.results
=> {"_id"=>"2", "_type"=>"vertex", "_properties"=>{"name"=>"vadas", "age"=>27}}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
