CREATE PROCEDURE check_date(start_time timestamp, finish_time timestamp, user_id smallint)
    BEGIN
        DECLARE tmp int;
        IF ISNULL(start_time)  THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'start_time cannot be null';
        END IF;
        IF NOT ISNULL(finish_time) AND start_time > finish_time THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'finish_time cannot be an earlier date than start_time';
        END IF;

        IF EXTRACT( MONTH FROM start_time) <> EXTRACT(MONTH FROM finish_time) THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'finish_time and start_time cannot be in another month';
        END IF;

        with overlaps as (
            SELECT wt.start_time BETWEEN start_time AND finish_time OR
                   start_time BETWEEN wt.start_time AND wt.finish_time as overlaps,
                   wt.id
            FROM ml_testing.work_time wt
            WHERE wt.user_id = user_id
        )
        SELECT SUM(o.overlaps) into tmp FROM overlaps o;
        IF tmp <> 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Given date overlaps existing date';
        END IF;
    END;

drop trigger check_date;
drop procedure check_date;

CREATE TRIGGER check_date BEFORE INSERT ON ml_testing.work_time
    FOR EACH ROW CALL check_date(NEW.start_time, NEW.finish_time, NEW.user_id);

CREATE TRIGGER check_date_update BEFORE UPDATE ON ml_testing.work_time
    FOR EACH ROW CALL check_date(NEW.start_time, NEW.finish_time, NEW.user_id);

INSERT INTO ml_testing.work_time (user_id, start_time, finish_time) values
    (1, '2021-10-08 04:05:08', '2021-10-17 05:05:07');

select * from ml_testing.work_time;