# SpotlightSearch

It helps filtering, sorting and exporting tables easier.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spotlight_search'
```

And then execute:

    $ bundle

Or install it manually:

    $ gem install spotlight_search

## Usage

### Export to file

#### Model
Enables or disables export and specifies which all columns can be
exported. Export is disabled for all columns by default.

For enabling export for all columns in all models

```ruby
  class ApplicationRecord < ActiveRecord::Base
    export_columns enabled: true
  end
```

For disabling export for only specific models

```ruby
  class Person < ActiveRecord::Base
    export_columns enabled: false
  end
```

For allowing export for only specific columns in a model

```ruby
  class Person < ActiveRecord::Base
    export_columns enabled: true, only: [:created_at, :updated_at]
  end
```

For excluding only specific columns and allowing all others

```ruby
  class Person < ActiveRecord::Base
    export_columns enabled: true, except: [:created_at, :updated_at]
  end
```

#### View

Add `exportable email, model_object` in your view to display the export button.

```html+erb
<table>
  <tr>
    <th>Name</th>
    <th>Email</th>
  </tr>
  <td>
    <% @records.each do |record| %>
      <tr>
        <td><%= record.name %></td>
        <td><%= record.value %></td>
    <% end %>
  </td>
</table>

<%= exportable(current_user.email, current_user.class) %>
```

This will first show a popup where an option to select the export enabled columns will be listed. This will also apply any filters that has been selected along with a sorting if applied. It then pushes the export to a background job which will send an excel file of the contents to the specified email. You can edit the style of the button using the class `export-to-file-btn`.

**Note**

You will need to have a background job processor such as `sidekiq`, `resque`, `delayed_job` etc as the file will be generated in the background and will be sent to the email passed.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/commutatus/spotlight_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SpotlightSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/commutatus/spotlight_search/blob/master/CODE_OF_CONDUCT.md).
