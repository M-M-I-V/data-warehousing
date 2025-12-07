<<<<<<< HEAD
=======
SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing OLTP tables if needed
DROP TABLE IF EXISTS treatments;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS diagnoses;

-- Drop DW tables in correct dependency order
DROP TABLE IF EXISTS fact_admissions;
DROP TABLE IF EXISTS dim_date;
DROP TABLE IF EXISTS dim_department;
DROP TABLE IF EXISTS dim_doctor;
DROP TABLE IF EXISTS dim_diagnosis;
DROP TABLE IF EXISTS dim_patient;

SET FOREIGN_KEY_CHECKS = 1;

-- Create OLTP Tables
>>>>>>> b9aed55 (Finished)
CREATE TABLE diagnoses (
  diagnosis_id INT PRIMARY KEY AUTO_INCREMENT,
  diagnosis_code VARCHAR(50) NOT NULL,
  description VARCHAR(255) NOT NULL
);

CREATE TABLE patients (
  patient_id INT PRIMARY KEY AUTO_INCREMENT,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  gender ENUM('Male','Female','Other') NOT NULL,
<<<<<<< HEAD
  age INT CHECK (age > 0)
=======
  age INT
>>>>>>> b9aed55 (Finished)
);

CREATE TABLE treatments (
  admission_id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id INT NOT NULL,
  doctor_name VARCHAR(255) NOT NULL,
  department VARCHAR(100) NOT NULL,
  diagnosis_id INT NOT NULL,
  admission_date DATETIME NOT NULL,
<<<<<<< HEAD
  treatment_cost DECIMAL(10,2) CHECK (treatment_cost > 0),
=======
  treatment_cost DECIMAL(10,2),
>>>>>>> b9aed55 (Finished)
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id)
);

<<<<<<< HEAD
LOAD DATA INFILE 'C:/xampp/htdocs/data/diagnoses_cleaned.csv
=======
LOAD DATA LOCAL INFILE 'diagnoses_cleaned.csv'
>>>>>>> b9aed55 (Finished)
INTO TABLE diagnoses
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

<<<<<<< HEAD
LOAD DATA INFILE 'C:/xampp/htdocs/data/patients_cleaned.csv
=======
LOAD DATA LOCAL INFILE 'patients_cleaned.csv'
>>>>>>> b9aed55 (Finished)
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

<<<<<<< HEAD
LOAD DATA INFILE 'C:/xampp/htdocs/treatments.csv
=======
LOAD DATA LOCAL INFILE 'treatments_cleaned.csv'
>>>>>>> b9aed55 (Finished)
INTO TABLE treatments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

<<<<<<< HEAD
=======
-- Dimension Tables
>>>>>>> b9aed55 (Finished)
CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    gender ENUM('Male','Female','Other'),
    age INT,
<<<<<<< HEAD
    age_group VARCHAR(20) 
);

CREATE TABLE dim_diagnosis (
    diagnosis_id INT PRIMARY KEY,
    diagnosis_code VARCHAR(50),
    diagnosis_desc VARCHAR(255),
    category VARCHAR(100)
);

CREATE TABLE dim_doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_name VARCHAR(255),
    specialization VARCHAR(100)
);

CREATE TABLE dim_department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    location VARCHAR(100)
);

CREATE TABLE dim_date (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter VARCHAR(2),
    year INT,
    weekday VARCHAR(10)
);

CREATE TABLE fact_admissions (
    admission_id INT PRIMARY KEY, -- Matches treatments.admission_id
    patient_id INT,
    doctor_id INT,
    diagnosis_id INT,
    department_id INT,
    date_id INT,
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

INSERT INTO dim_patient (patient_id, first_name, last_name, gender, age, age_group)
=======
    age_group VARCHAR(20)
);

INSERT IGNORE INTO dim_patient
>>>>>>> b9aed55 (Finished)
SELECT
    patient_id,
    first_name,
    last_name,
    gender,
    age,
    CASE
        WHEN age < 18 THEN 'Child'
        WHEN age BETWEEN 18 AND 64 THEN 'Adult'
        ELSE 'Senior'
<<<<<<< HEAD
    END AS age_group
FROM patients;

INSERT INTO dim_diagnosis (diagnosis_code, diagnosis_desc, category)
SELECT DISTINCT
=======
    END
FROM patients;

CREATE TABLE dim_diagnosis (
    diagnosis_id INT PRIMARY KEY,
    diagnosis_code VARCHAR(50),
    diagnosis_desc VARCHAR(255),
    category VARCHAR(100)
);

