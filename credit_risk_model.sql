
------------------------------------------------------------------------------------

-- ABSCHLUSSPROJEKT SQL CHRISTIN GÄRTNER --

-- Datenverständnis
-- Backup-Erstellung
-- ID-Generierung
-- Duplikatentfernung 
-- Outlier-Handlung
-- NULL Analyse 
-- Datentypänderung
-- Aufgabe 1
-- Aufgabe 2
-- Boni (Risikogruppen, Scoring)

-----------------------------------------------------------------------------------

drop table if exists credit_risk_model;
drop table if exists base_data;
drop table if exists median_rates;
drop table if exists scoring;


-- Datenverständnis
select * from credit_risk;
SELECT * FROM credit_risk LIMIT 100;
DESCRIBE credit_risk;
SELECT COUNT(*) AS total_rows FROM credit_risk;


-- Spaltenanalyse vor Imputation--
-- Alter des Kreditnehmers in Jahren --
SELECT person_age, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY person_age
ORDER BY anzahl DESC;

-- Jährliches Bruttoeinkommen des Kreditnehmers --
SELECT person_income, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY person_income
ORDER BY anzahl DESC;

-- Wohnsituation - zur Miete/Eigentürmer/Hypothek/andere--
SELECT person_home_ownership, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY person_home_ownership
ORDER BY anzahl DESC;

-- Dauer der aktuellen Beschäftigung in Jahren --
SELECT person_emp_length, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY person_emp_length
ORDER BY anzahl DESC;

-- Verwendungszweck Kredit - Bildung/medizinisch/Unternehmensgründung/Freizeit/Schuldenkonsolidierung/RenovierungHaus --
SELECT loan_intent, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_intent
ORDER BY anzahl DESC;

-- Bonitätsbewertung des Kredits von A (beste) bis G (schlechteste) --
SELECT loan_grade, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_grade
ORDER BY anzahl DESC;

-- Höhe des beantragten/vergebenen Kredits --
SELECT loan_amnt, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_amnt
ORDER BY anzahl DESC;

-- Zinssatz des Kredits in Prozent --
SELECT loan_int_rate, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_int_rate
ORDER BY anzahl DESC;

-- Kreditstatus: 0 = kein Ausfall, 1 = Ausfall --
SELECT loan_status, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_status;

-- Anteil der Kreditsumme am Jahreseinkommen --
SELECT loan_percent_income, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY loan_percent_income
ORDER BY anzahl DESC;

-- Frühere Zahlungsausfälle in der Kredithistorie --
SELECT cb_person_default_on_file, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY cb_person_default_on_file;

-- Länge der Kredithistorie in Jahren --
SELECT cb_person_cred_hist_length, COUNT(*) AS anzahl
FROM credit_risk
GROUP BY cb_person_cred_hist_length;


-- arithmetische Mittel/Aggregatfunktionen --
SELECT
MIN(person_age),
MAX(person_age),
AVG(person_age),
COUNT(person_age)
FROM credit_risk;

SELECT
MIN(person_income),
MAX(person_income),
AVG(person_income),
SUM(person_income),
COUNT(person_income)
FROM credit_risk;

SELECT
MIN(loan_amnt),
MAX(loan_amnt),
AVG(loan_amnt),
SUM(loan_amnt),
COUNT(loan_amnt)
FROM credit_risk;

SELECT
MIN(loan_int_rate),
MAX(loan_int_rate),
AVG(loan_int_rate),
COUNT(loan_int_rate)
FROM credit_risk;

SELECT
MIN(loan_percent_income),
MAX(loan_percent_income),
AVG(loan_percent_income),
COUNT(loan_percent_income)
FROM credit_risk;

SELECT
MIN(person_emp_length),
MAX(person_emp_length),
AVG(person_emp_length),
COUNT(person_emp_length)
FROM credit_risk;

SELECT
MIN(cb_person_cred_hist_length),
MAX(cb_person_cred_hist_length),
AVG(cb_person_cred_hist_length),
COUNT(cb_person_cred_hist_length)
FROM credit_risk;


