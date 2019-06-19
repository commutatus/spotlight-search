# SpotlightSearch

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/spotlight_search`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spotlight_search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spotlight_search

## Usage

After installing the gem to the project, there are few places you will have to make changes.

### Controller

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

### HTML
**STEP - 1 Search**
First step is to add the input box to search. Here there are few elements that should be placed mandatorily.

```
.filters.w-100 data-filter-url="/admin/workshops" data-replacement-class="workshops_table"
	.col-md-4.input-group.search
		input#workshop-search-filter.form-control.filter-box name=("search_term_for_workshops ") placeholder=("Search Workshops") type="text" data-behaviour="filter" data-scope="search" data-type="input-filter"
```

The elements that should be placed mandatorily are

  * `.filters` All search input / select filter should be nested inside this class name.
  * `data-filter-url` Is mandatory, this is the search URL, Mostly this will hit the index action.
  * `data-replacement-class` After ajax this is the class name where the data will get appended.
  * `data-behaviour="filter"` If the input behaviour is set to filter then this will get added to ajax
  * `data-scope="search"` This is the model scope name, The helper method will call this when filter is applied.
  * `data-type="input-filter"` This is to tell if the element is input or select other value is `data-type="select-filter"`

**STEP - 2 Pagination**
We will add the paginate helper to the bottom of the partial which gets replaced.
```
= cm_paginate(@filtered_result.facets)
```
**STEP - 3 Sort**
If any of the header needs to be sorted, then we will  add the following helper
```
th = sortable "name", "Name", @filtered_result.sort[:sort_column], @filtered_result.sort[:sort_direction]
```
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/spotlight_search. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SpotlightSearch project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/spotlight_search/blob/master/CODE_OF_CONDUCT.md).
