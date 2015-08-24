require 'pg'
require 'faker'
require 'pry'

TITLES = ["Roasted Brussels Sprouts",
  "Fresh Brussels Sprouts Soup",
  "Brussels Sprouts with Toasted Breadcrumbs, Parmesan, and Lemon",
  "Cheesy Maple Roasted Brussels Sprouts and Broccoli with Dried Cherries",
  "Hot Cheesy Roasted Brussels Sprout Dip",
  "Pomegranate Roasted Brussels Sprouts with Red Grapes and Farro",
  "Roasted Brussels Sprout and Red Potato Salad",
  "Smoky Buttered Brussels Sprouts",
  "Sweet and Spicy Roasted Brussels Sprouts",
  "Smoky Buttered Brussels Sprouts",
  "Brussels Sprouts and Egg Salad with Hazelnuts"]

#WRITE CODE TO SEED YOUR DATABASE AND TABLES HERE

def db_connection
  begin
    connection = PG.connect(dbname: "brussels_sprouts_recipes")
    yield(connection)
  ensure
    connection.close
  end
end

#CREATES TABLES
db_connection do |conn|
  conn.exec_params("DROP TABLE IF EXISTS recipes;")
  conn.exec_params("DROP TABLE IF EXISTS comments;")
  conn.exec_params("CREATE TABLE recipes (recipe_id int, recipe varchar(250))")
  conn.exec_params("CREATE TABLE comments (recipe_id int,comment varchar(250))")
  # conn.exec_params("CREATE SEQUENCE recipe_id
  #     START WITH 1
  #     INCREMENT BY 1
  #     NO MINVALUE
  #     NO MAXVALUE
  #     CACHE 1;")

end


#SEEDS THE TABLES WITH FAKE DATA

db_connection do |conn|
  @count = 1
  TITLES.each do |name|
    conn.exec("INSERT INTO recipes (recipe, recipe_id) VALUES ('#{name}', '#{@count}');")
    @count += 1
  end

  10.times do
    random_text = Faker::Lorem.sentence
    comments ="INSERT INTO comments (comment, recipe_id) VALUES ('#{random_text}','#{rand(0..11)}' );"
    conn.exec(comments)
  end
end

#Associate the tables by recipe_id.
db_connection do |conn|
  conn.exec("SELECT * FROM recipes
  INNER JOIN comments ON recipes.recipe_id = comments.recipe_id;")
end

puts "How many recipes are there in total?"
db_connection do |conn|
  recipes_count = conn.exec("SELECT count(comment) FROM comments;")
  puts recipes_count[0].values
end
puts

puts "How many comments are there in total?"
db_connection do |conn|
  comments_count = conn.exec("SELECT count(recipe) FROM recipes;")
  puts comments_count[0].values
end
puts

puts "How would you find out how many comments each of the recipes have?"
db_connection do |conn|
  comments_per_recipe = conn.exec("SELECT recipe, COUNT(comment) FROM (recipes JOIN comments ON recipes.recipe_id = comments.recipe_id) GROUP BY recipe;")
  comments_per_recipe.each do |string|
    puts "#{string['recipe']}: #{string['count']}"
  end
end
puts

puts "What is the name of the recipe that is associated with a specific comment?"
puts "In this case, since they are random comments, It will displays each of them with a 'c'"
db_connection do |conn|
  specific_recipe = conn.exec("SELECT recipe FROM recipes
    JOIN comments ON recipes.recipe_id = comments.recipe_id
    WHERE comment  LIKE '%c%';")

    specific_recipe.each do |string|
      puts string['recipe']
    end
end
puts

# Add a new recipe titled Brussels Sprouts with Goat Cheese. Add two comments to it.
db_connection do |conn|
  random_text_1 = Faker::Lorem.sentence
  random_text_2 = Faker::Lorem.sentence
  conn.exec("INSERT INTO recipes (recipe, recipe_id) VALUES ('Brussels Sprouts with Goat Chees', '#{@count}');")
  conn.exec("INSERT INTO comments (comment, recipe_id) VALUES ('#{random_text_1}','#{@count}');")
  @count +=1
  conn.exec("INSERT INTO comments (comment, recipe_id) VALUES ('#{random_text_2}','#{@count}');")
  @count +=1

end
