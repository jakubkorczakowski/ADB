CREATE FUNCTION get_working_time_in_given_month( integer , double precision) RETURNS smallint AS $$
    WITH user_hours as (
        SELECT sum(a.finish_time - a.start_time) as working_time, a.user_id
            FROM analytics.work_time a
            WHERE a.user_id = $1
              AND date_part('month', a.start_time) = $2
              AND date_part('month', a.finish_time) = $2
            GROUP BY a.user_id
    )
    SELECT EXTRACT(EPOCH FROM uh.working_time) / 60
        FROM user_hours uh;
    $$
 LANGUAGE SQL;

select get_working_time_in_given_month(u.id, 10.0::double precision)
    from admin.user u
    where u.id = 1;

CREATE FUNCTION count_salary( integer, double precision ) RETURNS money AS $$
    SELECT (get_working_time_in_given_month(u.id, $2) * u.hourly_rate / 60)::money
        FROM admin.user u
        WHERE u.id = $1;
$$ LANGUAGE SQL;

select count_salary(u.id, 10.0::double precision) as salary
    from admin.user u
    where u.id = 1;