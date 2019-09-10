require 'yaml'

module Saving
    def show_saves
        puts Dir.glob('saves/*.yaml').map {|fname| fname.match(/^saves\/(\w+)\.yaml$/)[1] }.join("\n")
    end

    def select_save
        print "Select a savegame to load: "
        filename = ""
        loop do
            filename = gets.chomp
            if File.exists?("saves/#{filename}.yaml")
                break
            else
                print "Invalid filename, try again:"
            end
        end
        "saves/#{filename}.yaml"
    end

    def get_filename
        print "Choose a name for your savegame:"
        name = gets.chomp.strip
        name
    end

    def save(filename)
        begin
            Dir.mkdir("saves") unless File.exists?"saves"
            File.open("saves/#{filename}.yaml", "w") {|file| file.puts self.to_yaml}
            puts "Game saved as #{filename}!"
        rescue
            puts "Error saving file"
        end
    end

    def load_from_file(filename)
        data = File.open(filename, "r").read
        load_from_yaml(data)
    end
end