-----------------------------------------------------------------------------------

-- Backup-ERSTELLUNG
CREATE TABLE credit_risk_model AS SELECT * FROM credit_risk;
select * from credit_risk_model;

-----------------------------------------------------------------------------------

-- Duplikatentfernung 

-- ID hinzufügen 
ALTER TABLE credit_risk_model ADD id INT AUTO_INCREMENT PRIMARY KEY FIRST;

-- Überblick 
SELECT COUNT(*) AS total_rows FROM credit_risk_model;

SELECT cnt, COUNT(*) AS gruppen
FROM (
    SELECT COUNT(*) AS cnt
    FROM credit_risk_model
    GROUP BY 
        person_age, person_income, person_home_ownership,
        person_emp_length, loan_intent, loan_grade,
        loan_amnt, loan_int_rate, loan_status,
        loan_percent_income, cb_person_default_on_file,
        cb_person_cred_hist_length
) t
GROUP BY cnt
ORDER BY cnt;

-- Duplikate (165) anzeigen
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY person_age, person_income, person_home_ownership,
                            person_emp_length, loan_intent, loan_grade,
                            loan_amnt, loan_int_rate, loan_status,
                            loan_percent_income, cb_person_default_on_file,
                            cb_person_cred_hist_length
               ORDER BY id
           ) AS rn
    FROM credit_risk_model
) t
WHERE rn > 1;


-- Anzahl Duplikate
SELECT COUNT(*) AS duplicate_rows
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY person_age, person_income, person_home_ownership,
                            person_emp_length, loan_intent, loan_grade,
                            loan_amnt, loan_int_rate, loan_status,
                            loan_percent_income, cb_person_default_on_file,
                            cb_person_cred_hist_length
               ORDER BY id
           ) AS rn
    FROM credit_risk_model
) t
WHERE rn > 1;

-- Duplikate löschen 
SET SQL_SAFE_UPDATES = 0;
DELETE FROM credit_risk_model
WHERE id IN (
    SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (
                   PARTITION BY person_age, person_income, person_home_ownership,
                                person_emp_length, loan_intent, loan_grade,
                                loan_amnt, loan_int_rate, loan_status,
                                loan_percent_income, cb_person_default_on_file,
                                cb_person_cred_hist_length
                   ORDER BY id
               ) AS rn
        FROM credit_risk_model
    ) t
    WHERE rn > 1
);
SET SQL_SAFE_UPDATES = 1;

-- Kontrolle 
SELECT COUNT(*) AS cleaned_rows FROM credit_risk_model;

SELECT COUNT(*) AS remaining_duplicates
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY person_age, person_income, person_home_ownership,
                            person_emp_length, loan_intent, loan_grade,
                            loan_amnt, loan_int_rate, loan_status,
                            loan_percent_income, cb_person_default_on_file,
                            cb_person_cred_hist_length
               ORDER BY id
           ) AS rn
    FROM credit_risk_model
) t
WHERE rn > 1;


-----------------------------------------------------------------------------------

-- Outlier-Handlung

-- Übersicht --
SELECT outlier_flag, COUNT(*) 
FROM (
    SELECT *,
    CASE
        WHEN person_age < 18 OR person_age > 100 THEN 'Age Outlier'
        WHEN person_income <= 0 OR person_income > 1000000 THEN 'Income Outlier'
        WHEN person_emp_length < 0 OR person_emp_length > 60 THEN 'Employment Outlier'
        WHEN loan_amnt <= 0 OR loan_amnt > 500000 THEN 'Loan Amount Outlier'
        WHEN loan_int_rate < 0 OR loan_int_rate > 50 THEN 'Interest Rate Outlier'
        WHEN loan_percent_income > 1 THEN 'Loan Percent Outlier'
        WHEN cb_person_cred_hist_length < 0 OR cb_person_cred_hist_length > 50 THEN 'Credit History Outlier'
        ELSE 'Normal'
    END AS outlier_flag
    FROM credit_risk_model
) t
GROUP BY outlier_flag;

