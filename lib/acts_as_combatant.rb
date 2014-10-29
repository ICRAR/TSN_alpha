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
      #create message
      msg = "Your #{self.model_name}:#{self.id} has been destroyed by #{killer.the_sky_map_player.profile.name}"
      self.the_sky_map_player.send_msg(msg,self.the_sky_map_quadrant)
      #destroy self
      self.destroy
    end
    def is_healthy?
      self.damage < self.health_value
    end
    def attack(defender)
      attacker = self
      quadrant = self.the_sky_map_quadrant
      attack_chance = 50..100
      attack_damage = ((rand(attack_chance) * attacker.attack_value) / 100.0).round
      defender.take_damage(attack_damage)
      #check if defender if still alive
      if defender.is_healthy?
        #defender retaliates
        defend_chance = 25..75
        defend_damage = ((rand(defend_chance) * defender.attack_value) / 100.0).round
        attacker.take_damage(defend_damage)
        if attacker.is_healthy?
          if attacker.model_name == defender.model_name
            PostToFaye.request_update(attacker.model_name,[attacker.id, defender.id])
          else
            PostToFaye.request_update(attacker.model_name,[attacker.id])
            PostToFaye.request_update(defender.model_name,[defender.id])
          end
        else
          #destroy defender
          attacker.killed_by(defender)
          PostToFaye.request_update('quadrant',[quadrant.id])
          PostToFaye.remove_model_delayed(attacker.id,attacker.model_name)
        end
      else
        #destroy defender
        defender.killed_by(attacker)
        PostToFaye.request_update('quadrant',[quadrant.id])
        PostToFaye.remove_model_delayed(defender.id,defender.model_name)
      end
      true
    end
  end
end


ActiveRecord::Base.send(:include, ActsAsCombatant)