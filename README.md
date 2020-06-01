[![Gem Version](https://badge.fury.io/rb/spotlight_search.svg)](https://badge.fury.io/rb/spotlight_search)

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

Generator that installs mandatory files and gems to application

    $ rails g spotlight_search:install

Include the spotlight_search javascript by adding the line `//= require spotlight_search` to your `app/assets/javascripts/application.js`

## Usage

1. [Filtering, Sorting and Pagination](#filtering-sorting-and-pagination)
  * [Controller](#controller)
  * [View](#view)
2. [Export table data to excel](#export-table-data-to-excel)
  * [Initializer](#initializer)
  * [Routes](#Routes)
  * [Model](#model)
  * [View](#export-view)

### Filtering, Sorting and Pagination

#### Controller

**STEP - 1**

First step is to add the search method to the index action.

```
@filtered_result = @workshop.filter_by(params[:page], filter_params.to_h, sort_params.to_h)
```

`filter_by` is the search method which accepts 3 arguments. `page`, `filter_params`, `sort_params`.
All 3 params are sent from the JS which is handled by the gem.

**STEP - 2**

Second Step is to add the permitted params. Since the JS is taking up values from HTML,
we do not want all params to be accepted. Permit only the scopes that you want to allow.

```
def filter_params
  params.require(:filters).permit(:search) if params[:filters]
end

def sort_params
  params.require(:sort).permit(:sort_column, :sort_direction) if params[:sort]
end
```

#### View
Please note that the below code is in haml.

**STEP - 1 Filters**

**Wrapping div for filters**

  First step is to add wrapper div around the filters you're going to add. Include this line at the beginning of your filter inputs
    
  ```
    = filter_wrapper(data_behaviours, classes=nil)

    <!-- Data attributes can be passed as a Hash and the below are mandatory -->
      
      {filter_url: '/users', replacement_class: 'users-table'}  
    
    <!-- Classes are optional and you can pass them as a String -->
      
      "filter-classes"

  ```

  * `data-filter-url` Is mandatory, this is the search URL, Mostly this will hit the index action.

  * `data-replacement-class` After ajax this is the class name where the data will get appended.

**Select-tags and Inputs**

  ```
    <!-- This is to generate a select tag for filters. -->
    = cm_select_tag(select_options, data_behaviours, classes=nil, placeholder=nil)
  ```

  * `select_options` this variable carries the options to the select tag.

  ```
    <!-- This is to generate a text input field for filters. -->
    = cm_textfield_tag(data_behaviours, classes=nil, placeholder=nil)
  ```

  ```
    <!-- This is to revert all filters. -->
    = clear_filters(clear_path, classes=nil, data_behaviours=nil, clear_text=nil)
  ```
  * `clear_path` this the controller index path.

  * `clear_text` this gives the text for the `a` tag.

  Common attributes

  * `data_behaviours` this carries data attributes as a Hash to `select_tag` or `input`.
    
    These are mandatory attributes for filters
    
     `{behaviour: "filter", scope: "search", type: "(select/input)-filter}`

    `data-behaviour="filter"` If the input behaviour is set to filter then this will get added to ajax.

    `data-scope="search"` This is the model scope name, The helper method will call this when filter is applied.

    `data-type="input-filter"` This is to tell if the element is input or select other value is `data-type="select-filter"`

  * `classes` HTML classes can be passed as a string arguement for inputs/select tags.

  * `placeholder` this arguement passes the placeholder for input/select tags.


**STEP - 2 Pagination**

We will add the paginate helper to the bottom of the partial which gets replaced.
```
= cm_paginate(@filtered_result.facets)
```

**STEP - 3 Sort**

If any of the header needs to be sorted, then we will add the following helper
```
th = sortable "name", "Name", @filtered_result.sort[:sort_column], @filtered_result.sort[:sort_direction]
```

### Export table data to excel

**Note**

You will need to have a background job processor such as `sidekiq`, `resque`, `delayed_job` etc as the file will be generated in the background and will be sent to the email passed. If you need to use any other service for sending emails, you will need to override `ExportMailer` class.

#### Initializer
An initializer will have to be created to extend the functionality to ActiveRecord.

```ruby
  # config/initializers/spotlight_search.rb
  ActiveRecord::Base.include SpotlightSearch::ExportableColumns
```

#### Routes
A line has to be added to the routes.

```ruby
mount SpotlightSearch::Engine => '/spotlight_search'
```

#### <a name="export-view"></a>View

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

<%= exportable(current_user.email, Person) %>
```

This will first show a popup where an option to select the export enabled columns will be listed. This will also apply any filters that has been selected along with a sorting if applied. It then pushes the export to a background job which will send an excel file of the contents to the specified email. You can edit the style of the button using the class `export-to-file-btn`.

#### Model

##### V1

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

##### V2

To use version two of column export, which supports model methods and nested associations, set it up in the spotlight initializer like this:
```ruby
# config/initializers/spotlight_search.rb
ActiveRecord::Base.include SpotlightSearch::ExportableColumns

SpotlightSearch.setup do |config|
  config.exportable_columns_version = :v2
end
```

All fields will be disabled by default, so you will need to explicitly enable them by passing them to `export_columns`

```ruby
class Person < ActiveRecord::Base
  export_columns :created_at, :formatted_amount, :preferred_month, :orderable_type, :payment_type, :status, customer: [:full_name, :email, :mobile_number, :city, :college], orderable: :orderable_display_name, seller: [:full_name]
end
```

Nested association fields should go at the end of `export_columns`, following Ruby's standard syntax of placing keyword arguments at the end

**Notes**
- You will need to make `filter_params` and `sort_params` in your controller public, or the rendering of the form will fail
- Be careful with methods that return a hash, as the algorithm will recursively create one column for every key inside that hash. One example is `Money` fields from the `money-rails` gem



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/commutatus/spotlight_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SpotlightSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/commutatus/spotlight_search/blob/master/CODE_OF_CONDUCT.md).
