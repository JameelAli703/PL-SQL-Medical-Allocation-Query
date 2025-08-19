SELECT
  location_id,
  employee_id,
  employee_name,
  ROUND(mtitle) AS mtitle,
  NVL(avail, 0) AS avail,
  ROUND(mtitle) - NVL(avail, 0) AS balance
FROM (
  SELECT
    location_id,
    employee_id,
    employee_name,
    CASE
      WHEN (
        SELECT COUNT(fix_percent_amt)
        FROM PAY_EMP_ALLOW_DEDUCT@hrms
        WHERE employee_id = aa AND adcode = 'A10'
      ) > 0 THEN (
        SELECT fix_percent_amt * 12
        FROM PAY_EMP_ALLOW_DEDUCT@hrms
        WHERE employee_id = aa AND adcode = 'A10'
      )
      ELSE (
        SELECT ROUND(hev.BASIC_PAY * 0.05 *
          CASE
            WHEN hev.JOIN_DATE < TO_DATE(f.ficalyear || '/07/01', 'yyyy/mm/dd') THEN 12
            WHEN hev.JOIN_DATE > TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd') THEN 0
            ELSE MONTHS_BETWEEN(TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd'), hev.JOIN_DATE)
          END
        )
        FROM hrs_all_employee_view@hrms hev, fy f
        WHERE hev.employee_id = aa
      )
    END AS mtitle,
    (
      SELECT SUM(pay_amount)
      FROM pay_emp_payroll@hrms pep
      WHERE pep.employee_id = aa
        AND pep.adcode IN ('A10', 'A43')
        AND pep.PAY_MONTH BETWEEN TO_DATE((SELECT ficalyear || '/07/01' FROM fy), 'yyyy/mm/dd')
                                 AND TO_DATE((SELECT (ficalyear + 1) || '/06/30' FROM fy), 'yyyy/mm/dd')
    ) AS avail
  FROM (
    SELECT
      ROUND(SUM((p.pay_amount + NVL(p.paid_arr, 0)) * 0.05)) AS amount,
      COUNT(p.pay_amount * 0.05) AS con,
      p.employee_id AS aa,
      elu.employee_id,
      elu.employee_name,
      location_id
    FROM pay_emp_payroll@hrms p
    JOIN elm_leave_users elu ON p.employee_id = elu.employee_id
    WHERE elu.status = 'Y'
      AND med_allow = 'Y'
      AND p.adcode = 'A01'
      AND p.PAY_MONTH BETWEEN (
        SELECT CASE
                 WHEN aa.JOIN_DATE < TO_DATE((SELECT ficalyear || '/07/01' FROM fy), 'yyyy/mm/dd')
                 THEN TO_DATE((SELECT ficalyear || '/07/01' FROM fy), 'yyyy/mm/dd')
                 ELSE aa.JOIN_DATE
               END
        FROM hrs_all_employee_view@hrms aa
        WHERE employee_id = p.employee_id
      ) AND TO_DATE((SELECT (ficalyear + 1) || '/06/30' FROM fy), 'yyyy/mm/dd')
    GROUP BY p.employee_id, elu.employee_id, elu.employee_name, elu.location_id
  )
)
 
UNION ALL
 
SELECT
  default_loc,
  TO_NUMBER(employee_id),
  emp_name,
  ROUND(hev.BASIC_PAY * 0.05 *
    CASE
      WHEN hev.JOIN_DATE < TO_DATE(f.ficalyear || '/07/01', 'yyyy/mm/dd') THEN 12
      WHEN hev.JOIN_DATE > TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd') THEN 0
      ELSE MONTHS_BETWEEN(TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd'), hev.JOIN_DATE)
    END
  ) AS mtitle,
  0 AS avail,
  ROUND(hev.BASIC_PAY * 0.05 *
    CASE
      WHEN hev.JOIN_DATE < TO_DATE(f.ficalyear || '/07/01', 'yyyy/mm/dd') THEN 12
      WHEN hev.JOIN_DATE > TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd') THEN 0
      ELSE MONTHS_BETWEEN(TO_DATE((f.ficalyear + 1) || '/06/30', 'yyyy/mm/dd'), hev.JOIN_DATE)
    END
  ) AS balance
FROM hrs_all_employee_view@hrms hev
CROSS JOIN fy f
WHERE NOT EXISTS (
  SELECT 1
  FROM pay_emp_payroll@hrms p
  JOIN elm_leave_users elu ON p.employee_id = elu.employee_id
  WHERE elu.status = 'Y'
    AND med_allow = 'Y'
    AND p.adcode = 'A01'
    AND p.PAY_MONTH BETWEEN (
      SELECT CASE
               WHEN aa.JOIN_DATE < TO_DATE((SELECT ficalyear || '/07/01' FROM fy), 'yyyy/mm/dd')
               THEN TO_DATE((SELECT ficalyear || '/07/01' FROM fy), 'yyyy/mm/dd')
               ELSE aa.JOIN_DATE
             END
      FROM hrs_all_employee_view@hrms aa
      WHERE employee_id = p.employee_id
    ) AND TO_DATE((SELECT (ficalyear + 1) || '/06/30' FROM fy), 'yyyy/mm/dd')
);
