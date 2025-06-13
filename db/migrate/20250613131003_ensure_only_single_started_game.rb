class EnsureOnlySingleStartedGame < ActiveRecord::Migration[8.0]
  def change
    add_index :games, :workflow_state, where: "workflow_state = 'started'", unique: true, name: "index_games_on_workflow_state_started"
  end
end
