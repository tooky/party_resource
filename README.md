# party_resource

Simple REST interface for ruby objects.

party_resource is a framework for building ruby objects which interact with a REST api. Built on top of HTTParty.

HTTParty is great for adding a couple of methods that fetch data from an HTTP api, but becomes cumbersome if you have
lots of objects that all need to connect to several routes on the api. ActiveResource doesn't give you enough control.

## Installation

    gem install party_resource

## Usage

For detailed usage instructions, please see the [API Documentation](http://yardoc.org/docs/edendevelopment-party_resource).

    PartyResource::Connector.add(:library, :base_uri => 'http://www.example.com/library')

    class Author
      include PartyResource

      property :name
      property :slug

      connect :books, :get => '/authors/:slug/books', :as => Book, :on => :instance

      def initialize(params = {})
        populate_properties(params)
      end
    end

    class Book
      include PartyResource

      property :title
      property :author, :as => Author

      connect :search, :get => '/search/:query', :with => :query

      def initialize(params = {})
        populate_properties(name)
      end
    end

    book = Book.search('Lord of the Rings')

    book.title #=> 'Lord of the Rings Trilogy'
    book.author.class #=> Author
    book.author.name #=> 'J. R. R. Tolkein'

    author = book.author

    author.books.map(&:title) #=> ['Lord of the Rings Trilogy', 'The Hobbit', 'The Silmarillion']

## Issues

Please use the [github issues tracker](http://github.com/edendevelopment/party_resource/issues).

## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 Eden Development (UK) LTD. See LICENSE for details.
