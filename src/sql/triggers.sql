CREATE FUNCTION check_date() RETURNS trigger AS $check_date$
    DECLARE
        tmp integer;
    BEGIN
        IF NEW.start_time IS NULL THEN
            RAISE EXCEPTION 'start_time cannot be null';
        END IF;
        IF NEW.finish_time IS NOT NULL AND NEW.start_time > NEW.finish_time THEN
            RAISE EXCEPTION 'finish_time cannot be an earlier date than start_time';
        END IF;

        IF date_part('month', NEW.start_time) <> date_part('month', NEW.finish_time) THEN
            RAISE EXCEPTION 'finish_time and start_time cannot be in another month';
        END IF;

        SELECT 1 into tmp FROM analytics.work_time wt
            WHERE EXISTS(
                SELECT "overlaps"(wt.start_time, wt.finish_time, NEW.start_time, NEW.finish_time)
                    WHERE "overlaps"(wt.start_time, wt.finish_time, NEW.start_time, NEW.finish_time) = True
            );
        IF FOUND THEN
            RAISE EXCEPTION 'Given date overlaps existing date';
        END IF;

        RETURN NEW;
    END;
$check_date$ LANGUAGE plpgsql;

-- drop trigger check_date on analytics.work_time;
-- drop function check_date();

CREATE TRIGGER check_date BEFORE INSERT OR UPDATE ON analytics.work_time
    FOR EACH ROW EXECUTE FUNCTION check_date();

INSERT INTO analytics.work_time (user_id, start_time, finish_time) values
    (1, '2021-10-08 04:05:07', '2021-10-19 05:05:07')