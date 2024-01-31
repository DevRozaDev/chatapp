# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ChatApp.Repo.insert!(%ChatApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

categories = [
  # Filmy
  %ChatApp.Chat.Category{name: "Movies"},
  # Gry
  %ChatApp.Chat.Category{name: "Games"},
  # Technologia
  %ChatApp.Chat.Category{name: "Technology"},
  # Zwierzęta
  %ChatApp.Chat.Category{name: "Animals"},
  # Zagadki
  %ChatApp.Chat.Category{name: "Riddles"},
  # Kryptowaluta
  %ChatApp.Chat.Category{name: "Cryptocurrency"}
]

for category <- categories do
  ChatApp.Repo.insert!(category)
end
