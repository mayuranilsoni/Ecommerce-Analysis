USE olist;

show variables like "local_infile";

set global local_infile = 1;

create table customers_dataset (
	customer_id varchar(50),
    customer_unique_id varchar(50),
    customer_zip_code_prefix int,
    customer_city varchar(50),
    customer_state varchar(50)
);

load data local infile 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_customers_dataset.csv'
INTO TABLE customers_dataset
fields terminated by ","
ignore 1 rows;

select count(*) from customers_dataset;
select * from customers_dataset;

create table order_item(order_id varchar(100),
                        order_item_id int,
                        product_id varchar(100), 
                        seller_id varchar(100),
                        shipping_limit_date date,
                        price decimal(8,2),
                        freight_value decimal(8,2));
                        
LOAD DATA LOCAL INFILE 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_order_items_dataset.csv'
INTO TABLE order_item
FIELDS TERMINATED BY ','
IGNORE 1 ROWS
(order_id,
 order_item_id,
 product_id,
 seller_id,
 @shipping_limit_date,
 price,
 freight_value)
SET shipping_limit_date = STR_TO_DATE(@shipping_limit_date, '%d-%m-%Y');
select * from order_item;

create table geo_loc(geolocation_zip_code_prefix int ,
					 geolocation_lat decimal(6,3),
                     geolocation_lng decimal(6,3),
                     geolocation_city varchar(50),
                     geolocation_state varchar(50)
);

LOAD DATA LOCAL INFILE 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_geolocation_dataset.csv'
INTO TABLE  geo_loc
FIELDS TERMINATED BY ','
IGNORE  1 ROWS;

select count(*) from geo_loc;
# =======================================================
create table payment (order_id varchar(50),
                      payment_sequential int ,
                      payment_type varchar(50),
                      payment_installments int ,
                      payment_value decimal(11,2)
					 );
LOAD DATA LOCAL INFILE 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_order_payments_dataset.csv'
INTO TABLE  payment
FIELDS TERMINATED BY ','
IGNORE  1 ROWS;
#
desc select * from payment;

create table review(order_id  varchar(50),
                    review_score int ,
                    review_creation_date date,
                    review_answer_timestamp date
);
 load data local infile 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_order_reviews_dataset.csv'
 into table review
 fields terminated by ','
 ignore 1 rows
 (order_id,review_score,@review_creation_date,@review_answer_timestamp )
 set
 review_creation_date=str_to_date(trim(@review_creation_date),'%d-%m-%Y'),
 review_answer_timestamp =str_to_date(trim(@review_answer_timestamp),'%d-%m-%Y')
;
select count(*) from review;
select * from review;
#========================================================================
 create table orders(order_id varchar(50),
              customer_id varchar(50),
              order_status varchar(50),
              order_purchase_timestamp date,
              order_approved_at   date,
              order_delivered_carrier_date date,
              order_delivered_customer_date date,
              order_estimated_delivery_date date
);
 
LOAD DATA LOCAL INFILE 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
 @order_id, @customer_id, @order_status,@order_purchase_timestamp,@order_approved_at,@order_delivered_carrier_date,
 @order_delivered_customer_date,@order_estimated_delivery_date
)
SET
 order_id = TRIM(@order_id),customer_id = TRIM(@customer_id),order_status = TRIM(@order_status),
 order_purchase_timestamp =STR_TO_DATE(TRIM(@order_purchase_timestamp),'%Y-%m-%d %H:%i:%s'),
 order_approved_at =STR_TO_DATE(TRIM(@order_approved_at),'%Y-%m-%d %H:%i:%s'),
 order_delivered_carrier_date=STR_TO_DATE(TRIM(@order_delivered_carrier_date),'%Y-%m-%d %H:%i:%s'),
 order_delivered_customer_date =STR_TO_DATE(TRIM(@order_delivered_customer_date),'%Y-%m-%d %H:%i:%s'),
 order_estimated_delivery_date =STR_TO_DATE(TRIM(@order_estimated_delivery_date),'%Y-%m-%d %H:%i:%s');
 select count(*) from orders;
 select * from orders;
 truncate table orders;
 #=====================================================================
 create table product( product_id varchar(50),product_category_name varchar(50));
 truncate table product;
 load data local infile 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_products_dataset.csv'
 into table product
 fields terminated by ','
 ignore 1 rows
 (product_id ,@product_category_name )
 set 
 product_category_name=trim(@product_category_name);
 
 select count(*) from product;
 select *,length(product_category_name)from product where product_category_name = "pet_shop";
 
 #=================================================================
