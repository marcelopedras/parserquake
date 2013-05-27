require 'parser_quake_errors_class'

class Array
    def sum
        self.inject{|sum,x| sum + x }
    end
end

class ParserLogQuake

	@@means_of_death = [
		'MOD_RAILGUN',
		'MOD_UNKNOWN',
		'MOD_SHOTGUN',
		'MOD_GAUNTLET',
		'MOD_MACHINEGUN',
		'MOD_GRENADE',
		'MOD_GRENADE_SPLASH',
		'MOD_ROCKET',
		'MOD_ROCKET_SPLASH',
		'MOD_PLASMA',
		'MOD_PLASMA_SPLASH',
		'MOD_RAILGUN',
		'MOD_LIGHTNING',
		'MOD_BFG',
		'MOD_BFG_SPLASH',
		'MOD_WATER',
		'MOD_SLIME',
		'MOD_LAVA',
		'MOD_CRUSH',
		'MOD_TELEFRAG',
		'MOD_FALLING',
		'MOD_SUICIDE',
		'MOD_TARGET_LASER',
		'MOD_TRIGGER_HURT',
		'MOD_NAIL',
		'MOD_CHAINGUN',
		'MOD_PROXIMITY_MINE',
		'MOD_KAMIKAZE',
		'MOD_JUICED',
		'MOD_GRAPPLE'
		]
	
	
	def initialize(path_arq)
		string = File.open(path_arq, 'rb') { |file| file.read}
		@arq = Array.new
		@games = Array.new
		@cont = 0
		string.each_line do |line| 
			@arq << line
			if start_game?(line)
				#puts "\n\n#{line}"
				@games << Game.new(@cont)
				@cont+=1				
			elsif player_info?(line)
				@games.last.add_player(Player.new(get_player_info(line)))				
			elsif kill?(line)
				killer = get_killer(line)
				victim = get_victim(line)
				mean = get_cause_of_death(line)
				#puts "\n-------------------------\n"
				#puts line
				#puts "\n#{killer} -- #{victim} -- #{mean}\n"
				#puts "#{(@games.last.players_names).join('|')}"
				#puts "\n-------------------------\n"

				@games.last.add_kill
				#puts @games.last.players_names

				if killer != "<world>"
					player1 = @games.last.player(killer)
					player1.add_kills
					player1.update_kills_by_means(mean)
				end
			
				player2 = @games.last.player(victim)
				player2.add_deaths
				player2.update_deaths_by_means(mean)

				if killer == "<world>"			
					player2.subtract_kills
					player2.update_penalty_by_means(mean)
				end
			end
		end		
	end

	def print
		@arq.each{|p| puts p}
	end
	
	def to_s
		buffer =''
		@games.each do |x|
			buffer+= "#{x.to_s}\n"
		end
		buffer
	end

	def get
		@arq
	end

	def games
		@games
	end