-- relevante Outliers -15 total 
SELECT 
    id,
    person_age,
    person_income,
    person_emp_length,
    loan_amnt,
    loan_int_rate,
    loan_percent_income
FROM credit_risk_model
WHERE 
    person_age < 18 OR person_age > 100
 OR person_income <= 0 OR person_income > 1000000
 OR person_emp_length < 0 OR person_emp_length > 60
 OR loan_amnt <= 0 OR loan_amnt > 500000
 OR loan_int_rate < 0 OR loan_int_rate > 50
 OR loan_percent_income > 1
 OR cb_person_cred_hist_length < 0 OR cb_person_cred_hist_length > 50;

-- Prüfung Einzelfall (ID)  
SELECT *
FROM credit_risk_model
WHERE person_age > 100
   OR (person_age BETWEEN 20 AND 25 AND person_emp_length > 100);
   
-- Löschung 7 Outliers - da sonst Scoringverzerrung -
SET SQL_SAFE_UPDATES = 0;
DELETE FROM credit_risk_model 
WHERE person_age > 100
   OR (person_age BETWEEN 20 AND 25 AND person_emp_length > 100);
SET SQL_SAFE_UPDATES = 1;

-- Ergebnis nach Löschung 
SELECT COUNT(*) AS total_rows FROM credit_risk_model;


-----------------------------------------------------------------------------------

-- Prüfung: Berechnung loan_percent_income ≈ loan_amnt / person_income
SELECT 
    id,
    person_income,
    loan_amnt,
    loan_percent_income,
    loan_amnt / person_income AS recalculated,
    ABS(loan_percent_income - (loan_amnt / person_income)) AS diff
FROM credit_risk_model
WHERE person_income > 0
ORDER BY diff DESC;

-- Falsche Werte 387 - 1,19%  
SELECT COUNT(*) AS wrong_values
FROM credit_risk_model
WHERE person_income > 0
AND ABS(loan_percent_income - (loan_amnt / person_income)) > 0.01;

-- Korrektur falsche Werte
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_risk_model
SET loan_percent_income = loan_amnt / person_income
WHERE person_income > 0
AND ABS(loan_percent_income - (loan_amnt / person_income)) > 0.01;
SET SQL_SAFE_UPDATES = 1;

-- Kontrolle Korrektur
SELECT COUNT(*) AS wrong_values
FROM credit_risk_model
WHERE person_income > 0
AND ABS(loan_percent_income - (loan_amnt / person_income)) > 0.01;

-----------------------------------------------------------------------------------


-- NULL Analyse 
SELECT 
    SUM(person_age IS NULL),
    SUM(person_income IS NULL),
    SUM(person_home_ownership IS NULL),
    SUM(person_emp_length IS NULL),
    SUM(loan_intent IS NULL),
    SUM(loan_grade IS NULL),
    SUM(loan_amnt IS NULL),
    SUM(loan_int_rate IS NULL),
    SUM(loan_status IS NULL),
    SUM(loan_percent_income IS NULL),
    SUM(cb_person_default_on_file IS NULL),
    SUM(cb_person_cred_hist_length IS NULL)
FROM credit_risk_model;


-- NULL WERTE loan_int_rate (Zinssatz) -- 
CREATE TEMPORARY TABLE base_data AS
SELECT *,
    CASE 
        WHEN person_income < 30000 THEN 'Low'
        WHEN person_income < 70000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,

    CASE 
        WHEN person_emp_length < 2 THEN 'Short'
        WHEN person_emp_length < 10 THEN 'Medium'
        ELSE 'Long'
    END AS emp_group,

    CASE 
        WHEN loan_percent_income < 0.1 THEN 'Low_Burden'
        WHEN loan_percent_income < 0.3 THEN 'Medium_Burden'
        ELSE 'High_Burden'
    END AS burden_group
FROM credit_risk_model;


-- Median je Gruppe 
CREATE TEMPORARY TABLE median_rates AS
SELECT 
    income_group,
    emp_group,
    burden_group,
    AVG(loan_int_rate) AS median_rate
