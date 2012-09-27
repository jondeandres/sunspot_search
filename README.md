# SunspotSearch

A gem to search with Sunspot using filters in the query string.


## Installation

Add this line to your application's Gemfile:

    gem 'sunspot_search'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sunspot_search

## Usage

You must configure in your models the filters the user is allowed to use in the query string using **sunspot\_search\_with**.

```ruby
   class Article
     searchable do
       text :title, :body
       time :published_at
     end

     sunspot_search_with :title, :body, :published_at
   end
```

In your controllers you can simply use **sunspot\_search** to retrieve the results:
```ruby
   class ArticlesController < ActionController::Base
     def index
       @articles = Article.sunspot_search(params)
     end
   end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
