-- SELECT QUERY WHICH CAN BE USED DURING LINGUIST WORK ON EVALUATING GIVEN CORPUS

select r.id, r.reference, h.text, h.score, cp.name, mc.order_number, m.name from core.row r
    join core.hypothesis h on r.id = h.row_id
    join core.corpus_row cr on r.id = cr.row_id
    join core.corpus c on c.id = cr.corpus_id
    join core.model_component mc on mc.id = h.model_component_id
    join core.component cp on mc.component_id = cp.id
    join core.model m on m.id = mc.model_id
    where c.id = 1 and h.score < 1.0
    order by r.id, mc.order_number;


-- SELECT QUERY WHICH CAN BE USED BY DEVELOPER TO CHECK MODEL PERFORMANCE

select avg(h.score), mc.order_number, p.name from core.hypothesis h
    join core.model_component mc on mc.id = h.model_component_id
    join core.component c on c.id = mc.component_id
    join core.model m on m.id = mc.model_id
    join core.product p on p.id = m.product_id
    where p.id = 1
    group by mc.order_number, p.name, h.score
    order by p.name, mc.order_number;