FROM (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY income_group, emp_group, burden_group
            ORDER BY loan_int_rate
        ) AS rn,

        COUNT(*) OVER (
            PARTITION BY income_group, emp_group, burden_group
        ) AS total
    FROM base_data
    WHERE loan_int_rate IS NOT NULL
) t
WHERE rn IN (FLOOR((total+1)/2), FLOOR((total+2)/2))
GROUP BY income_group, emp_group, burden_group;


-- Globaler Median (Fallback) 
SELECT AVG(loan_int_rate) INTO @global_median
FROM credit_risk_model
WHERE loan_int_rate IS NOT NULL;


-- NULL-Werte ersetzen
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_risk_model t1
JOIN base_data b ON t1.id = b.id
LEFT JOIN median_rates t2
ON b.income_group = t2.income_group
AND b.emp_group = t2.emp_group
AND b.burden_group = t2.burden_group
SET t1.loan_int_rate = COALESCE(t2.median_rate, @global_median)
WHERE t1.loan_int_rate IS NULL;
SET SQL_SAFE_UPDATES = 1;


-- Kontrolle - NULLs
SELECT COUNT(*) AS remaining_nulls
FROM credit_risk_model
WHERE loan_int_rate IS NULL;

-- Verteilung prüfen
SELECT 
    MIN(loan_int_rate),
    MAX(loan_int_rate),
    AVG(loan_int_rate)
FROM credit_risk_model;


-- NULL- Werte (887) in person_emp_length (Beschäftiungsdauer)
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM credit_risk_model) AS percent_null
FROM credit_risk_model
WHERE person_emp_length IS NULL;

SELECT *,
    CASE 
        WHEN person_emp_length IS NULL THEN 'Unknown'
        WHEN person_emp_length < 2 THEN 'Short'
        WHEN person_emp_length < 10 THEN 'Medium'
        ELSE 'Long'
    END AS emp_group
FROM credit_risk_model;

ALTER TABLE credit_risk_model ADD emp_group VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_risk_model
SET emp_group = 
    CASE 
        WHEN person_emp_length IS NULL THEN 'Unknown'
        WHEN person_emp_length < 2 THEN 'Short'
        WHEN person_emp_length < 10 THEN 'Medium'
        ELSE 'Long'
    END;
SET SQL_SAFE_UPDATES = 1;

SELECT 
    emp_group,
    COUNT(*) AS anzahl,
    ROUND(AVG(loan_status) * 100, 2) AS default_rate_pct
FROM credit_risk_model
GROUP BY emp_group
ORDER BY default_rate_pct DESC;

-----------------------------------------------------------------------------------


-- Datentypänderung
DESCRIBE credit_risk_model;

ALTER TABLE credit_risk_model
MODIFY person_income DECIMAL(12,2) NOT NULL,
MODIFY loan_amnt DECIMAL(12,2) NOT NULL,
MODIFY person_emp_length INT,
MODIFY loan_int_rate DECIMAL(5,2),
MODIFY loan_percent_income DECIMAL(10,6);

SELECT 
    MIN(loan_percent_income),
    MAX(loan_percent_income)
FROM credit_risk_model;


-- neue Spalte loan_grade_num
ALTER TABLE credit_risk_model ADD loan_grade_num TINYINT;
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_risk_model
SET loan_grade_num = 
    CASE 
        WHEN loan_grade = 'A' THEN 1
        WHEN loan_grade = 'B' THEN 2
        WHEN loan_grade = 'C' THEN 3
        WHEN loan_grade = 'D' THEN 4
        WHEN loan_grade = 'E' THEN 5
        WHEN loan_grade = 'F' THEN 6
        WHEN loan_grade = 'G' THEN 7
    END;
SET SQL_SAFE_UPDATES = 1;  
  
SELECT loan_grade, loan_grade_num, COUNT(*) 
FROM credit_risk_model
GROUP BY loan_grade, loan_grade_num
ORDER BY loan_grade;

-- neue Spalte default_flag (cb_person_default_on_file)
ALTER TABLE credit_risk_model ADD default_flag TINYINT;
SET SQL_SAFE_UPDATES = 0;
UPDATE credit_risk_model
SET default_flag = 
    CASE 
        WHEN cb_person_default_on_file = 'Y' THEN 1
        WHEN cb_person_default_on_file = 'N' THEN 0
        ELSE NULL
    END;
