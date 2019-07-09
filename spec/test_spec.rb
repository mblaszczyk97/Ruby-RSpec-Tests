require_relative '../lib/projekt'
require 'sequel'
require 'sqlite3'
require 'csv'

describe 'SQL' do

		query = SQL.new

	it "sprawdzenie czy baza danych istnieje" do
		expect(query.create_db).to eq('ok')
      	end

	it "sprawdzenie czy baza danych istnieje" do
		expect(File.exist?('resources/test_database.db')).to be true
      	end

	it "sprawdzenie czy insert poszedl" do
		expect(query.insert_przykladowe_rekordy).to eq('ok')
      	end

	it "czy akcja wyswietlenia sie pokazala" do
		expect(query.pokaz).to eq("-------------------------------")
	end

	it "sprawdzenie pustego rekordu" do
		expect(query.sprawdzenie_puste).to eq([])
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=3 ale nie ma takiego ucznia" do
		expect{query.srednia_ocena(3)}.to raise_error(ArgumentError)
		#expect(query.srednia_ocena(3)).to eq([{:srednia=>5.0}])
	end

	it "srednia ogolna ucznia o id=1 powinna rownac sie 5.0" do
		expect(query.srednia_ocena(1)).to eq([{:srednia=>4.166666666666667}])
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=1 nie powinna sie rownac 3.0" do
		expect(query.srednia_ocena(1)).not_to eq([{:srednia=>3.0}])
      	end


      	it "srednia ogolna ucznia o id=2 powinna rownac sie 3.6666666666666665" do
		expect(query.srednia_ocena(2)).to eq([{:srednia=>3.6666666666666665}])
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=3 z przedmiotu j.polski ale nie ma takiego ucznia" do
		expect{query.srednia_ocena_zprzedmiotu(3,1)}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY srednia ogolna ucznia o id=1 z przedmiotu ktorego nie ma w bazie" do
		expect{query.srednia_ocena_zprzedmiotu(1,5)}.to raise_error(ArgumentError)
	end

	it "srednia ogolna ucznia o id=1 z przedmiotu j.polski" do
		expect(query.srednia_ocena_zprzedmiotu(1,1)).to eq([{:srednia=>5.0}])
	end

	it "dodaj ucznia o numerze 3" do
		test = Uczen.new(3, "Zenon", "Zenkowski")
		query.dodaj(test)
		expect(query.select('uczniowie',3)).to eq([{:id_uczniowie=>3, :imie=>"Zenon", :nazwisko=>"Zenkowski"}])
	end

	it "dodaj przedmiot Angielski do ucznia numer 1" do
		test = Przedmiot.new(2, "Angielski")
		query.dodaj(test)
		query.dodaj_przedmiot(1, 2)
		expect(query.sprawdzenie(2,1)).to eq([{:id_przedmiot=>2, :id_uczniowie=>1}])

	end

	it "dodaj ocene 6.0 z Angielskiego dla ucznia numer 1" do
		test = Ocena.new(10, 6, 1, 2)
		query.dodaj(test)
		expect(query.select('oceny',10)).to eq([{:id_oceny=>10, :id_przedmiot=>2, :id_uczniowie=>1, :ocena=>6}])
	end

	it "update ucznia o imieniu Zenon zmieniamy imie na Henryk" do
		query.update('uczniowie', 'imie', 'Henryk', 'imie', 'Zenon')
		expect(query.select('uczniowie',3)).to eq([{:id_uczniowie=>3, :imie=>"Henryk", :nazwisko=>"Zenkowski"}])
	end

	it "update przedmiotu" do
		query.update('przedmiot', 'nazwa', 'Niemiecki', 'id_przedmiot', 1)
		expect(query.select('przedmiot',1)).to eq([{:id_przedmiot=>1, :nazwa=>"Niemiecki"}])
	end

	it "update oceny o id=4 na ocene wynoszaca 5.0 " do
		query.update('oceny', 'ocena', 5, 'id_oceny', 4)
		expect(query.select('oceny',4)).to eq([{:id_oceny=>4, :id_przedmiot=>1, :id_uczniowie=>2, :ocena=>5}])
	end

	it "NEGATYWNY update oceny o id=4 na ocene wynoszaca 8.0 " do
		expect{query.update('oceny', 'ocena', 8, 'id_oceny', 4)}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY update oceny o id=4 na ocene wynoszaca -1.0 " do
		expect{query.update('oceny', 'ocena', -1, 'id_oceny', 4)}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY nie ma takiego ucznia Zeks" do
		expect{query.update('uczniowie', 'imie', 'Henryk', 'imie', 'Zeks')}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY nie ma takiej oceny" do
		expect{query.update('oceny', 'ocena', 3, 'id_oceny', 123)}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY nie mozna oceny -1 do nieistniejacej oceny wstawic" do
		expect{query.update('oceny', 'ocena', -1, 'id_oceny', 123)}.to raise_error(ArgumentError)
	end

	it "usuwanie ucznia o imieniu Henryk" do
		query.delete('uczniowie', 'imie', 'Henryk')
		expect(query.select('uczniowie',3)).to eq([])
	end

	it "usuwanie oceny" do
		query.delete('oceny', 'id_oceny', 1)
		expect(query.select('oceny',1)).to eq([])
	end

	it "usuwanie przedmiotu sprawdzamy czy usuwanie kaskadowe dziala" do
		query.delete('przedmiot', 'id_przedmiot', 1)
		expect(query.select('przedmiot',1)).to eq([])
	end

	it "NEGATYWNY usuwanie przedmiotu ktory nie istnieje" do
		expect{query.delete('przedmiot', 'id_przedmiot', 222)}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY usuwanie ucznia ktory nie istnieje" do
		expect{query.delete('uczniowie', 'imie', 'Hugh')}.to raise_error(ArgumentError)
	end

	it "NEGATYWNY usuwanie przedmiotu ktory nie istnieje" do
		expect{query.delete('przedmiot', 'nazwa', 'magia')}.to raise_error(ArgumentError)
	end


	it "eksport uczniow" do
		query.eksport_uczniowie
		expect(File.exist?('resources/uczniowie.csv')).to be true
	end

	it "eksport uczniow nie pusty" do
		expect(File.read("resources/uczniowie.csv")).not_to eq(nil)
	end


	it "eksport oceny" do
		query.eksport_oceny
		expect(File.exist?('resources/oceny.csv')).to be true
	end

	it "eksport ocen nie pusty" do
		expect(File.read("resources/oceny.csv")).not_to eq(nil)
	end


	it "eksport przedmioty" do
		query.eksport_przedmioty
		expect(File.exist?('resources/przedmioty.csv')).to be true
	end

	it "eksport przedmiot nie pusty" do
		expect(File.read("resources/przedmioty.csv")).not_to eq(nil)
	end

	it "eksport uwagi" do
		query.eksport_uwagi
		expect(File.exist?('resources/uwagi.csv')).to be true
	end

	it "eksport uwag nie pusty" do
		expect(File.read("resources/uwagi.csv")).not_to eq(nil)
	end


    	it "ttest importu uczniow" do
        	query.import_uczniowie('resources/uczniowieImport.csv')
		expect(query.select('uczniowie',4)).to eq([{:id_uczniowie=>4, :imie=>"Szczepan", :nazwisko=>"Sghilk"}])
		expect(query.select('uczniowie',5)).to eq([{:id_uczniowie=>5, :imie=>"Pokol", :nazwisko=>"Potop"}])
    	end

	it "ttest importu przedmiotow" do
		query.import_przedmiot('resources/przedmiotyInsert.csv')
		expect(query.select('przedmiot', 9)).to eq([{:id_przedmiot=>9, :nazwa=>"Testowanie Aplikacji Ruby"}])
	end

	it "ttest importu ocen" do
		query.import_oceny('resources/ocenyInsert.csv')
		expect(query.select('oceny',20)).to eq([{:id_oceny=>20, :id_przedmiot=>9, :id_uczniowie=>5, :ocena=>6}])
	end

	it "test importu uwag" do
		query.import_uwag('resources/uwagiInsert.csv')
		expect(query.select('uwagi', 9)).to eq([{:id_uwagi=>9, :nazwa=>"test", :id_uczniowie=>1}])
	end

    it "test metody pokaz_uczniow" do
        expect {query.pokaz_uczniow }.to output().to_stdout
    end

		it 'test czy metoda pokaz_oceny pisze na stdout' do
		expect {query.pokaz_oceny }.to output().to_stdout
	end

	it ' test specjalnego select' do
		expect(query.select_specjalny('uwagi', 'uwagi', 1)).to eq([{:id_uwagi=>1, :nazwa=>"brak zeszytu", :id_uczniowie=>1}])
	end


	it "test importu uczniow dla blednego pliku" do
			query.import_uczniowie('resources/uczniowie.txt')
expect(query.select('uczniowie',21)).to eq([])
	end

it "test importu przedmiotow z blednymi danymi (int)" do
query.import_przedmiot('resources/przedmiot.csv')
expect(query.select('przedmiot', 20)).to eq([])
end

it "test importu ucznia z blednymi danymi (string)" do
query.import_uwag('resources/ucz.csv')
expect(query.select('uczniowie', 20)).to eq([])
end

it "test metody pokaz_uczniow" do
		expect {query.pokaz_uczniow }.to output().to_stdout
end

it "test sprawdzenia nazwy tabeli" do
	query.delete('ooooceny', 'id_oceny', 9)
	expect(query.select('oceny',9)).to eq([:id_oceny=> 9, :ocena=>4, :id_uczniowie=>1, :id_przedmiot=>3])
end


	it "czyszczenie" do
		query.wyczysc
		a=1
		expect(File.exist?("resources/test_database.db")).to be false
	end

end
