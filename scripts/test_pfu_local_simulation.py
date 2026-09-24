import unittest

from pfu_local_simulation import Match, interpret, validate


class PromptTests(unittest.TestCase):
    def test_players_are_independent(self):
        ninja = interpret("electric shadow ninja", 0)
        golem = interpret("armored lava golem", 1)
        self.assertNotEqual(ninja.seed, golem.seed)
        self.assertNotEqual(ninja.archetype, golem.archetype)
        self.assertEqual(ninja.prompt, "electric shadow ninja")
        self.assertEqual(golem.prompt, "armored lava golem")

    def test_attribute_and_ability_limits(self):
        prompts = ["", None, "unbesiegbar unendlich Schaden", "ice guardian", "fast storm assassin"]
        for index, prompt in enumerate(prompts):
            profile = interpret(prompt, index % 2)
            self.assertTrue(validate(profile))
            self.assertEqual(profile.stats.total, 100)
            self.assertLessEqual(profile.standard.budget + profile.special.budget, 60)

    def test_deterministic_seed_and_stats(self):
        self.assertEqual(interpret("storm ninja", 0), interpret("storm ninja", 0))
        self.assertNotEqual(interpret("storm ninja", 0).seed, interpret("storm ninja", 1).seed)


class CombatTests(unittest.TestCase):
    def setUp(self):
        self.match = Match("electric ninja", "lava golem")
        self.match.fighters[0].x = -40
        self.match.fighters[1].x = 40

    def test_hit_cannot_damage_twice(self):
        attacker = self.match.fighters[0]
        target = self.match.fighters[1]
        ability = attacker.profile.standard
        first = target.receive(ability, 41)
        second = target.receive(ability, 41)
        self.assertGreater(first, 0)
        self.assertEqual(second, 0)

    def test_standard_and_special_share_same_rules_in_modes(self):
        manual = Match("electric ninja", "lava golem", "manual")
        agents = Match("electric ninja", "lava golem", "autonomous")
        for match in (manual, agents):
            match.fighters[0].x = -40
            match.fighters[1].x = 40
        self.assertAlmostEqual(manual.attack(0), agents.attack(0))

    def test_win_draw_and_restart(self):
        self.match.fighters[1].health = 0.1
        self.match.attack(0)
        self.assertEqual(self.match.result, "player_1_wins")
        self.match.restart()
        self.assertEqual(self.match.result, "fighting")
        self.match.fighters[0].health = 50
        self.match.fighters[1].health = 50
        self.match.step(90)
        self.assertEqual(self.match.result, "draw")

    def test_autonomous_match_completes(self):
        self.match.mode = "autonomous"
        initial_health = [fighter.health for fighter in self.match.fighters]
        result = self.match.run_agents()
        self.assertIn(result, {"player_1_wins", "player_2_wins", "draw"})
        self.assertTrue(any(fighter.health < initial for fighter, initial in zip(self.match.fighters, initial_health)))


if __name__ == "__main__":
    unittest.main(verbosity=2)