SET SQL_SAFE_UPDATES = 1;  

SELECT 
    cb_person_default_on_file,
    default_flag,
    COUNT(*) AS anzahl
FROM credit_risk_model
GROUP BY cb_person_default_on_file, default_flag
ORDER BY cb_person_default_on_file;

SHOW COLUMNS FROM credit_risk_model;

-----------------------------------------------------------------------------------


-- Aufgabe 1 - KREDITRISIKO-ANALYSE

-- Datenqualitäts-Check --
SELECT *
FROM credit_risk_model
WHERE person_income <= 0
   OR loan_amnt <= 0
   OR person_age < 18;
   
SELECT 
    COUNT(*) AS total_loans,
    AVG(loan_status) AS overall_default_rate,
    AVG(loan_percent_income) AS avg_debt_ratio
FROM credit_risk_model;   
   

-- 1. EINZELRISIKEN -- 

-- 1.1 Verschuldungsgrad & Risiko (>50%) = 249 rows
SELECT 
    CASE 
        WHEN loan_percent_income > 0.8 THEN 'Extreme (>80%)'
        WHEN loan_percent_income > 0.5 THEN 'High (50-80%)'
        WHEN loan_percent_income > 0.3 THEN 'Medium (30-50%)'
        ELSE 'Low (<=30%)'
    END AS debt_group,
    
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate

FROM credit_risk_model
GROUP BY debt_group
ORDER BY 
CASE 
    WHEN debt_group = 'Low (<=30%)' THEN 1
    WHEN debt_group = 'Medium (30-50%)' THEN 2
    WHEN debt_group = 'High (50-80%)' THEN 3
    ELSE 4
END;


-- 1.2 Altersgruppen & Risiko
SELECT 
    CASE 
        WHEN person_age < 21 THEN 'Young'
        WHEN person_age <= 65 THEN 'Standard'
        WHEN person_age <= 75 THEN 'Senior'
        ELSE 'High Risk'
    END AS age_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY age_group;


-- 1.3 Einkommen & Risiko (einheitliche Gruppen)
SELECT 
    CASE 
        WHEN person_income < 30000 THEN 'Low'
        WHEN person_income < 70000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY income_group;


-- 1.4 Beschäftigungsdauer & Risiko
SELECT 
    emp_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY emp_group
ORDER BY emp_group;


-- 2. MODELL-VALIDIERUNG (SCORING LOGIK) -- 

-- 2.1 Zinssatz & Rating (Preislogik)
SELECT 
    loan_grade,
    AVG(loan_int_rate) AS avg_interest_rate
FROM credit_risk_model
GROUP BY loan_grade
ORDER BY loan_grade;


-- 2.2 Rating vs tatsächlicher Ausfall (Reality Check)
SELECT 
    loan_grade,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY loan_grade
ORDER BY loan_grade;


-- 2.3 Kombinierter Check (Grafik1)
SELECT 
    loan_grade,
    AVG(loan_int_rate) AS avg_interest_rate,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY loan_grade
ORDER BY loan_grade;


-- 2.4 Inkonsistente Kreditbewertungen (Grafik2 resultierend auf Grafik1)
SELECT *
FROM credit_risk_model
WHERE loan_grade IN ('A', 'B', 'C')
  AND loan_percent_income > 0.5;


-- 3. VERHALTENSANALYSE (HISTORIE) -- 

-- 3.1 Frühere Zahlungsausfälle → aktuelles Risiko
SELECT 
    cb_person_default_on_file,
    COUNT(*) AS total,
    SUM(loan_status) AS defaults,
    ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2) AS default_rate
FROM credit_risk_model
GROUP BY cb_person_default_on_file;


-- 3.2 Kombination Vergangenheit + Rating (Grafik3)
SELECT 
    cb_person_default_on_file,
    loan_grade,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY cb_person_default_on_file, loan_grade
ORDER BY cb_person_default_on_file, loan_grade;


