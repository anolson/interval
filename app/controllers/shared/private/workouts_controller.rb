class Shared::Private::WorkoutsController < Shared::WorkoutController  
  def initialize
    @private=true
    super
  end
end
