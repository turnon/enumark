# Enumark

Enumerate chrome bookmark dump file

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'enumark'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install enumark

## Usage

Create the enumerator with path to your dump file:

```ruby
enum = Enumark.new('/path/to/bookmark_dump_file')

enum.each do |item|
  item.name
  item.href
  item.host
  item.categories
end

enum.each_host do |host|
  host.name
  host.items
end

enum.each_dup_title do |title|
  title.name
  title.items
end

enum.each_dup_href do |href|
  href.name
  href.items
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/enumark. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/enumark/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Enumark project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/enumark/blob/master/CODE_OF_CONDUCT.md).
