-- view which can be used to retrieve data used by linguists during evaluation

create or replace view corpus_rows as
    select r.id, r.reference, h.text, h.score, cp.name as corpus_name,
           mc.order_number, m.name as model_name, c.id as corpus_id, m.id as model_id from core.row r
        join core.hypothesis h on r.id = h.row_id
        join core.corpus_row cr on r.id = cr.row_id
        join core.corpus c on c.id = cr.corpus_id
        join core.model_component mc on mc.id = h.model_component_id
        join core.component cp on mc.component_id = cp.id
        join core.model m on m.id = mc.model_id
        order by r.id, mc.order_number;

select * from corpus_rows
    where corpus_id = 1 and model_id = 1;

create view model_performance as
    select avg(h.score), mc.order_number, p.name as product_name, p.id as product_id from core.hypothesis h
        join core.model_component mc on mc.id = h.model_component_id
        join core.component c on c.id = mc.component_id
        join core.model m on m.id = mc.model_id
        join core.product p on p.id = m.product_id
        group by mc.order_number, p.name, h.score, p.id
        order by p.name, mc.order_number;

select * from model_performance
    where product_id = 1;
