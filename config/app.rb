DB = Sequel.connect(YAML.load(File.read('./config/database.yml'))[ENV['RACK_ENV']])
