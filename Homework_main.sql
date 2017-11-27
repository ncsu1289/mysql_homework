use sakila;
drop  database if exists mysql_homework;
create database mysql_homework;


-- 1a. Display the first and last names of all actors from the table actor.
select first_name,last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(ucase(first_name),' ',ucase(last_name)) as Actor_Name from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
select *
from actor
where last_name like '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name from actor
where last_name like '%LI%';

--  2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country from country
where country IN ( 'Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add middle_name varchar(30) AFTER first_name;

select *  from actor;

-- 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs.
alter table actor
modify column middle_name blob;

-- 3c. Now delete the middle_name column.
alter table actor drop middle_name;
select * from actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

create table unique_last_name
select last_name,count(last_name) as c_ln
from actor
group by last_name;

select * from unique_last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select * 
from unique_last_name
where (c_ln >=2);

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

select * 
from actor
where first_name='GROUCHO' and last_name='WILLIAMS';

update actor
set first_name="HARPO"
where actor_id = 172;

select * 
from actor
where actor_id=172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)

--    These instructions are NOT CLEAR!!!  Am I to assume the 4c was to change ALL grouchos to harpos?  Now 4d is to change all harpos back to grouchos with the exception of the original to MUCHO GROUCHO?    Am I to only change the ONE actor to MUCHO GROUCHO?  OR AS WORDED am I to change ALL actors to Groucho who are currently HARPO and ALL other actors to MUCHO GROUCHO????

-- Using the hint, I'll just undo the last exercise and change the one actor back to groucho:

update actor
set first_name="GROUCHO"
where actor_id = 172;

select * 
from actor
where actor_id=172;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

show columns from address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

select  first_name,last_name,address
from staff
join address using(address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

create table amount_rung
select first_name, last_name,staff_id,amount,payment_date
from staff a
join payment b using(staff_id)
where payment_date>='2005-08-01 00:00:00' and payment_date<='2005-09-01 00:00:00';

select staff_id, first_name, last_name, sum(amount)
from amount_rung
group by staff_id ,first_name, last_name;

 -- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
 create table film_actors
 select title, actor_id
 from film_actor fa
 join film f using(film_id);
 
 select title,count(actor_id) as num_actors
 from film_actors
 group by title;
 
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(inventory_id)
from inventory i
join film f using (film_id)
where title="Hunchback Impossible";

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select customer_id,first_name,last_name,sum(amount) as tot_amt_paid
from payment p
join customer c using(customer_id)
group by customer_id,first_name,last_name order by last_name asc;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title
from film
where title like 'K%' or title like 'Q%' and  language_id in
(
select language_id
from language
where name in ('English')
);

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

select first_name, last_name
from actor
where actor_id in
(
  select actor_id
  from film_actor
  where film_id in
   (
     select film_id
     from film
     where title = 'Alone Trip'
    )
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

 create table Can_cust
 select city_id
 from city c
 join country cy using(country_id);
 
 create table Can_add
 select address_id
 from address a
 join city c using (city_id);
 
 create table Can_cust_name_email
 select first_name, last_name, email
 from customer cu
 join address a using (address_id);
 
 select * from Can_cust_name_email;

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

select title
from film
where film_id in
(
  select film_id
  from film_category
  where category_id in
  (
    select category_id
    from category
    where name = 'Family'
    )
  );

-- 7e. Display the most frequently rented movies in descending order.

create table film_inventory
select title, inventory_id
from film f
join inventory i using(film_id);
select * from film_inventory;

create table freq_rent
select title,  count(title) as count_rental
from film_inventory
join rental r using(inventory_id)
group by title order by count_rental desc;

select * from freq_rent;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
create view salesbystore
as
select
concat(c.city, _utf8',', cy.country) as store
, concat(m.first_name, _utf8' ', m.last_name) as manager
, sum(p.amount) as total_sales
from payment as p
inner join rental as r on p.rental_id = r.rental_id
inner join  inventory as i on r.inventory_id = i.inventory_id
inner join  store as s on i.store_id = s.store_id
inner join  address as a on s.address_id = a.address_id
inner join  city as c on a.city_id = c.city_id
inner join  country as cy on c.country_id = cy.country_id
inner join  staff as m on s.manager_staff_id = m.staff_id
group by s.store_id
order by cy.country, c.city;


-- 7g. Write a query to display for each store its store ID, city, and country.

select
city, country, store_id
from country as ctry
inner join city as c using (country_id)
inner join address as a using(city_id)
inner join store AS s using(address_id)
group by store_id
order by ctry.country, c.city;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select
name, sum(amount) as gross_revenue
from category cg
inner join film_category as fc using (category_id)
inner join film as f using(film_id)
inner join inventory as i using(film_id)
inner join rental as r using (inventory_id)
inner join payment as p using(rental_id)
group by name
order by gross_revenue desc;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five as
select
name, sum(amount) as gross_revenue
from category cg
inner join film_category as fc using (category_id)
inner join film as f using(film_id)
inner join inventory as i using(film_id)
inner join rental as r using (inventory_id)
inner join payment as p using(rental_id)
group by name
order by gross_revenue desc;

-- 8b. How would you display the view that you created in 8a?

select * from top_five;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view if exists top_five;