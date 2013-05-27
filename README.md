parserquake
===========

Algoritmo que faz um parse do log de Quake Arena III contendo informações sobre partidas, jogadores, mortes e penalidades.

Projeto: ParserLogQuake
Autor: Marcelo Pedras
email: marcelo.braulio.si@gmail.com

Descrição: O algoritmo desenvolvido utilizando ruby 1.8.7 é capaz de ler o log gerado por Quake Arena III, carregando informações como:
  -número de kills por partida
	-nome dos jogadores
	-pontuação dos jogadores por partida
	-penalidades por jogador
	-motivo das mortes
	
Três classes foram desenvolvidas para tanto:
	-Player
	-Game
	-ParserLogQuake

ParserLogQuake é a classe principal, responsável por processar a informação do arquivo. Seu construtor recebe o caminho para o arquivo de log e criar internamente várias instâncias de Game e Player, descrevendo as partidas.

Um exemplo de uso da classe ParserLogQuake seria(Obs: Você deve estar dentro da pasta que contem os arquivos parser_quake.rb e games.log.original.txt para que os comandos abaixo funcionem):

load 'parser_quake.rb'

p = ParserLogQuake.new('games.log.original.txt')
puts p.games				#exibe informações de todas as partidas

puts p.games.first 			#exibe informações da primeira partida

puts p.games.last.players		#exibe informações dos jogadores da primeira partida

puts p.games.last.players_names		#exibe os nomes dos jogadors

puts p.games.last.players['Isgalamido']	#exibe informações do jogador Isgalamido da última partida

Você pode executar o arquivo main.rb, contendo os exemplos da seguinte forma (Obs: É necessário que o interpretador ruby versão 1.8.7 esteja instalado na sua máquina, e que caso você esteja usando rvm, a versão em uso seja a 1.8.7 ):

ruby games.rb


O resultado pedido em Task1 e Task2 pode ser obtido utilizando, por exemplo, o comando:

load 'parser_quake.rb'

p = ParserLogQuake.new('games.log.original.txt')
puts p.games.last	#houve mais ação nesta partida :-)

Um plus para o que foi pedido são as informações de motivo da morte e arma utilizada para matar de cada player. Para isso utilize:

puts p.games.last.players['Oootsimo']	#os nomes dos players envolvidos na partida podem ser obitidos com o comando p.games.last.players_names

Os testes foram feitos utilizando Test::Unit, nativo do ruby e podem ser executados utilizando o comando:

ruby parser_quake_test.rb			


