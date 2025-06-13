# This module can be used to ensure that state transitions are atomic.
#
# Example:
#
# class Game < ApplicationRecord
#   prepend TransitionTransaction
#
#   workflow do
#     state :draft do
#       event :start, transitions_to: :started
#     end
#   end
# end
#
# In this example, the start event will be processed in a transaction.

module TransitionTransaction
  def process_event!(name, *, **)
    transaction { super(name, *, **) }
  end
end
