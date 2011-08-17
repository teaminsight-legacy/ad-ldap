# AD::LDAP

A small wrapper to Net::LDAP to provide some extended functionality and utility.

## Description

AD::LDAP is a small wrapper to the Net::LDAP library. Net::LDAP provides a nice low-level interface for interacting with an LDAP server. AD::LDAP simply wraps that interface and provides some extended functionality through:

* Built-in logging of any communication with the LDAP server
* Easier searching

## Installation

    gem install ad-ldap

## Usage

First, you need to configure the gem:

```ruby
AD::LDAP.configure do |config|
  config.host = "127.0.0.1"
  config.port = 389
  config.base = "DC=mydomain, DC=com"
  config.encrytion = :simple_tls
  config.logger = Rails.logger
end
```

Then you can start running LDAP commands like you would with Net::LDAP.

```ruby
# logs your search and returns a collection of matching Net::LDAP::Entry
AD::LDAP.search({
  :base => "DC=Users, DC=mydomain, DC=com",
  :filter => "(name=collin)"
})

# most of the commands have the same syntax as they do in net-ldap
AD::LDAP.add({
  :dn => "DN=collin, DC=Users, DC=mydomain, DC=com",
  :attributes => { :givenname => "Collin", :lastname => "Redding" }
})

# some are slightly modified though
AD::LDAP.delete("DN=collin, DC=Users, DC=mydomain, DC=com")
# instead of: AD::LDAP.delete({ :dn => "DN=collin, DC=Users, DC=mydomain, DC=com })
```

The biggest feature of AD::LDAP is some of the conventions when using the search method. If I don't provide a filter and have extra keys not supported by net-ldap's search, these are converted to filters automatically for me:

```ruby
# searching for an object named "collin"
AD::LDAP.search({ :name__eq => "collin" })

# the equality filter is defaulted so this can even be simplified to
AD::LDAP.search({ :name => "collin" })

# multiple filters are supported and automatically joined (AND)
AD::LDAP.search({ :name => "collin", :objectclass => "user" })

# AD::LDAP doesn't get in your way if you need to do something complex though
name_filter = Net::LDAP::Filter.eq("name", "collin*")
class_filter = Net::LDAP::Filter.eq("objectclass", "user")
filters = name_filter | class_filter
AD::LDAP.search({ :filter => filters, :size => 1 })
```

Finally, because the LDAP names for most fields are not very ruby-ish (are all one word) it's sometimes convenient to setup mappings from a more ruby friendly name to a LDAP name:

```ruby
AD::LDAP.configure do |config|
  # ... use previous config here
  config.mapppings = {
    "login" => "samaccountname"
  }
end

# you can use the mapping when performing a search
AD::LDAP.search({ :login => "jcredding" })

# which is equivalent to
AD::LDAP.search({ :samaccountname => "jcredding" })
```

## License

Copyright (c) 2011 Collin Redding, and Team Insight

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.