
require 'action_view'
require 'spotlight_search'

describe 'Serializer' do
  it 'serializes a complex object' do
    expect(SpotlightSearch::Utils.serialize_csv_columns(:a, :b, c: [:d, e: :h], f: :g)).to eql [:a, :b, "c/d", "c/e/h", "f/g"]
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
    expect(SpotlightSearch::Utils.deserialize_csv_columns([:a, :b, "c/d", "c/e/h", "f/g"], :json_params)).to eql({
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