#private
	def start_game?(line)
		line=~/^\s{1,2}\d{1,2}:\d{2} InitGame:/ ? true : false
		#^\s{1,2}\d{1,2}:\d{2} InitGame:
	end
	
	#Não foi necessário
	#def end_game?(line)
	#	line=~/^ (\d:\d\d|\d\d:\d\d) ShutdownGame:$/ ? true : false
	#end
	
	#Não foi necessário
	#def new_player?(line)
	#	line=~/^ (\d:\d\d|\d\d:\d\d) ClientConnect:/ ? true : false
	#end

	def kill?(line)
		line=~/^ (\d:\d\d|\d\d:\d\d) Kill:/ ? true : false
	end
	
	def get_cause_of_death(line)
		line.match(/(#{@@means_of_death.join('|')})$/).to_s
	end
	
	def get_killer(line)
		#puts "#{(@games.last.players_names).join('|')}"
		line.match(/(#{(@games.last.players_names << '<world>').join('|')}) killed/).to_s.gsub!(/ killed$/,'')
	end
	
	def get_victim(line)
		#puts (@games.last.players_names << '<world>').join('|')
		#@games.last.show
		#line.match(/\(#{(@games.last.players_names).join('|')}\) by/).to_s.gsub!(/ by$/,'')
		line.match(/(#{(@games.last.players_names << '<world>').join('|')}) by/).to_s.gsub!(/ by$/,'')
	end
	
	def player_info?(line)
		#puts line
		line=~/^(\s\d{2}|\s\s\d):\d{2} ClientUserinfoChanged:/ ? true : false	
	end
	
	def get_player_info(line)
		#puts line		
		line.match(/n\\.+\\t\\\d/).to_s.gsub(/n\\|\\t\\\d/,'')			
	end
	
end

class Game	
	
    	
    	def initialize(id)
		begin
			raise ParserQuakeException::MustBeInteger, "<id> deve ser um número inteiro" if id.class != Fixnum
	    		@id = id
	    		@total_kills = 0
	    		@players = Hash.new
		rescue ParserQuakeException::MustBeInteger
			raise
		end    		
    	end

	def to_s
		deaths_by_means = Hash.new
		@players.each_pair do |k,p|
			deaths_by_means.merge!(p.deaths_by_means){|k,v1,v2| v1+v2}
		end

		"game_#{@id}:\n"+
    		     "{"+
    		     	"\ttotal_kills: #{@total_kills}\n"+
    		     	"\tplayers:\n"+
    		     	"\t{\n"+
    		     		@players.map{|n,p| "\t\t#{n}"}.join(",\n")+
    		     	"\n\t}\n"+
    		     	"\tkills:\n"+
    		     	"\t{\n"+
    		     		@players.map{|n,p| "\t\t#{n}: #{p.kills} #{p.penalities? ? p.penalities_to_s : ''}"}.join("\n")+
    		     	"\n\t}\n"+
			"\tdeaths_by_means:\n"+
    		     	"\t{\n"+
    		     		deaths_by_means.map{|n,p| "\t\t#{n}: #{p}"}.join("\n")+
    		     	"\n\t}\n"+   		     	
    		     	
    		     "}"
    	end
    	
    	def add_player(player)
		begin
			raise ArgumentError,"<player> não pode ser nil" if player.nil?			
			raise ParserQuakeException::PlayerMustBeUnique, "Não pode haver players com nomes igual para um game" if player?(player.name)
    			@players.merge!({player.name => player})
		rescue ArgumentError
			raise
		rescue ParserQuakeException::PlayerMustBeUnique
			#raise
			#Um player pode se desconectar e reconectar durante uma partida, então nada será feito
		end
    	end
    	
    	def add_kill
    		@total_kills+=1
    	end
    	
    	def total_kills
    		@total_kills
	end
	
	def kills
		@players.map{|k,p| {p.name => p.kills}}.reduce Hash.new, :merge
	end
	
	def players_names
		@players.keys.sort
	end
	
	def players
		@players
	end
		
	def player?(player_name)
		@players[player_name] ? true : false
	end
	
	def player(player_name)
		begin
			raise ParserQuakeException::PlayerNotExists, "<#{player_name}> nao existe nesta partida" if !player?(player_name) 
		@players[player_name]
		rescue ParserQuakeException::PlayerNotExists
			raise
		end
	end

	#Atalhos para métodos da classe Player
	def add_kills(player_name)
		self.player(player_name).add_kills
	end
	
	def subtract_kills(player_name)
		self.player(player_name).subtract_kills
	end
	
	def update_kills_by_means(player_name, mean)
		self.player(player_name).update_kills_by_means(mean)
	end
	
	def add_deaths(player_name)
		self.player(player_name).add_deaths
	end
	
	def update_deaths_by_means(player_name, mean)
		self.player(player_name).update_deaths_by_means(mean)
	end 
end

class Player	
	
	def initialize(name)
		begin
			raise ParserQuakeException::MustBeString, '<name> deve ser uma string' if name.class!=String
			raise ParserQuakeException::BlankString, '<name> não pode ser uma string vazia ou conter apenas espacos' if name.gsub(/\s/,'').empty?

			@name = name
			@kills=0
			@deaths=0
			@kills_by_means = Hash.new
			@deaths_by_means = Hash.new
			@penalty_by_means = Hash.new

		rescue ParserQuakeException::MustBeString => e
			raise
		rescue ParserQuakeException::BlankString => e
			raise			
		end
	end
	
	def name
		@name
	end
	
	def add_kills
		@kills+=1
	end
	
	def subtract_kills
		@kills-=1
	end
	
	
	def kills
		@kills
	end
	
	def add_deaths
		@deaths+=1
	end
	
	def deaths
		@deaths
	end
	
	def kills_by_means
		@kills_by_means
	end
	
	def deaths_by_means
		@deaths_by_means
	end
	
	def to_hash
		{:name => @name,
		 :kills => @kills,
		 :deaths =>@deaths,
		 :kills_by_means =>@kills_by_means,
		 :deaths_by_means => @deaths_by_means,
		 :penalty_by_means => @penalty_by_means}
	end
	
	def update_kills_by_means(mean)
		begin
			raise ParserQuakeException::MustBeString, "<mean> de ser uma string" if mean.class!=String
			raise ParserQuakeException::BlankString, '<mean> não pode ser uma string vazia ou conter apenas espacos' if mean.gsub(/\s/,'').empty?
			@kills_by_means[mean] ? @kills_by_means[mean]+=1 : @kills_by_means[mean]=1
		rescue ParserQuakeException::MustBeString
			raise
		rescue ParserQuakeException::BlankString
			raise
		end
	
	end
	
	def update_deaths_by_means(mean)
		begin
			raise ParserQuakeException::MustBeString, "<mean> de ser uma string" if mean.class!=String
			raise ParserQuakeException::BlankString, '<mean> não pode ser uma string vazia ou conter apenas espacos' if mean.gsub(/\s/,'').empty?
			@deaths_by_means[mean] ? @deaths_by_means[mean]+=1 : @deaths_by_means[mean]=1
		rescue ParserQuakeException::MustBeString
			raise
		rescue ParserQuakeException::BlankString
			raise
		end	
	end

	#TODO TESTAR
	def penalities?
		number_of_penalties > 0 ? true : false		
	end
	
	def penalities_to_s
		" (kills of penalty: #{number_of_penalties} by {#{hash_to_s(penalty_by_means)}})"		
	end
	
	def to_s
		penalties_number = number_of_penalties
		
		 #{if penalties_number then "#{penalties_number} kill(s) of penalty (#{penalty_by_means})"end}
		" Player: #{@name}"+
			"\n\tKills: #{@kills} #{if penalities? then penalities_to_s end}"+
			"\n\tDeaths: #{@deaths}"+
			"\n\tKills by means:"+
			"\n\t{\n"+
				@kills_by_means.map{|x,y| "\t\t#{x}: #{y}"}.join("\n")+
			"\n\t}\n"+
			"\n\tDeaths by means:"+
			"\n\t{\n"+
				@deaths_by_means.map{|x,y| "\t\t#{x}: #{y}"}.join("\n")+
			"\n\t}\n\n\n"
	end

	def update_penalty_by_means(mean)
		begin
			raise ParserQuakeException::MustBeString, "<mean> de ser uma string" if mean.class!=String
			raise ParserQuakeException::BlankString, '<mean> não pode ser uma string vazia ou conter apenas espacos' if mean.gsub(/\s/,'').empty?		
			@penalty_by_means[mean] ? @penalty_by_means[mean]+=1 : @penalty_by_means[mean]=1
		rescue ParserQuakeException::MustBeString
			raise
		rescue ParserQuakeException::BlankString
			raise
		end
	end

	def penalty_by_means
		@penalty_by_means
	end

	def number_of_penalties
		@penalty_by_means.size == 0 ? 0 : @penalty_by_means.values.sum

	end
private
	def hash_to_s(hash)
		hash.map do |k,v|
			"#{k}: #{v}"		
		end.join(', ')		
	end
	
end

#parser = ParserLogQuake.new('games.log.original.txt')

