SELECT xmlelement (
        name "employee", 
        xmlattributes (e.employee_id as "id"), 
        xmlforest (
            e.employee_id as "employeeId", 
            e.first_name as "firstName", 
            e.last_name as "lastName", 
            e.email as "email", 
            xmlagg (
                xmlelement (
                    name "jobHistory", 
                    xmlforest (
                        jh.start_date as "startDate", 
                        jh.end_date as "endDate", 
                        j.job_title as "jobTitle",
                        d.department_name as "departmentName"
                    )
                )
            ) as "jobHistory"
        )
    )
FROM
    employees e
    LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
    LEFT JOIN jobs j ON jh.job_id = j.job_id
    LEFT JOIN departments d ON jh.department_id = d.department_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email;