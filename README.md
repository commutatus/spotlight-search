[![Gem Version](https://badge.fury.io/rb/spotlight_search.svg)](https://badge.fury.io/rb/spotlight_search)

# SpotlightSearch

It helps filtering, sorting and exporting tables easier.

First create a new rails project with the following command. If you are adding to existing project skip this

```
rails new blog -m https://raw.githubusercontent.com/commutatus/cm-rails-template/devise_integration/template.rb
```


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

The install generator does the following

* `require spotlight_search` added to application.js

* Copies required files for the spotlight_search to work, Such as gemassets.rb, webpacker.yml, environment.js

* Copies initializer file

* Adds a line in route for mounting.

Generator that installs filter and table files to application
    $ rails g spotlight_search filter orders --filters scope_name:filter_type
    $ rails g spotlight_search filter orders --filters search:input order_status:multi_select status:select

scope_name is the model scope name, scope can written after running this generator, it won't throw any error that it has to be present.

Following filter type are supported
* input
* single-select
* multi-select
* datetime
* daterange


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

**Filter Wrapper, Select-tags and Inputs**

| Generator                                                                        | *Mandatory(Data Attributes, Select options)                                                                            | *Optional(Classes, Placeholders)                                                       |
|----------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------|
| `= filter_wrapper(data_behaviours, classes=nil)`                                 | `{filter_url: '/users', replacement_class: 'users-table'}`                                                             | "filter-classes"                                                                       |
|                                                                                  |                                                                                                                        |                                                                                        |
| `= cm_select_tag(select_options, data_behaviours, classes=nil, placeholder=nil)` | `{behaviour: "filter", scope: "status", type: "select-filter}` , User.all.map {\|user\| [user.name.titleize, user.id]} | `"user-select"`, placeholder = `"Users"`                                               |
|                                                                                  |                                                                                                                        |                                                                                        |
| `= cm_textfield_tag(data_behaviours, classes=nil, placeholder=nil)`              | `{behaviour: "filter", scope: "search", type: "input-filter}`                                                          | `"user-search"`, placeholder = `"Search"`                                              |
|                                                                                  |                                                                                                                        |                                                                                        |
| `= clear_filters(clear_path, classes=nil, data_behaviours=nil, clear_text=nil)`  | clear_path = `users_path`                                                                                              | `"clear-filter"`, data_behaviours = `{behaviour: 'clear'}`, clear_text = `"Clear all"` |


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
