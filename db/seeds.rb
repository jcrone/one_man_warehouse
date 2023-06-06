# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Phrase.destroy_all
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

if Rails.env.development?
  200.times do 
    Inventory.create!(                                                     
      upc: "043475724248",                                                                                                  
      asin: "B09L7F899D",                                                 
      description: "Danskin Women's Super Soft 7/8 Legging with Pockets (Black Camo Print, Small)",
      location_id: 1,                                                     
      brand: "Danskin",
      photo_link: "https://m.media-amazon.com/images/I/316OfXQ1UcL._SL75_.jpg",
      qty: 4,
      marketplace: "amazon",
      box_id: 4,
      active: "NOT-LISTED"

    )

    
  end 
end