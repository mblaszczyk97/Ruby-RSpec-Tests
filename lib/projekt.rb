require 'sequel'
require 'sqlite3'
require 'csv'

class SQL


	def create_db
        	@DB = Sequel.sqlite('resources/test_database.db')
		#DB.drop_table?(:uczniowie)
		#DB.drop_table?(:oceny)
		@DB.create_table(:uczniowie) do
     			primary_key :id_uczniowie, unique: true
     			String :imie
			String :nazwisko
 		end

		@DB.create_table(:przedmiot) do
     			primary_key :id_przedmiot
     			String :nazwa
			#foreign_key :id_uczniowie, :uczniowie, on_delete: :cascade
 		end

		@DB.create_table(:uczniowie_przedmiot) do
			foreign_key :id_uczniowie, :uczniowie, on_delete: :cascade
			foreign_key :id_przedmiot, :przedmiot, on_delete: :cascade
 		end

		@DB.create_table(:oceny) do
     			primary_key :id_oceny
     			Int :ocena
			foreign_key :id_uczniowie, :uczniowie, on_delete: :cascade
			foreign_key :id_przedmiot, :przedmiot, on_delete: :cascade
 		end

		@DB.create_table(:uwagi) do
     			primary_key :id_uwagi
     			String :nazwa
			foreign_key :id_uczniowie, :uczniowie, on_delete: :cascade
 		end
		return 'ok'

	end

	def wyczysc
		File.delete("resources/test_database.db")
		File.delete("resources/uczniowie.csv")
		File.delete("resources/oceny.csv")
		File.delete("resources/przedmioty.csv")
		File.delete('resources/uwagi.csv')
	end

	def insert_przykladowe_rekordy

		@DB[:uczniowie].insert(:id_uczniowie => 1, :imie => 'Zbigniew', :nazwisko => 'Krasicki')
		@DB[:uczniowie].insert(:id_uczniowie => 2, :imie => 'Stefan', :nazwisko => 'Konkol')

		@DB[:przedmiot].insert(:id_przedmiot => 1, :nazwa => 'Polski')
		@DB[:przedmiot].insert(:id_przedmiot => 3, :nazwa => 'Matematyka')

		@DB[:uczniowie_przedmiot].insert(:id_uczniowie => 1, :id_przedmiot => 1)
		@DB[:uczniowie_przedmiot].insert(:id_uczniowie => 2, :id_przedmiot => 1)
		@DB[:uczniowie_przedmiot].insert(:id_uczniowie => 1, :id_przedmiot => 3)

		@DB[:oceny].insert(:id_oceny => 1, :ocena => 5, :id_uczniowie => 1, :id_przedmiot => 1)
		@DB[:oceny].insert(:id_oceny => 2, :ocena => 4, :id_uczniowie => 1, :id_przedmiot => 1)
		@DB[:oceny].insert(:id_oceny => 3, :ocena => 6, :id_uczniowie => 1, :id_przedmiot => 1)

		@DB[:oceny].insert(:id_oceny => 7, :ocena => 3, :id_uczniowie => 1, :id_przedmiot => 3)	
		@DB[:oceny].insert(:id_oceny => 8, :ocena => 3, :id_uczniowie => 1, :id_przedmiot => 3)
		@DB[:oceny].insert(:id_oceny => 9, :ocena => 4, :id_uczniowie => 1, :id_przedmiot => 3)

		@DB[:oceny].insert(:id_oceny => 4, :ocena => 3, :id_uczniowie => 2, :id_przedmiot => 1)
		@DB[:oceny].insert(:id_oceny => 5, :ocena => 3, :id_uczniowie => 2, :id_przedmiot => 1)
		@DB[:oceny].insert(:id_oceny => 6, :ocena => 5, :id_uczniowie => 2, :id_przedmiot => 1)

		@DB[:uwagi].insert(:id_uwagi => 1, :nazwa => 'brak zeszytu', :id_uczniowie => 1)
		return 'ok'
	end
    
    def testTabela tabela
        if ["oceny", "uwagi", "uczniowie", "przedmiot", "uczniowie_przedmiot"].include? tabela
            return true
        end
        puts "podano bledna nazwe tabeli"
        return false
    end

	def select(tabela, id)
        if testTabela(tabela)
		ary = Array.new
		ary = @DB.fetch("SELECT * FROM #{tabela} WHERE id_#{tabela}=#{id}").to_a
		p ary
        end
	end

	def select_specjalny(tabela, encja, id)
        if testTabela(tabela)
		ary = Array.new
		ary = @DB.fetch("SELECT * FROM #{tabela} WHERE id_#{encja}=#{id}").to_a
		p ary
        end
	end


	def pokaz
		ary = Array.new
		#p @DB[:uczniowie].all
 		#p @DB[:oceny].all
		ary = @DB.fetch("SELECT uczniowie.id_uczniowie, avg(ocena) FROM uczniowie LEFT JOIN oceny ON oceny.id_uczniowie = uczniowie.id_uczniowie WHERE uczniowie.id_uczniowie=1").to_a
                p ary
		p "-------------------------------"
	end

	def srednia_ocena(id_ucznia)
		ary = Array.new
		ary = @DB.fetch("SELECT avg(ocena) AS srednia FROM uczniowie LEFT JOIN oceny ON oceny.id_uczniowie = uczniowie.id_uczniowie WHERE uczniowie.id_uczniowie=#{id_ucznia}").to_a
		if ary==[{:srednia=>nil}]
			raise ArgumentError
		else
			puts "srednia calosciowa ucznia o numerze dziennika #{id_ucznia}"
			p ary
		end
	end

	def sprawdzenie_puste
		ary = Array.new
		ary = @DB.fetch("SELECT id_uczniowie FROM uczniowie WHERE id_uczniowie=3").to_a
		p ary
	end

	def srednia_ocena_zprzedmiotu(id_ucznia, przedmiot)
		ary = Array.new
		ary = @DB.fetch("SELECT avg(ocena) AS srednia FROM uczniowie LEFT JOIN oceny ON oceny.id_uczniowie = uczniowie.id_uczniowie WHERE uczniowie.id_uczniowie=#{id_ucznia} AND oceny.id_przedmiot=#{przedmiot}").to_a
		if ary==[{:srednia=>nil}]
			raise ArgumentError
		else

			parry = @DB.fetch("SELECT nazwa FROM przedmiot WHERE id_przedmiot=#{przedmiot}").to_a

			puts "srednia z ucznia o numerze dziennika #{id_ucznia} z przedmiotu #{parry}"
			p ary
		end
	end

	def dodaj(obiekt)
		@DB.run "INSERT INTO #{obiekt.getTab} VALUES (#{obiekt.insert})"
	end

	def dodaj_przedmiot(id_uczen, id_przedmiotu)
		@DB.run "INSERT INTO uczniowie_przedmiot VALUES (#{id_uczen}, #{id_przedmiotu})"
	end

	def update(tabela, setter, value, gdzie_zmieniamy, naco_zmieniamy)
        if testTabela(tabela)
		if setter=='ocena' && value.to_i>6 || setter=='ocena' && value.to_i<1
			raise ArgumentError
		else
		ary = Array.new
		ary = @DB.fetch("SELECT #{gdzie_zmieniamy} FROM #{tabela} WHERE #{gdzie_zmieniamy}='#{naco_zmieniamy}'").to_a
		if ary==[]
			raise ArgumentError
		end


        	@DB.run "UPDATE #{tabela} SET #{setter} = '#{value}' WHERE #{gdzie_zmieniamy} LIKE '#{naco_zmieniamy}'"
        	puts "Zmieniono rekord w tabeli: #{tabela}, #{ary}."
		p "-------------------------------"
		end
        end
    	end

	def delete(tabela, gdzie, who)
        if testTabela(tabela)
		ary = Array.new
		ary=@DB.fetch("SELECT #{gdzie} FROM #{tabela} WHERE #{gdzie}='#{who}'").to_a
		if ary==[]
			raise ArgumentError
		end
        	@DB.run "DELETE FROM #{tabela} WHERE #{gdzie} == '#{who}'"
        	puts "Usunieto #{who} z bazy."

        end
    	end

	def pokaz_uczniow

		p @DB[:uczniowie].all

	end

	def pokaz_oceny

		p @DB[:oceny].all
		p "-------------------------------"

	end

	def eksport_uczniowie
		File.open('resources/uczniowie.csv', 'w'){|f|
  			@DB[:uczniowie].each{|data|
    				f << data.values.to_csv(:col_sep=>';')
  			}
		}
	end

	def eksport_oceny
		File.open('resources/oceny.csv', 'w'){|f|
  			@DB[:oceny].each{|data|
    				f << data.values.to_csv(:col_sep=>';')
  			}
		}
	end

	def eksport_przedmioty
		File.open('resources/przedmioty.csv', 'w'){|f|
  			@DB[:przedmiot].each{|data|
    				f << data.values.to_csv(:col_sep=>';')
  			}
		}
	end

	def eksport_uwagi
		File.open('resources/uwagi.csv', 'w'){|f|
  			@DB[:uwagi].each{|data|
    				f << data.values.to_csv(:col_sep=>';')
  			}
		}
	end

    def testInt x
        if x.scan(/\D/).empty?
            return true
        end
        puts "bledna wartosc " + x.to_s
        return false
    end

        def testString x
                if x.match(/^[[:alpha:][:blank:]]+\z/) != nil
                    return true
                end
            puts "bledna wartosc " + x
            return false
        end

	def import_uczniowie adres
        if testCsv(adres)
		CSV.foreach(adres, headers: false) do |row|
			tmp = row[0].split(";")
            if testInt(tmp[0]) && testString(tmp[1]) && testString(tmp[2])
			uczen = Uczen.new(tmp[0], tmp[1], tmp[2])
			dodaj(uczen)
            end
		end
        end
	end

	def import_oceny adres
        if testCsv(adres)
		CSV.foreach(adres, headers: false) do |row|
			tmp = row[0].split(";")
            if testInt(tmp[0]) && testInt(tmp[1]) && testInt(tmp[2]) && testInt(tmp[3])
			ocena = Ocena.new(tmp[0], tmp[1], tmp[2], tmp[3])
			dodaj(ocena)
            end
		end
        end
	end

	def import_przedmiot adres
       if testCsv(adres)
		CSV.foreach(adres, headers: false) do |row|
			tmp = row[0].split(";")
            if testInt(tmp[0]) && testString(tmp[1])
			przedmiot = Przedmiot.new(tmp[0], tmp[1])
			dodaj(przedmiot)
            end
		end
       end
	end

	def import_uwag adres
        if testCsv(adres)
		CSV.foreach(adres, headers: false) do |row|
			tmp = row[0].split(";")
            if testInt(tmp[0])  && testInt(tmp[2])
			@DB.run "INSERT INTO uwagi VALUES (#{tmp[0].to_i}, '#{tmp[1]}', #{tmp[2].to_i})"
            end
        end
        end
	end

    def testCsv x
        if x.end_with? ".csv"
            if File.exist?(x)
                return true
            end
        end
        puts "podany plik nie spełnia wymagań"
        return false
    end

	def sprawdzenie(id_przedmiot, id_uczen)
		ary = @DB.fetch("SELECT id_przedmiot, id_uczniowie FROM uczniowie_przedmiot WHERE id_uczniowie=#{id_uczen} AND id_przedmiot=#{id_przedmiot}").to_a
		p ary
	end

