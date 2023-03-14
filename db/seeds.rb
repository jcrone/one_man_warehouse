# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

@todo_phrases = [
    "Your on fire Bitch!",
    "KA POW Mother Fucker! ",
    "One Man Warehouse My ASS!!",
    "Noice!!",
    "Damn Girl your on fire!",
    "Holly Buttholes!!",
    "Shit yay!",
    "Fuck Yay!",
    "Weed Lunch box!",
    "Complete that Shit!",
    "Da fuq!",
    "RAAAAAAAAAAAACCCCCCCCCCCCCCCCCCCHHHHHHHHHHHHHEEEEEEELLLLLLLLLLLLLL!!!! ",
    "5 Stars! YAS ",
    "Kicking Ass and something something something!!",
    "Roundhouse it!! ",
    "SEND IT!!!",
    "SEND IT!!!!"
  ]

@todo_phrases.each do |todo_phrase|
    Phrase.create phrase: todo_phrase,
                    category: "todo"
end
