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
     include SunspotSearch

     searchable do
       text :title, :body
       time :published_at
       integer author_id
     end

     sunspot_search_with :title, :body, :published_at, :author_id
   end
```

Your parameters keys should be prefixed with 'filter_'. You can use filters in the next way:
* ?filter_text=Foo
* ?filter_title=My+Awesome+Title
* ?filter_author_id=5

Or if you are searching using dates you can use keys like 'filter_published_at_start' and/or 'filter_published_at_end' to set a date range.


In your controllers you can simply use **sunspot\_search** to retrieve the results:
```ruby
   class ArticlesController < ActionController::Base
     def index
       @articles = Article.sunspot_search(params).results
     end
   end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
