require "./parser_quake"
require "test/unit"



class TestPlayer < Test::Unit::TestCase
	def test_initialize
		assert_raise(ArgumentError){Player.new}
		assert_raise(ParserQuakeException::MustBeString){Player.new 1}
		assert_raise(ParserQuakeException::BlankString){Player.new " "}
	end
	
	def test_get_name		
		p = Player.new "marcelo"
		assert_equal("marcelo", p.name)		
	end
	
	def test_get_add_and_subtract_kills
		p=Player.new "marcelo"
		assert_equal(0, p.kills)
		p.add_kills
		assert_equal(1, p.kills)
		p.add_kills
		assert_equal(2, p.kills)
		p.subtract_kills
		assert_equal(1, p.kills)
		p.subtract_kills
		p.subtract_kills
		assert_equal(-1, p.kills)		
	end

	def test_get_and_add_deaths
		p=Player.new "marcelo"
		assert_equal(0,p.deaths)
		p.add_deaths
		assert_equal(1,p.deaths)
		p.add_deaths
		assert_equal(2,p.deaths)	
	end

	def test_get_and_set_kill_by_means
		p=Player.new "marcelo"
		assert_equal({},p.kills_by_means)
		p.update_kills_by_means("shotgun")
		assert_equal({"shotgun" => 1}, p.kills_by_means)
		p.update_kills_by_means("machine-gun")
		assert_equal({"shotgun" => 1, "machine-gun"=>1}, p.kills_by_means)
		assert_equal({"machine-gun"=>1, "shotgun" => 1}, p.kills_by_means)
		p.update_kills_by_means("shotgun")
		assert_equal({"machine-gun"=>1, "shotgun" => 2}, p.kills_by_means)
	end

	def test_get_and_set_deaths_by_means
		p=Player.new "marcelo"
		assert_equal({},p.deaths_by_means)
		p.update_deaths_by_means("shotgun")
		assert_equal({"shotgun" => 1}, p.deaths_by_means)
		p.update_deaths_by_means("machine-gun")
		assert_equal({"shotgun" => 1, "machine-gun"=>1}, p.deaths_by_means)
		assert_equal({"machine-gun"=>1, "shotgun" => 1}, p.deaths_by_means)
		p.update_deaths_by_means("shotgun")
		assert_equal({"machine-gun"=>1, "shotgun" => 2}, p.deaths_by_means)
	end

	def test_get_and_set_penalty
		p = Player.new "marcelo"
		assert_equal({}, p.penalty_by_means)
		assert_equal(0, p.number_of_penalties)
		p.update_penalty_by_means("queda de arvore")
		assert_equal({"queda de arvore" => 1}, p.penalty_by_means)
		p.update_penalty_by_means("atingido por raio")
		assert_equal({"queda de arvore" => 1,"atingido por raio" => 1}, p.penalty_by_means)
		p.update_penalty_by_means("atingido por raio")
		assert_equal({"queda de arvore" => 1,"atingido por raio" => 2}, p.penalty_by_means)
		assert_equal(3, p.number_of_penalties)		
	end

	def test_get_hash_player
		p=Player.new "marcelo"
		p.add_kills
		p.add_deaths
		p.update_kills_by_means("pistol")
		p.update_deaths_by_means("queda de arvore")
		p.update_penalty_by_means("queda de arvore")
		assert_equal(
		{:name => "marcelo",
		 :kills => 1,
		 :deaths => 1,
		 :kills_by_means =>{"pistol" => 1},
		 :deaths_by_means => {"queda de arvore" => 1},
		 :penalty_by_means => {"queda de arvore" => 1}}, p.to_hash)				
	end

	def test_player_to_string
		p=Player.new "marcelo"
		assert_equal(" Player: marcelo\n\tKills: 0 \n\tDeaths: 0\n\tKills by means:\n\t{\n\n\t}\n\n\tDeaths by means:\n\t{\n\n\t}\n\n\n",p.to_s)
		p.add_kills
		p.add_deaths
		assert_equal(" Player: marcelo\n\tKills: 1 \n\tDeaths: 1\n\tKills by means:\n\t{\n\n\t}\n\n\tDeaths by means:\n\t{\n\n\t}\n\n\n",p.to_s)
		p.update_kills_by_means("shotgun")
		assert_equal(" Player: marcelo\n\tKills: 1 \n\tDeaths: 1\n\tKills by means:\n\t{\n\t\tshotgun: 1\n\t}\n\n\tDeaths by means:\n\t{\n\n\t}\n\n\n",p.to_s)
		p.update_deaths_by_means("queda de arvore")
		assert_equal(" Player: marcelo\n\tKills: 1 \n\tDeaths: 1\n\tKills by means:\n\t{\n\t\tshotgun: 1\n\t}\n\n\tDeaths by means:\n\t{\n\t\tqueda de arvore: 1\n\t}\n\n\n",p.to_s)
		p.update_penalty_by_means("queda de arvore")
		assert_equal(" Player: marcelo\n\tKills: 1  (kills of penalty: 1 by {queda de arvore: 1})\n\tDeaths: 1\n\tKills by means:\n\t{\n\t\tshotgun: 1\n\t}\n\n\tDeaths by means:\n\t{\n\t\tqueda de arvore: 1\n\t}\n\n\n",p.to_s)
				
	end	
