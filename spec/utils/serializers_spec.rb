
require 'action_view'
require 'spotlight_search'

describe 'Serializer' do
  it 'serializes a complex object' do
    expect(SpotlightSearch::Utils.serialize_csv_columns(:a, :b, c: [:d, e: :h], f: :g)).to eql [:a, :b, "c/d", "c/e/h", "f/g"]
  end

  it 'serializes an object with multiple hashes at the end' do
    pp SpotlightSearch::Utils.serialize_csv_columns(:created_at, :transaction_amount, :preferred_month, :payment_type, :status, :customer=>[:full_name, :email, :mobile_number, :city, :college], :association=>[:orderable_display_name, :type], :seller=>[:full_name])
    pp SpotlightSearch::Utils.serialize_csv_columns(**[:created_at, :transaction_amount, :preferred_month, :payment_type, :status, {:customer=>[:full_name, :email, :mobile_number, :city, :college]}, {:association=>[:orderable_display_name, :type]}, {:seller=>[:full_name]}])
  end

  it 'deserializes in base mode' do
    expect(SpotlightSearch::Utils.deserialize_csv_columns([:a, :b, "c/d", "c/e/h", "f/g"], :base)).to eql({
      columns:["a", "b"],
         :associations=>{
           "c"=>
            {:columns=>["d"],
             :associations=>{
               "e"=>{:columns=>["h"], :associations=>{}}
               }
             },
            "f"=>{:columns=>["g"], :associations=>{}
           }
          }
        })
  end

  it 'deserializes in json_params mode' do
    expect(SpotlightSearch::Utils.deserialize_csv_columns([:a, :b, "c/d", "c/e/h", "f/g"], :as_json_params)).to eql({
      :only=>[],
      :methods=>["a", "b"],
      :include=>{
        "c"=>{
          :only=>[],
          :methods=>["d"],
          :include=>{ "e"=>{:only=>[], :methods=>["h"], :include=>{} } }
        },
        "f"=>{:only=>[], :methods=>["g"], :include=>{}}
      }
    })
  end

end

describe 'hash flattener' do
  it 'flattens hashes correctly' do
    expect(SpotlightSearch::Utils.flatten_hash(
      name: "My name", occupation: "Spy", location: {city: "San Andreas", country: "Eagleland", gps: {lat: 40, lng: 50}}
    )).to eq({"name"=>"My name", "occupation"=>"Spy", "location_city"=>"San Andreas", "location_country"=>"Eagleland", "location_gps_lat"=>40, "location_gps_lng"=>50})
  end
end

describe 'recursive hash' do
  it 'creates deeply nested hashes' do
    expect(SpotlightSearch::Utils.recursive_hash[:one][:two][:three][:four]).to eq({})
  end
  it 'assigns deeply nested values' do
    hash = SpotlightSearch::Utils.recursive_hash
    hash[:one][:two][:three][:four] = :five
    expect(hash).to eq(
      {one: {two: {three: {four: :five}}}}
    )
  end
end
