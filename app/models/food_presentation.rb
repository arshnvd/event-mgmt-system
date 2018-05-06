class FoodPresentation

  include DataMapper::Resource

  property :id, Serial
  property :menu_id, Integer
  property :crockery, Enum[:disposable, :bone_china, :glass, :steel]
  property :presentation, Enum[:decorated, :simple]

  belongs_to :menu
end