-- 4. KOMBINATIONEN -- 

-- 4.1 Einkommen + Verschuldung (Kernrisiko) (Grafik4)
SELECT 
    CASE 
        WHEN person_income < 30000 THEN 'Low'
        WHEN person_income < 70000 THEN 'Medium'
        ELSE 'High'
    END AS income_group,
    CASE 
        WHEN loan_percent_income < 0.3 THEN 'Low Risk'
        WHEN loan_percent_income < 0.5 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS debt_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY income_group, debt_group
ORDER BY income_group, debt_group;


-- 4.2 Verschuldungsgruppen (isolierte Risikoanalyse)
SELECT 
    CASE 
        WHEN loan_percent_income < 0.3 THEN 'Low'
        WHEN loan_percent_income < 0.5 THEN 'Medium'
        ELSE 'High'
    END AS debt_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY debt_group;

-- 4.3 High-Risk Kombination
SELECT COUNT(*) AS high_risk_cases
FROM credit_risk_model
WHERE person_income < 30000
  AND loan_percent_income > 0.5
  AND person_emp_length < 2;


-- 4.4 Kredithistorie & Risiko (Grafik5)
SELECT 
    CASE 
        WHEN cb_person_cred_hist_length < 2 THEN 'Very Short'
        WHEN cb_person_cred_hist_length < 5 THEN 'Short'
        WHEN cb_person_cred_hist_length < 10 THEN 'Medium'
        ELSE 'Long'
    END AS credit_hist_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY credit_hist_group;


-- 5. BUSINESS INSIGHTS-- 

-- 5.1 Wohnsituation & Risiko
SELECT 
    person_home_ownership,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY person_home_ownership;


-- 5.2 Kreditgrund & Risiko
SELECT 
    loan_intent,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY loan_intent
ORDER BY default_rate DESC;


-- 5.3 Zinssatz vs tatsächlicher Ausfall (Grafik6)
SELECT 
    CASE 
        WHEN loan_int_rate < 10 THEN 'Low Interest'
        WHEN loan_int_rate < 15 THEN 'Medium Interest'
        ELSE 'High Interest'
    END AS rate_group,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM credit_risk_model
GROUP BY rate_group;


-----------------------------------------------------------------------------------

-- Aufgabe 2 --
SELECT 
    *,
    CASE 
        -- 🔴 HOHES RISIKO
        WHEN 
            loan_percent_income > 0.5
            OR person_income < 30000
            OR person_emp_length < 2
            OR cb_person_default_on_file = 'Y'
        THEN 'High Risk'
        -- 🟡 MITTLERES RISIKO
        WHEN 
            loan_percent_income BETWEEN 0.3 AND 0.5
            OR person_income BETWEEN 30000 AND 70000
        THEN 'Medium Risk'
        -- 🟢 NIEDRIGES RISIKO
        ELSE 'Low Risk'
    END AS risk_category
FROM credit_risk_model;

-- Verteilung (Grafik7) --
SELECT 
    risk_category,
    COUNT(*) AS anzahl,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS prozent
FROM (
    SELECT 
        CASE 
            WHEN loan_percent_income > 0.5
              OR person_income < 30000
              OR person_emp_length < 2
              OR cb_person_default_on_file = 'Y'
            THEN 'High Risk'
            
            WHEN loan_percent_income BETWEEN 0.3 AND 0.5
              OR person_income BETWEEN 30000 AND 70000
            THEN 'Medium Risk'
            
            ELSE 'Low Risk'
        END AS risk_category
    FROM credit_risk_model
) t
GROUP BY risk_category;

-- Kontrolle(Grafik8)--
SELECT 
    risk_category,
    AVG(loan_status) AS default_rate
FROM (
    SELECT 
        CASE 
            WHEN loan_percent_income > 0.5
              OR person_income < 30000
              OR person_emp_length < 2
              OR cb_person_default_on_file = 'Y'
            THEN 'High Risk'
            
            WHEN loan_percent_income BETWEEN 0.3 AND 0.5
              OR person_income BETWEEN 30000 AND 70000
            THEN 'Medium Risk'
            
            ELSE 'Low Risk'
        END AS risk_category,
        loan_status
    FROM credit_risk_model
) t
GROUP BY risk_category;


