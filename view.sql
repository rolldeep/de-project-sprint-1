--Создаём представления в сехму analysis
create view de.analysis.orders as select * from de.production.orders;
create view de.analysis.orderitems as select * from de.production.orderitems;
create view de.analysis.orderstatuses as select * from de.production.orderstatuses;
create view de.analysis.orderstatuslog as select * from de.production.orderstatuslog;
create view de.analysis.products as select * from de.production.products;
create view de.analysis.users as select * from de.production.users;