INSERT IGNORE INTO dim_diagnosis
SELECT
    diagnosis_id,
>>>>>>> b9aed55 (Finished)
    diagnosis_code,
    description,
    CASE
        WHEN description LIKE '%Covid%' THEN 'Infectious Disease'
        WHEN description LIKE '%Flu%' THEN 'Infectious Disease'
        WHEN description LIKE '%Asthma%' THEN 'Respiratory'
        WHEN description LIKE '%Hypertension%' THEN 'Cardiology'
        WHEN description LIKE '%Diabetes%' THEN 'Endocrinology'
<<<<<<< HEAD
        WHEN description = 'Unknown' THEN 'Unknown'
        ELSE 'General'
    END AS category
FROM diagnoses
WHERE description IS NOT NULL;

INSERT INTO dim_doctor (doctor_name, specialization)
SELECT DISTINCT
    doctor_name,
    department AS specialization
FROM treatments
WHERE doctor_name IS NOT NULL;

INSERT INTO dim_department (department_name, location)
SELECT DISTINCT
    department,
    NULL AS location
FROM treatments
WHERE department IS NOT NULL;

INSERT INTO dim_date (date_id, full_date, day, month, month_name, quarter, year, weekday)
SELECT DISTINCT
    DATE_FORMAT(admission_date, '%Y%m%d') AS date_id,
    DATE(admission_date) AS full_date,
    DAY(admission_date) AS day,
    MONTH(admission_date) AS month,
    MONTHNAME(admission_date) AS month_name,
    QUARTER(admission_date) AS quarter,
    YEAR(admission_date) AS year,
    DAYNAME(admission_date) AS weekday
FROM treatments
WHERE admission_date IS NOT NULL;

INSERT INTO fact_admissions (
    admission_id,
    patient_id,
    doctor_id,
    diagnosis_id,
    department_id,
    date_id,
    treatment_cost
)
=======
        ELSE 'General'
    END
FROM diagnoses;

CREATE TABLE dim_doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    doctor_name VARCHAR(255),
    specialization VARCHAR(100)
);

INSERT IGNORE INTO dim_doctor (doctor_name, specialization)
SELECT DISTINCT doctor_name, department FROM treatments;

CREATE TABLE dim_department (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100),
    location VARCHAR(100)
);

INSERT IGNORE INTO dim_department (department_name)
SELECT DISTINCT department FROM treatments;

CREATE TABLE dim_date (
    date_id VARCHAR(8) PRIMARY KEY,
    full_date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter VARCHAR(2),
    year INT,
    weekday VARCHAR(10)
);

INSERT IGNORE INTO dim_date
SELECT DISTINCT
    DATE_FORMAT(admission_date, '%Y%m%d'),
    DATE(admission_date),
    DAY(admission_date),
    MONTH(admission_date),
    MONTHNAME(admission_date),
    QUARTER(admission_date),
    YEAR(admission_date),
    DAYNAME(admission_date)
FROM treatments;

-- Fact Table
CREATE TABLE fact_admissions (
    admission_id INT PRIMARY KEY,
    patient_id INT,
    doctor_id INT,
    diagnosis_id INT,
    department_id INT,
    date_id VARCHAR(8),
    treatment_cost DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES dim_patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES dim_doctor(doctor_id),
    FOREIGN KEY (diagnosis_id) REFERENCES dim_diagnosis(diagnosis_id),
    FOREIGN KEY (department_id) REFERENCES dim_department(department_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);

INSERT IGNORE INTO fact_admissions
>>>>>>> b9aed55 (Finished)
SELECT
    t.admission_id,
    t.patient_id,
    d.doctor_id,
<<<<<<< HEAD
    t.diagnosis_id,
    dep.department_id,
    DATE_FORMAT(t.admission_date, '%Y%m%d') AS date_id,
    t.treatment_cost
FROM treatments t
JOIN dim_doctor d
    ON t.doctor_name = d.doctor_name
JOIN dim_department dep
    ON t.department = dep.department_name;
=======
    dd.diagnosis_id,
    dep.department_id,
    DATE_FORMAT(t.admission_date, '%Y%m%d'),
    t.treatment_cost
FROM treatments t
JOIN dim_doctor d ON t.doctor_name = d.doctor_name
JOIN dim_diagnosis dd ON t.diagnosis_id = dd.diagnosis_id
JOIN dim_department dep ON t.department = dep.department_name
JOIN dim_date dt ON DATE_FORMAT(t.admission_date, '%Y%m%d') = dt.date_id;
>>>>>>> b9aed55 (Finished)