-----------------------------------------------------------------------------------

-- Bonus1 --
SELECT 
    *,
   CASE 
        -- 🔴 High Risk → schlechte Grades
        WHEN loan_percent_income > 0.5
          OR person_income < 30000
          OR person_emp_length < 2
          OR cb_person_default_on_file = 'Y'
        THEN 'High Risk'
        -- 🟡 Medium Risk
        WHEN loan_percent_income BETWEEN 0.3 AND 0.5
          OR person_income BETWEEN 30000 AND 70000
        THEN 'Medium Risk'
        -- 🟢 Low Risk
        ELSE 'Low Risk'
    END AS new_loan_grade
FROM credit_risk_model;


-- Vergleich alt vs. neu (Grafik9) 
SELECT 
    loan_grade AS old_grade,
    new_loan_grade,
    COUNT(*) AS anzahl
FROM (
    SELECT 
        loan_grade,
        CASE 
            WHEN loan_percent_income > 0.5
              OR person_income < 30000
              OR person_emp_length < 2
              OR cb_person_default_on_file = 'Y'
            THEN 'High Risk'
            WHEN loan_percent_income BETWEEN 0.3 AND 0.5
              OR person_income BETWEEN 30000 AND 70000
            THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS new_loan_grade
    FROM credit_risk_model
) t
GROUP BY loan_grade, new_loan_grade
ORDER BY loan_grade, new_loan_grade;


-- Kontrolle --
SELECT 
    new_loan_grade,
    AVG(loan_status) AS default_rate
FROM (
    SELECT 
        CASE 
            WHEN loan_percent_income > 0.5
              OR person_income < 30000
              OR person_emp_length < 2
              OR cb_person_default_on_file = 'Y'
            THEN 'High Risk'
            WHEN loan_percent_income BETWEEN 0.3 AND 0.5
              OR person_income BETWEEN 30000 AND 70000
            THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS new_loan_grade,
        loan_status
    FROM credit_risk_model
) t
GROUP BY new_loan_grade
ORDER BY new_loan_grade;

-- Fazit: Das bestehende Loan-Grade-System weist Inkonsistenzen auf, Ich habe ein alternatives, datengetriebenes Scoring-Modell entwickelt aus Debt Ratio aus Einkommen, Beschäftigung, Historie und Verschuldung.

-----------------------------------------------------------------------------------

-- Bonus2 --

-- Risikokrechner --
-- | Faktor           | Regel         | Punkte  |
-- | ---------------- | ------------- | ------- |
-- | Einkommen        | <30k / <70k   | +2 / +1 |
-- | Debt Ratio       | >50% / >30%   | +3 / +1 |
-- | Beschäftigung    | <2 / <5 Jahre | +2 / +1 |
-- | Historie         | Default       | +3      |
-- | Alter (kein core) | <21 oder >75  | +1      |

-- | Score | Risiko | 
-- | ----- | ------ | 
-- | 0–2   | Low    | 
-- | 3–5   | Medium | 
-- | ≥6    | High   | 


-- Grafik10
WITH scoring AS (
SELECT 
    *,
    (
        -- Einkommen
        CASE 
            WHEN person_income < 30000 THEN 2
            WHEN person_income < 70000 THEN 1
            ELSE 0
        END
        +
        -- Verschuldung
        CASE 
            WHEN loan_percent_income > 0.5 THEN 3
            WHEN loan_percent_income > 0.3 THEN 1
            ELSE 0
        END
        +
        -- Beschäftigung
        CASE 
            WHEN person_emp_length < 2 THEN 2
            WHEN person_emp_length < 5 THEN 1
            ELSE 0
        END
        +
        -- Historie
        CASE 
            WHEN cb_person_default_on_file = 'Y' THEN 3
            ELSE 0
        END
        +
        -- Alter (leicht gewichtet)
        CASE 
            WHEN person_age < 21 THEN 1
            WHEN person_age > 75 THEN 1
            ELSE 0
        END
    ) AS risk_score
FROM credit_risk_model
)