end

class TestGame < Test::Unit::TestCase
	def setup
		@player = Player.new 'Terminator'	
	end

	def test_hash_to_s
		assert_equal('',@player.send(:hash_to_s, @player.penalty_by_means))
		@player.update_penalty_by_means('queda de arvore')
		assert_equal('queda de arvore: 1', @player.send(:hash_to_s, @player.penalty_by_means))	
	end
	
	def test_initialize
		assert_raise(ParserQuakeException::MustBeInteger){Game.new 'a'}
		assert_raise(ArgumentError){Game.new}
		assert_nothing_raised{Game.new 1}
	end

	def test_add_player
		p1 = Player.new "marcelo"
		p2 = Player.new "marcelo"
		g = Game.new 1
		assert_raise(ArgumentError){g.add_player nil}
		assert_nothing_raised{g.add_player p1}
		#Esse teste foi retirado pois essa restrição foi retirada devido a possibilidade de haver reconexões
		#assert_raise(ParserQuakeException::PlayerMustBeUnique){g.add_player p2}	
	end

	def test_get_player
		p1= Player.new "marcelo"
		p2= Player.new "pedro"
		g = Game.new 1
		g.add_player p1
		g.add_player p2
		assert_equal(p1, g.player("marcelo"))
		assert_equal(p2, g.player("pedro"))
		assert_equal(true, g.player?("marcelo"))
		assert_equal(false, g.player?("fulano"))
		assert_equal({p1.name => p1, p2.name => p2},g.players)
		assert_equal(["marcelo", "pedro"],g.players_names)
	end
	
	def test_add_and_get_kills
		p1= Player.new "marcelo"
		p2= Player.new "pedro"
		g = Game.new 1

		g.add_player p1
		g.add_player p2
		g.add_kill
		assert_equal(1, g.total_kills)
		g.add_kills("marcelo")
		g.add_deaths("pedro")
		assert_equal(1, g.player("pedro").deaths)
		assert_equal(1,g.player("marcelo").kills)
		g.subtract_kills("marcelo")
		assert_equal(0, g.player("marcelo").kills)
		g.update_kills_by_means("marcelo", "shotgun")
		assert_equal({"shotgun"=> 1},g.player("marcelo").kills_by_means)
		g.update_deaths_by_means("marcelo", "queda de arvore")
		assert_equal({"queda de arvore"=>1}, g.player("marcelo").deaths_by_means)

		assert_raise(ParserQuakeException::MustBeString){g.update_kills_by_means("marcelo",1)}
		assert_raise(ParserQuakeException::MustBeString){g.update_deaths_by_means("marcelo",1)}
		assert_nothing_raised{g.subtract_kills("marcelo")}
		assert_nothing_raised{g.add_kills("marcelo")}
		
	end	
end

class TestParserLogQuake< Test::Unit::TestCase
	
	def setup
		@parser_log_quake = ParserLogQuake.new('games.log.original.txt')	
	end

	def test_start_game?
		assert_equal(true, @parser_log_quake.send(:start_game?, ' 20:37 InitGame: \sv_floodProtect\1\sv_maxPing\0\sv_minPing\0\sv_maxRate\10000\sv_minRate\0\sv_hostname\Code Miner Server\g_gametype\0\sv_privateClients\2\sv_maxclients\16\sv_allowDownload\0\bot_minplayers\0\dmflags\0\fraglimit\20\timelimit\15\g_maxGameClients\0\capturelimit\8\version\ioq3 1.36 linux-x86_64 Apr 12 2009\protocol\68\mapname\q3dm17\gamename\baseq3\g_needpass\0'))	
	end

	def test_player_info?
		assert_equal(true, @parser_log_quake.send(:player_info?, ' 20:38 ClientUserinfoChanged: 2 n\Isgalamido\t\0\model\uriel/zael\hmodel\uriel/zael\g_redteam\\g_blueteam\\c1\5\c2\5\hc\100\w\0\l\0\tt\0\tl\0'))
	end

	def test_get_player_info
		assert_equal('Isgalamido', @parser_log_quake.send(:get_player_info, ' 20:38 ClientUserinfoChanged: 2 n\Isgalamido\t\0\model\uriel/zael\hmodel\uriel/zael\g_redteam\\g_blueteam\\c1\5\c2\5\hc\100\w\0\l\0\tt\0\tl\0'))
	end

	def test_kill?
		assert_equal(true, @parser_log_quake.send(:kill?, ' 21:07 Kill: 1022 2 22: <world> killed Isgalamido by MOD_TRIGGER_HURT'))
	end

	def test_get_cause_of_death
		assert_equal('MOD_MACHINEGUN', @parser_log_quake.send(:get_cause_of_death, '  4:37 Kill: 3 5 3: Isgalamido killed Assasinu Credi by MOD_MACHINEGUN'))
	end

	def test_get_killer
		assert_equal('Isgalamido', @parser_log_quake.send(:get_killer, '  4:37 Kill: 3 5 3: Isgalamido killed Assasinu Credi by MOD_MACHINEGUN'))	
	end

	def test_get_victim
		assert_equal('Assasinu Credi', @parser_log_quake.send(:get_victim, '  4:37 Kill: 3 5 3: Isgalamido killed Assasinu Credi by MOD_MACHINEGUN'))
	end

end

