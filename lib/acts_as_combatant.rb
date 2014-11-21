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
      true
    end
    def attack(defender)
      attacker = self
      quadrant = self.the_sky_map_quadrant
      attack_chance = 50..100
      attack_damage = ((rand(attack_chance) * attacker.attack_value) / 100.0).round
      defender.take_damage(attack_damage)
      #check if defender if still alive
      if defender.is_healthy?
        defender_killed = false
        #defender retaliates
        defend_chance = 25..75
        defend_damage = ((rand(defend_chance) * defender.attack_value) / 100.0).round
        attacker.take_damage(defend_damage)
        if attacker.is_healthy?
          attacked_killed = false
          if attacker.model_name == defender.model_name
            PostToFaye.request_update(attacker.model_name,[attacker.id, defender.id])
          else
            PostToFaye.request_update(attacker.model_name,[attacker.id])
            PostToFaye.request_update(defender.model_name,[defender.id])
          end
        else
          #destroy attacker
          attacked_killed = true
          attacker.killed_by(defender)
          PostToFaye.request_update('quadrant',[quadrant.id])
          PostToFaye.remove_model_delayed(attacker.id,attacker.model_name)
        end
      else
        defender
        defend_damage = 0
        #destroy defender
        defender.killed_by(attacker)
        defender_killed = true
        PostToFaye.request_update('quadrant',[quadrant.id])
        PostToFaye.remove_model_delayed(defender.id,defender.model_name)
      end
      return {
        action_outcome: true,
        attack_damage: attack_damage,
        defend_damge: defend_damage,
        defender_killed: defender_killed,
        attacked_killed: attacked_killed,
      }
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsCombatant)