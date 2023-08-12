-- 1. List each pair of actors that have worked together.

-- answer used in the lab from self join:
select * from sakila.film_actor fa1
join sakila.film_actor fa2
on fa1.actor_id <> fa2.actor_id
and fa1.film_id = fa2.film_id;

-- answer using CTE:

with cte_actors as (
	select fa.actor_id, fa.film_id, a.first_name, a.last_name from sakila.film_actor fa
	join sakila.actor a
	using (actor_id)
)
select * from cte_actors fa1
join cte_actors fa2
on fa1.actor_id <> fa2.actor_id
and fa1.film_id = fa2.film_id;

-- 2. For each film, list actor that has acted in more films.
-- query to count number of films in which each actor starred (to be used as CTE)
select actor_id, count(distinct(film_id)) as films_starred from sakila.film_actor
group by actor_id;

-- query to get the highest films_starred for each film (to be used as CTE)

with CTE_FILMS_STARRED as (
	select actor_id, count(distinct(film_id)) as films_starred from sakila.film_actor
    group by actor_id
    )
select film_id, max(films_starred) as max_films_starred
from (
	select fa.film_id, fa.actor_id, fs.films_starred
    from sakila.film_actor fa
    join cte_films_starred fs
    using (actor_id)
    ) as mfc
    group by film_id;
    
-- join to get the list of films' titles and actors' names:

select f.film_id, f.title, fa.actor_id, a.first_name, a.last_name
from sakila.film_actor fa
join sakila.film f using (film_id)
join sakila.actor a using (actor_id)
order by f.film_id;

-- FINAL: query to show film and actor information but only for actors whose films_starred = max_films_starred

with CTE_FILMS_STARRED as (
	select actor_id, count(distinct(film_id)) as films_starred from sakila.film_actor
	group by actor_id
    ),
    CTE_MAX_FILMS_STARRED as (
		with cte_film_count as (
			select actor_id, count(distinct(film_id)) as films_starred from sakila.film_actor
			group by actor_id
			)
		select film_id, max(films_starred) as max_films_starred
		from (
			select fa.film_id, fa.actor_id, fs.films_starred
			from sakila.film_actor fa
			join cte_films_starred fs
			using (actor_id)
			) as mfc
			group by film_id
		)
select f.film_id, f.title, fa.actor_id, a.first_name, a.last_name, mfc1.max_films_starred
from sakila.film_actor fa
join sakila.film f using (film_id)
join sakila.actor a using (actor_id)
join cte_max_films_starred mfc1 on fa.film_id = mfc1.film_id and mfc1.max_films_starred = (
	select films_starred from cte_films_starred
    where actor_id = fa.actor_id
    )
order by f.film_id;

