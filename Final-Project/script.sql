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
  age INT CHECK (age > 0)
);

CREATE TABLE treatments (
  admission_id INT PRIMARY KEY AUTO_INCREMENT,
  patient_id INT NOT NULL,
  doctor_name VARCHAR(255) NOT NULL,
  department VARCHAR(100) NOT NULL,
  diagnosis_id INT NOT NULL,
  admission_date DATETIME NOT NULL,
  treatment_cost DECIMAL(10,2) CHECK (treatment_cost > 0),
  FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
  FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(diagnosis_id)
);

LOAD DATA INFILE 'C:/xampp/htdocs/data/diagnoses_cleaned.csv
INTO TABLE diagnoses
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/data/patients_cleaned.csv
INTO TABLE patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/xampp/htdocs/treatments.csv
INTO TABLE treatments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE dim_patient (
    patient_id INT PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    gender ENUM('Male','Female','Other'),
    age INT,
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
    END AS age_group
FROM patients;

INSERT INTO dim_diagnosis (diagnosis_code, diagnosis_desc, category)
SELECT DISTINCT
    diagnosis_code,
    description,
    CASE
        WHEN description LIKE '%Covid%' THEN 'Infectious Disease'
        WHEN description LIKE '%Flu%' THEN 'Infectious Disease'
        WHEN description LIKE '%Asthma%' THEN 'Respiratory'
        WHEN description LIKE '%Hypertension%' THEN 'Cardiology'
        WHEN description LIKE '%Diabetes%' THEN 'Endocrinology'
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
SELECT
    t.admission_id,
    t.patient_id,
    d.doctor_id,
    t.diagnosis_id,
    dep.department_id,
    DATE_FORMAT(t.admission_date, '%Y%m%d') AS date_id,
    t.treatment_cost
FROM treatments t
JOIN dim_doctor d
    ON t.doctor_name = d.doctor_name
JOIN dim_department dep
    ON t.department = dep.department_name;