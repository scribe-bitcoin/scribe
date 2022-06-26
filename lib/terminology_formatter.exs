defmodule BitcoinTerms do
	use Witchcraft.Applicative

	def get_lines(path) do
		path
		|> File.read!()
		|> String.split("\n")
	end

	def augment(line) do
		words = String.split(line, ",")
		[ &(&1), &capitalize/1, &String.upcase/1] |> ap(words)
	end

	def capitalize(word) do
		split_ct = word |> String.split() |> Enum.count()
		cond do
			split_ct > 1 -> capitalize_compound(word)
			true -> String.capitalize(word)
		end
	end

	defp capitalize_compound(word) do
		word
		|> String.split() 
		|> convey([&String.capitalize/1])
		|> Enum.join(" ")
	end

	def run(csv_path) do
		str = csv_path
			|> get_lines() 
			|> Enum.map(&augment/1)
			|> List.flatten()
			|> Enum.join(",")

		File.write("bitcoin_terminology_clean.csv", str)
	end

end

BitcoinTerms.run("bitcoin_terminology.csv")
