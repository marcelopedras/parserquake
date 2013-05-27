module ParserQuakeException
	class MustBeString < StandardError; end
	class BlankString < StandardError; end
	class MustBeInteger < StandardError; end
	class PlayerMustBeUnique < StandardError; end
	class PlayerNotExists < StandardError; end
end
