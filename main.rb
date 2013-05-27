load "parser_quake.rb"

p = ParserLogQuake.new("games.log.original.txt")

puts "\n\nInformações sobre todas as partidas\n\n"

puts p.games				#exibe informações de todas as partidas

puts "\n\nExibe o número de partidas jogadas\n\n"

puts p.games.size			#exibe o número de partidas jogadas

puts "\n\nInformações sobre a primeira partida\n\n"

puts p.games.first 			#exibe informações da primeira partida

puts "\n\nInformações sobre os jogadores da última partida \n\n"

puts p.games.last.players		#exibe informações dos jogadores da primeira partida

puts "\n\nNome dos jogadores da última partida \n\n"

puts p.games.last.players_names		#exibe os nomes dos jogadors

puts "\n\nInformações sobre o Player Isgalamido na última partida \n\n"

puts p.games.last.players["Isgalamido"]	#exibe informações do jogador Isgalamido da última partida