SELECT 
    *,
    -- Risikogruppe
    CASE 
        WHEN risk_score >= 6 THEN 'High Risk'
        WHEN risk_score >= 3 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_category,
    -- neuer Loan Grade
    CASE 
        WHEN risk_score >= 6 THEN 'High Risk'
        WHEN risk_score >= 3 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS new_loan_grade
FROM scoring;


-- Kontrolle --
SELECT 
    risk_category,
    COUNT(*) AS anzahl,
    AVG(loan_status) AS default_rate
FROM (
    SELECT 
        loan_status,
        -- Score berechnen
        (
            CASE 
                WHEN person_income < 30000 THEN 2
                WHEN person_income < 70000 THEN 1
                ELSE 0
            END
            +
            CASE 
                WHEN loan_percent_income > 0.5 THEN 3
                WHEN loan_percent_income > 0.3 THEN 1
                ELSE 0
            END
            +
            CASE 
                WHEN person_emp_length < 2 THEN 2
                WHEN person_emp_length < 5 THEN 1
                ELSE 0
            END
            +
            CASE 
                WHEN cb_person_default_on_file = 'Y' THEN 3
                ELSE 0
            END
            +
            CASE 
                WHEN person_age < 21 THEN 1
                WHEN person_age > 75 THEN 1
                ELSE 0
            END
        ) AS risk_score,
        -- Risikogruppe
        CASE 
            WHEN (
                CASE 
                    WHEN person_income < 30000 THEN 2
                    WHEN person_income < 70000 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN loan_percent_income > 0.5 THEN 3
                    WHEN loan_percent_income > 0.3 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN person_emp_length < 2 THEN 2
                    WHEN person_emp_length < 5 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN cb_person_default_on_file = 'Y' THEN 3
                    ELSE 0
                END
                +
                CASE 
                    WHEN person_age < 21 THEN 1
                    WHEN person_age > 75 THEN 1
                    ELSE 0
                END
            ) >= 6 THEN 'High Risk'
          WHEN (
                CASE 
                    WHEN person_income < 30000 THEN 2
                    WHEN person_income < 70000 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN loan_percent_income > 0.5 THEN 3
                    WHEN loan_percent_income > 0.3 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN person_emp_length < 2 THEN 2
                    WHEN person_emp_length < 5 THEN 1
                    ELSE 0
                END
                +
                CASE 
                    WHEN cb_person_default_on_file = 'Y' THEN 3
                    ELSE 0
                END
                +
                CASE 
                    WHEN person_age < 21 THEN 1
                    WHEN person_age > 75 THEN 1
                    ELSE 0
                END
            ) >= 3 THEN 'Medium Risk'
            ELSE 'Low Risk'
        END AS risk_category
    FROM credit_risk_model
) t
GROUP BY risk_category;

-- Gesamtschaden --
CREATE TABLE scoring AS
SELECT 
    *,
    (
        CASE 
            WHEN person_income < 30000 THEN 2
            WHEN person_income < 70000 THEN 1
            ELSE 0
        END
        +
        CASE 
            WHEN loan_percent_income > 0.5 THEN 3
            WHEN loan_percent_income > 0.3 THEN 1
            ELSE 0
        END
        +
        CASE 
            WHEN person_emp_length < 2 THEN 2
            WHEN person_emp_length < 5 THEN 1
            ELSE 0
        END
        +
        CASE 
            WHEN cb_person_default_on_file = 'Y' THEN 3
            ELSE 0
        END
        +
        CASE 
            WHEN person_age < 21 THEN 1
            WHEN person_age > 75 THEN 1
            ELSE 0
        END
    ) AS risk_score
FROM credit_risk_model;

SELECT SUM(loan_amnt) AS total_loss
FROM scoring
WHERE risk_score >= 6
  AND loan_status = 1;
  
  -- Verlust --
  SELECT 
    COUNT(*) AS anzahl,
    SUM(loan_amnt) AS vermeidbarer_verlust
FROM scoring
WHERE risk_score >= 6;