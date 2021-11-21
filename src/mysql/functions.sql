CREATE FUNCTION get_working_time_in_given_month ( in_user_id int , month int) RETURNS FLOAT DETERMINISTIC
    BEGIN
        DECLARE result FLOAT;

        WITH user_hours as (
            SELECT sum(TIMESTAMPDIFF(MINUTE, a.start_time, a.finish_time)) as working_time, a.user_id
                FROM ml_testing.work_time a
                WHERE a.user_id = in_user_id
                  AND EXTRACT( MONTH FROM a.start_time) = month
                  AND EXTRACT( MONTH FROM a.finish_time) = month
                GROUP BY a.user_id
        )
        SELECT uh.working_time / 60 INTO result
            FROM user_hours uh;
        RETURN result;
    END;

select get_working_time_in_given_month(u.id, 10) as working_time
    from ml_testing.user u
    where u.id = 1;


CREATE FUNCTION count_salary(user_id int, month smallint) RETURNS FLOAT DETERMINISTIC
BEGIN
    DECLARE result FLOAT;
    SELECT (get_working_time_in_given_month(u.id, month) * u.hourly_rate) INTO result
        FROM ml_testing.user u
        WHERE u.id = user_id;
    RETURN result;
END;

select count_salary(u.id, 10) as salary
    from ml_testing.user u
    where u.id = 1;