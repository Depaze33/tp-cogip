/*1*/
fonction création de date 

CREATE OR REPLACE FUNCTION format_date(date date, separator varchar) 
 RETURNS text 
 LANGUAGE plpgsql 
AS $$ 
begin 
    -- en plpgsql, l'opérateur de concaténation est || 
    return to_char(date, 'DD' || separator || 'MM' || separator || 'YYYY'); 
END; 
$$

/*2*/
select format_date('2023-02-01', '/');
données de sortie : 01/02/2023;

autre test 
select format_date('2023.02.01', '-');

données de sortie : 01-02-2023;

/*3*/

CREATE OR REPLACE FUNCTION get_items_count() 
 RETURNS integer 
 LANGUAGE plpgsql 
AS $$ 
declare 
    items_count integer; 
    time_now time = now(); 
begin 
    select count(id) 
    into items_count 
    from item; 

    raise notice '% articles à %', items_count, time_now; 

    return items_count; 
END; 
$$

la variable "items_count integer" est declarer dans les variables, 
ensuite nous fesons un compte de l id dans item_count qui est contenu dans la table item, 
ensuite on affiche a l utilisateur l article le prix de l item et la date.

/*4*/
create or replace function count_item_order()
returns integer 
language plpgsql 
as $$

declare 
item_alert integer;
begin

    select count(id) 
    into item_alert
    from item
	where stock < stock_alert;

	raise notice 'stock en alerte de %', item_alert ;

	return item_alert;
end;
$$
-----------
    select count_item_order();

/*5*/
create or replace function best_supplier()
returns varchar
language plpgsql
as $$
declare
    supplier_name varchar;
    action_number int;
begin 
    
    select s."name", o.id
    into supplier_name, action_number
    from supplier s
    join "order" o 
    on s.id = o.supplier_id
    limit 1;

    
    raise notice 'meilleur fournisseur: % avec l''action numéro %', supplier_name, action_number;

    
    return supplier_name;
end;
$$;
--------------
select best_supplier()

/*6*/
create or replace function statisfaction_string_if(statisfaction_index int)
returns varchar
language plpgsql
as $$

begin 

  if satisfaction_index is null then 
return 'Sans commentaire';

elseif statisfaction_index in (1,2) then
return 'Mauvais';

elseif statisfaction_index in (3,4) then
return 'Passable';

elseif statisfaction_index in (5,6) then
return 'Moyen';

elseif statisfaction_index in (7,8) then
return 'Bon';

elseif stasfaction_index in (9,10) then 
return 'Exelent';

    else 
    return 'Non valide';
end if;
end;
$$;

 select  satisfaction_string(1)

 
create or replace function satisfaction_string_case(satisfaction_index int)
returns varchar
language plpgsql
as $$

begin 

return case 
  when satisfaction_index is null then  'Sans commentaire'

when satisfaction_index in (1,2) then 'Mauvais'

when satisfaction_index in (3,4) then 'Passable'

when satisfaction_index in (5,6) then 'Moyen'

when satisfaction_index in (7,8) then 'Bon'

when satisfaction_index in (9,10) then  'Exelent'

else  'Non valide'

end;

end;
$$;

select  satisfaction_string_case(4)

/*7*/
 select id, "name", satisfaction_string_if(satisfaction_index)
 from supplier s 

  select id, "name", satisfaction_string_if(satisfaction_index)
 from supplier s 
 
/*8*/
create or replace function add_days("date" date, days_to_add int)
returns date
language plpgsql
as $$
declare 
date_result date;
begin 
date_result = "date" + days_to_add;

raise notice '% Le nombre de jour, %la date en entrée, % la date en sortie', days_to_add,"date", date_result;
  return date_result;
end;
$$;

 select format_date (add_days('2023-10-10', 5),'/');

 /*9.1*/
 select count(*)
from sale_offer so 

/*9.2*/
create or replace function count_item_by_supplier(supplier_id_id int)
returns int
language plpgsql
as $$
declare
    item_count int;
begin 
    
    select count(so.supplier_id) 
    into item_count
    from sale_offer so
    where so.supplier_id = supplier_id_id;

  
   RAISE EXCEPTION 'L''identifiant % n''existe pas', identifiant USING HINT = 
'Vérifiez l''identifiant du fournisseur.';
    
    
    return item_count;
end;
$$;

select supplier_id, count_item_by_supplier(supplier_id)
from sale_offer so;

/*10*/
create or replace function sales_revenue(supplier_id_id int, "year" int)
returns real 
language plpgsql
as $$
declare 
result_sales real;
begin 
	select sum( so.price*1.20) as price_plus_tva, s.id 
into result_sales 
from sale_offer so 
join supplier s on so.supplier_id = s.id
join "order" o on o.supplier_id = s.id 
where supplier_id_id = so.supplier_id
 and "year" = extract(year from o.date)
group by s.id;


return result_sales;
end;
$$;

select sales_revenue(120, 2021);

/*11*/
drop function if exists get_items_stock_alert;

create or replace function get_items_stock_alert()  
returns table (
    id int, 
    item_code character(4), 
    name varchar
)  
language plpgsql
as $$ 
declare 
    alert_stock int;
    real_stock int;
begin 
    return query  
    select 
        i.id, 
        i.item_code, 
        i.name
    from 
        item i
    where 
        i.real_stock < i.alert_stock;
end; 
$$;

/*12*/
create or replace procedure insert_user(
p_email varchar,
p_password varchar,
p_role varchar)
language plpgsql
as $$

begin
	if  length(p_password)< 8 then
		raise exception 'Le mot de passe doit faire plus de 8 caratères';
	end if;

	if p_email !~'[a-zA-Z0-9_\-]+@([a-zA-Z0-9_\-]+\.)+(com|org|edu|nz|au)'then
		raise exception 'L email n est pas valide';
	end if;

	if p_role not like 'MAIN_ADMIN' 
		and p_role not like 'ADMIN'
		and p_role not like 'COMMON' then
		raise exception 'Rôle invalid';
	end if;

	insert into  "user" (email, last_login, password, role, connexion_attempt, blocked_account) 
values (p_email, NULL, p_password, p_role, 0, false);
	raise notice 'Tout est ok !';

end;
$$;

call insert_user('test@gmail.com', 'azertysd', 'ADMIN');

/*13*/
