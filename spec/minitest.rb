require 'minitest/spec'
require 'minitest/autorun'
require_relative '../lib/projekt'
require 'sequel'
require 'sqlite3'
require 'csv'

class Minitest::Test
  	def self.test_order
   		:alpha
  	end
end

class TestProjekt < Minitest::Test

  describe "Projekt" do

	query = SQL.new


	it "prawdzenie czy baza danych istnieje zwrot ok" do
		assert (query.create_db) == "ok"
      	end

	it "sprawdzenie czy baza danych istnieje" do
		assert (File.exist?('resources/test_database.db')) == true
      	end

	it "sprawdzenie czy insert poszedl" do
		assert (query.insert_przykladowe_rekordy) == "ok"
      	end

	it "czy akcja wyswietlenia sie pokazala" do
		assert(query.pokaz) == "-------------------------------"
	end

	it "sprawdzenie pustego rekordu" do
		assert (query.sprawdzenie_puste) == []
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=3 ale nie ma takiego ucznia" do
		assert_raises (ArgumentError) {query.srednia_ocena(3)}
		#expect(query.srednia_ocena(3)).to eq([{:srednia=>5.0}])
	end

	it "srednia ogolna ucznia o id=1 powinna rownac sie 5.0" do
		assert (query.srednia_ocena(1)) == [{:srednia=>4.166666666666667}]
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=1 nie powinna sie rownac 3.0" do
		assert (query.srednia_ocena(1)) != [{:srednia=>3.0}]
      	end

	it "srednia ogolna ucznia o id=2 powinna rownac sie 3.6666666666666665" do
		assert (query.srednia_ocena(2)) == [{:srednia=>3.6666666666666665}]
      	end

	it "NEGATYWNY srednia ogolna ucznia o id=3 z przedmiotu j.polski ale nie ma takiego ucznia" do
		assert_raises (ArgumentError) {query.srednia_ocena_zprzedmiotu(3,1)}
	end

	it "NEGATYWNY srednia ogolna ucznia o id=1 z przedmiotu ktorego nie ma w bazie" do
		assert_raises (ArgumentError) {query.srednia_ocena_zprzedmiotu(1,5)}
	end

	it "srednia ogolna ucznia o id=1 z przedmiotu j.polski" do
		assert (query.srednia_ocena_zprzedmiotu(1,1)) == [{:srednia=>5.0}]
	end

	it "dodaj ucznia o numerze 3" do
		test = Uczen.new(3, "Zenon", "Zenkowski")
		query.dodaj(test)
		assert (query.select('uczniowie',3)) == [{:id_uczniowie=>3, :imie=>"Zenon", :nazwisko=>"Zenkowski"}]
	end

	it "dodaj przedmiot Angielski do ucznia numer 1" do
		test = Przedmiot.new(2, "Angielski")
		query.dodaj(test)
		query.dodaj_przedmiot(1, 2)
		assert (query.sprawdzenie(2,1)) == [{:id_przedmiot=>2, :id_uczniowie=>1}]
	end

	it "dodaj ocene 6.0 z Angielskiego dla ucznia numer 1" do
		test = Ocena.new(10, 6, 1, 2)
		query.dodaj(test)
		assert (query.select('oceny',10)) == [{:id_oceny=>10, :id_przedmiot=>2, :id_uczniowie=>1, :ocena=>6}]
	end

	it "update ucznia o imieniu Zenon zmieniamy imie na Henryk" do
		query.update('uczniowie', 'imie', 'Henryk', 'imie', 'Zenon')
		assert (query.select('uczniowie',3)) == [{:id_uczniowie=>3, :imie=>"Henryk", :nazwisko=>"Zenkowski"}]
	end

	it "update przedmiotu" do
		query.update('przedmiot', 'nazwa', 'Niemiecki', 'id_przedmiot', 1)
		assert (query.select('przedmiot',1)) == [{:id_przedmiot=>1, :nazwa=>"Niemiecki"}]
	end

	it "update oceny o id=4 na ocene wynoszaca 5.0 " do
		query.update('oceny', 'ocena', 5, 'id_oceny', 4)
		assert (query.select('oceny',4)) == [{:id_oceny=>4, :id_przedmiot=>1, :id_uczniowie=>2, :ocena=>5}]
	end

	it "NEGATYWNY update oceny o id=4 na ocene wynoszaca 8.0 " do
		assert_raises (ArgumentError) {query.update('oceny', 'ocena', 8, 'id_oceny', 4)}
	end

	it "NEGATYWNY update oceny o id=4 na ocene wynoszaca -1.0 " do
		assert_raises (ArgumentError) {query.update('oceny', 'ocena', -1, 'id_oceny', 4)}
	end

	it "NEGATYWNY nie ma takiego ucznia Zeks" do
		assert_raises (ArgumentError) {query.update('uczniowie', 'imie', 'Henryk', 'imie', 'Zeks')}
	end

	it "NEGATYWNY nie ma takiej oceny" do
		assert_raises (ArgumentError) {query.update('oceny', 'ocena', 3, 'id_oceny', 123)}
	end

	it "NEGATYWNY nie mozna oceny -1 do nieistniejacej oceny wstawic" do
		assert_raises (ArgumentError) {query.update('oceny', 'ocena', -1, 'id_oceny', 123)}
	end

	it "usuwanie ucznia o imieniu Henryk" do
		query.delete('uczniowie', 'imie', 'Henryk')
		assert (query.select('uczniowie',3)) == []
	end

	it "usuwanie oceny" do
		query.delete('oceny', 'id_oceny', 1)
		assert (query.select('oceny',1)) ==([])
	end

	it "usuwanie przedmiotu sprawdzamy czy usuwanie kaskadowe dziala" do
		query.delete('przedmiot', 'id_przedmiot', 1)
		assert (query.select('przedmiot',1)) == ([])
	end

	it "NEGATYWNY usuwanie przedmiotu ktory nie istnieje" do
		assert_raises (ArgumentError) {query.delete('przedmiot', 'id_przedmiot', 222)}
	end

	it "NEGATYWNY usuwanie ucznia ktory nie istnieje" do
		assert_raises (ArgumentError) {query.delete('uczniowie', 'imie', 'Hugh')}
	end

	it "NEGATYWNY usuwanie przedmiotu ktory nie istnieje" do
		assert_raises (ArgumentError) {query.delete('przedmiot', 'nazwa', 'magia')}
	end



	it "5. eksport uczniow" do
		query.eksport_uczniowie
		assert (File.exist?('resources/uczniowie.csv')) == true
	end

	it "eksport uczniow nie pusty" do
		assert (File.read("resources/uczniowie.csv")) != nil
	end

	it "eksport oceny" do
		query.eksport_oceny
		assert (File.exist?('resources/oceny.csv')) == true
	end

	it "eksport ocen nie pusty" do
		assert (File.read("resources/oceny.csv")) != nil
	end


	it "eksport przedmioty" do
		query.eksport_przedmioty
		assert (File.exist?('resources/przedmioty.csv')) == true
	end

	it "eksport przedmiot nie pusty" do
		assert (File.read("resources/przedmioty.csv")) != nil
	end

	it "eksport uwagi" do
		query.eksport_uwagi
		assert (File.exist?('resources/uwagi.csv')) == true
	end

	it "eksport uwag nie pusty" do
		assert (File.read("resources/uwagi.csv")) != nil
	end


	it "test importu uczniow" do
        query.import_uczniowie('resources/uczniowieImport.csv')
		assert (query.select('uczniowie',4)) == ([{:id_uczniowie=>4, :imie=>"Szczepan", :nazwisko=>"Sghilk"}])
		assert (query.select('uczniowie',5)) == ([{:id_uczniowie=>5, :imie=>"Pokol", :nazwisko=>"Potop"}])
    	end

	it "test importu przedmiotow" do
        query.import_przedmiotu('resources/przedmioty.csv')
		assert (query.select('przedmiot', 9)) == ([{:id_przedmiot=>9, :nazwa=>"Testowanie Aplikacji Ruby"}])
	end

	it "test importu ocen" do
        query.import_oceny('resources/ocenyInsert.csv')
		assert (query.select('oceny',20)) == ([{:id_oceny=>20, :id_przedmiot=>9, :id_uczniowie=>5, :ocena=>6}])
	end

	it "test importu uwag" do
        query.import_uwagi('resources/uwagiInsert.csv')
		assert (query.select('uwagi', 9)) == ([{:id_uwagi=>9, :nazwa=>"test", :id_uczniowie=>1}])
	end

    it "test metod pokaz" do
        assert_output() {query.pokaz_uczniow}
    end

    it "test pokaz_oceny" do
        assert_output() { query.pokaz_oceny }
    end

    it "test specjalnego select" do
        assert(query.select_specjalny('uwagi', 'uwagi', 1)) == ([{:id_uwagi=>1, :nazwa=>"brak zeszytu", :id_uczniowie=>1}])
    end

    it "test importu uczniow dla blednego pliku" do
          query.import_uczniowie('resources/uczniowie.txt')
  		assert (query.select('uczniowie',21)) == ([])
      	end

  	it "test importu przedmiotow z blednymi danymi (int)" do
          query.import_przedmiotu('resources/przedmiot.csv')
  		assert (query.select('przedmiot', 20)) == ([])
  	end

  	it "test importu ucznia z blednymi danymi (String)" do
          query.import_oceny('resources/ucz.csv')
  		assert (query.select('uczniowie',20)) == ([])
  	end

    it "test sprawdzania podanej tabeli" do
  		query.delete('ooooooceny', 'id_oceny', 9)
  		assert (query.select('oceny',9)) ==([:id_oceny=> 9, :ocena=>4, :id_uczniowie=>1, :id_przedmiot=>3])
  	end


	it "czyszczenie" do
		query.wyczysc
		a=1
		assert (File.exist?("test_database.db")) == false
	end
  end
end
