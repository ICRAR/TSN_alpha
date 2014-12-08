module ActsAsCombatant
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_combatant(options = {})
      include ActsAsCombatant::LocalInstanceMethods
    end
  end

  module LocalInstanceMethods
    def take_damage(amount)
      self.class.where{id == my{self.id}}.update_all("damage = damage + #{amount.to_i}" )
      self.reload
    end
    def killed_by(killer)
      #destroy self
      self.destroy
    end
    def is_healthy?
      self.damage < self.health_value
    end
    def is_healable?
      self.damage > 0 && self.is_healthy?
    end
    def heal(amount)
      new_damage = [self.damage - amount,0].max
      self.class.where{id == my{self.id}}.update_all("damage = #{new_damage}" )
      self.reload
      PostToFaye.request_update(self.model_name,[self.id],self.the_sky_map_quadrant.game_map_id)
      true
    end
    #Attack takes place in teh following order
    #step 1 attack deals damage to the defender
    #step 2 if the defender survives it retaliates
    #There are 3 possible outcomes
    # outcome 1) The attacker kill the defender (in this case the attacker takes no damage)
    # outcome 2) The attacker fails to kill the defender and the defender retaliates killing the attacker
    # outcome 3) The attacker fails to kill the defender and the defender retaliates but does not kill the attacker
    def attack(defender)
      attacker = self
      quadrant = self.the_sky_map_quadrant
      #step 1
      attack_chance = 50..100
      attack_damage = ((rand(attack_chance) * attacker.attack_value) / 100.0).round
      defender.take_damage(attack_damage)
      #check if defender if still alive
      if defender.is_healthy?
        defender_killed = false
        #defender retaliates
        #step 2
        defend_chance = 25..75
        defend_damage = ((rand(defend_chance) * defender.attack_value) / 100.0).round
        attacker.take_damage(defend_damage)
        if attacker.is_healthy?
          # outcome 3) The attacker fails to kill the defender and the defender retaliates but does not kill the attacker
          attacker_killed = false
          if attacker.model_name == defender.model_name
            PostToFaye.request_update(attacker.model_name,[attacker.id, defender.id],quadrant.game_map_id)
          else
            PostToFaye.request_update(attacker.model_name,[attacker.id],quadrant.game_map_id)
            PostToFaye.request_update(defender.model_name,[defender.id],quadrant.game_map_id)
          end
        else
          # outcome 2) The attacker fails to kill the defender and the defender retaliates killing the attacker
          #destroy attacker
          attacker_killed = true
          attacker.killed_by(defender)
          PostToFaye.request_update('quadrant',[quadrant.id],quadrant.game_map_id)
          PostToFaye.remove_model_delayed(attacker.id,attacker.model_name,quadrant.game_map_id)
          PostToFaye.request_update(defender.model_name,[defender.id],quadrant.game_map_id)
        end
      else
        # outcome 1) The attacker kill the defender (in this case the attacker takes no damage)
        defend_damage = 0
        #destroy defender
        defender.killed_by(attacker)
        defender_killed = true
        PostToFaye.request_update('quadrant',[quadrant.id],quadrant.game_map_id)
        PostToFaye.remove_model_delayed(defender.id,defender.model_name,quadrant.game_map_id)
      end
      return {
        action_outcome: true,
        attack_damage: attack_damage,
        defend_damage: defend_damage,
        defender_killed: defender_killed,
        attacker_killed: attacker_killed,
      }
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsCombatant)