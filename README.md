# README

Food Recipes API is a simple API for managing recipes with categories, and authors.
The API is built using Ruby on Rails and uses JSON:API standard.

## Contributors:

The base of the project comes from [foodsi](https://foodsi.pl/) interview template.

## Ruby and Rails Version

- Ruby version: 3.0.7
- Rails version: 7.0.8.4

## Setup Steps

Clone the repository:

```
git clone <repository_url>
cd <repository_name>
```

Install dependencies:

```
bundle install
```

Set up the database:

```
rails db:create
rails db:migrate
rails db:seed
```

Run the server:

```
rails server
```

Run tests:

```
bundle exec rspec
```

## Tasks to Solve

### 1. Implement Likes:

- User must be able to like a recipe.

```ruby
GET api/v1/recipes?filter[liked_by_user_ids][eq]=1000,1222
```

- User must be able to unlike a recipe.

```ruby
POST api/v1/recipes/100/like
```

- User must be able to get a list of recipes they have liked.

```ruby
DELETE api/v1/recipes/100/unlike
```

- Likes count need to be display on recipe index page.

```text
Added  counter cache on Like for recipes and exposed it as a new attribute in RecipeResource
```

### 2. Add Stats for Recipes Grouped by Week/Month:

Add a way to get stats (recipes count and total likes) for author recipes grouped by

- category
- week/month of creation.

```ruby
GET /api/v1/authors/100/recipe_stats?group_by=week
```

### 3. Add Featured Recipes:

Add an endpoint for authors to mark and unmark their recipes as "featured" with constraints:

- up to 3 featured recipes at one time
- the recipe is in the top 10 by likes count for the author

```ruby
POST api/v1/recipes/99923/feature
DELETE api/v1/recipes/99923/unfeature
```

## Existing Endpoints

- GET /recipes
- GET /recipes/:id
- GET /categories
- GET /authors
- GET /authors/:id