create table seller(seller_id varchar(50),seller_zip_code_prefix int ,seller_city varchar(50),seller_state varchar(50));

LOAD DATA LOCAL INFILE 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/olist_sellers_dataset.csv'
INTO TABLE seller
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
 @seller_id,
 @seller_zip_code_prefix,
 @seller_city,
 @seller_state
)
SET
 seller_id = TRIM(@seller_id),
 seller_zip_code_prefix =CAST(TRIM(@seller_zip_code_prefix) AS UNSIGNED),
 seller_city = TRIM(@seller_city),
 seller_state = TRIM(@seller_state);
  select * from seller;
 #======================================================================
 create table category_translation(product_category_name varchar(50),product_category_name_english varchar(50));

 load data local infile 'C:/Users/VINIT/Desktop/All subject certificate Dashboards/Oilst project/Project Files/product_category_name_translation.csv'
 into table category_translation
 fields terminated by ','
 ignore 1 rows;
 
 select count(*) from  category_translation;
 select * from category_translation;
 
 #==================================================================================================================================================================
 # 1 weekday vs weekend orders                                      r
with orderdetails as
    (SELECT distinct order_id,
      case
	   WHEN DAYNAME(order_purchase_timestamp)IN ('Saturday','Sunday')THEN 'Weekend'
	   ELSE 'Weekday'
	   END AS Day_Type
      FROM orders
	  ) 
select od.Day_Type,
      concat(round(sum(p.payment_value)/1000000.0,2),'M') total_payment ,
      concat(round(sum(p.payment_value)*100.0/(select sum(payment_value) from payment),2),'%') as percentageV
from  payment as p join orderdetails as od
      on p.order_id=od.order_id 
group by 
      od.Day_Type;


#--2)Number of Orders with review score 5 and payment type as credit card.       r   
select count(Total_orders) as Total_orders,paymethod,reviews from
	   ( SELECT p.order_id as Total_orders,
		    p.payment_type as paymethod,
			r.review_score as reviews
	     FROM payment as p join review as r
			on p.order_id=r.order_id 
	   ) 
as t 
	group by 
		paymethod,reviews
	having 
		paymethod='credit_card' and reviews=5;

#--3)Average number of days taken for order_delivered_customer_date for pet_shop      

select avg(average_days) as Average_days
   from(
		SELECT datediff(od.order_delivered_customer_date,od.order_purchase_timestamp) as average_days
			FROM orders  as od join
				 order_item as oi on od.order_id=oi.order_id join 
				 product as p on oi.product_id=p.product_id 
			where od.order_delivered_customer_date is not null and 
			      p.product_category_name like '%pet_shop%'
		) 
	as t;
    
       
#--4)Average price and payment values from customers of sao paulo city             r
with avgp as
		 (select round(avg(oi.price),2) as avg_price from 
			 order_item as oi join orders as o on oi.order_id=o.order_id join
			 customers_dataset as c on o.customer_id=c.customer_id 	
		  where c.customer_city= 'sao paulo'
		 )
select (select avg_price from avgp) as Avg_price,round(avg(p.payment_value),2) as avg_payment_value ,c.customer_city from 
         payment as p join orders as o  on p.order_id=o.order_id join
         customers_dataset as c  on o.customer_id=c.customer_id 	
        where c.customer_city= 'sao paulo'
group by c.customer_city;


#5)Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores.   

select  review_score,round(avg(shipping_days)) as Shipping_days from
			(SELECT r.review_score as review_score,
					datediff(o.order_delivered_customer_date,o.order_purchase_timestamp) as shipping_days
					FROM 
					review as r join
					orders as o on r.order_id=o.order_id
			) as t
group by review_score
order by review_score;



 
 
 
 
 
 










