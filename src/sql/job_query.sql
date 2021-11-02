select get_working_time_in_given_month(u.id, date_part('month', (now() - interval '1 month'))::double precision),
       count_salary(u.id, date_part('month', (now() - interval '1 month'))::double precision),
       u.name || ' '::varchar || u.surname as user_name
    FROM admin.user u
        GROUP BY u.id;