end

class Uczen
	@id
	@imie
	@nazwisko
	@@tab = "uczniowie"

	def initialize(id, imie, nazwisko)
		@id = id
		@imie = imie
		@nazwisko = nazwisko
	end

	def getTab
		@@tab
	end

	def insert
		tmp = @id.to_s
		tmp += ", '#{@imie}', '#{@nazwisko}'"
		return tmp
	end
end

class Ocena
	@@tab = "oceny"
	@id
	@ocena
	@id_uczen
	@id_przedmiot

	def initialize(id, o, u, p)
		@id = id
		@ocena = o
		@id_uczen = u
		@id_przedmiot = p
 	end


	def getTab
		@@tab
	end

	def insert
			tmp = @id.to_s
		tmp += ", #{@ocena.to_s}, #{@id_uczen.to_s}, #{@id_przedmiot.to_s}"
		return tmp
	end
end

class Przedmiot
	@@tab = "przedmiot"
	@id
	@nazwa
	@uczen

	def initialize(id, n)
		@id = id
		@nazwa = n
	end

	def getTab
		@@tab
	end

	def insert
		tmp = "#{@id.to_s}, '#{@nazwa}'"
		return tmp
	end
end


query = SQL.new
query.create_db
query.insert_przykladowe_rekordy
query.select('uczniowie', 1)
query.srednia_ocena(1)
query.srednia_ocena(2)
query.srednia_ocena_zprzedmiotu(1, 1)
query.srednia_ocena_zprzedmiotu(1, 3)
query.dodaj_przedmiot(2, 3)
query.sprawdzenie(3,2)

File.delete("resources/test_database.db")
