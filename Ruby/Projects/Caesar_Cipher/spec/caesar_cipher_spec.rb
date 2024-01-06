require './lib/caesar_cipher'

describe "caesar_cipher" do
	it "returns same string with no arg" do
		expect(caesar_cipher("lol")).to eql("lol")
	end

	it "keeps casing" do
		expect(caesar_cipher("AbCdEf", 1)).to eql("BcDeFg")
	end

	it "ignores other characters" do
		expect(caesar_cipher("What a string!", 5)).to eql("Bmfy f xywnsl!")
	end

	it "returns empty string if passed an empty string" do
		expect(caesar_cipher("", 3)).to eql("")
	end

	it "wraps from z to a" do
		expect(caesar_cipher("z", 1)).to eql("a")
	end

	it "works with negative shifts" do
		expect(caesar_cipher("No, this is Patrick!", -4)).to eql("Jk, pdeo eo Lwpneyg!")
	end
end