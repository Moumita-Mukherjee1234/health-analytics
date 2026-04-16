CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    gender TEXT,
    date_of_birth DATE,
    contact_number TEXT,
    address TEXT,
    registration_date DATE,
    insurance_provider TEXT,
    insurance_number TEXT
);

CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    specialization TEXT,
    phone_number TEXT,
    years_experience INT,
    hospital_branch TEXT,
    email TEXT
);

CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    doctor_id INT REFERENCES doctors(doctor_id),
    appointment_date DATE,
    appointment_time TIME,
    reason_for_visit TEXT,
    status TEXT
);

CREATE TABLE treatments (
    treatment_id INT PRIMARY KEY,
    appointment_id INT REFERENCES appointments(appointment_id),
    treatment_type TEXT,
    description TEXT,
    cost NUMERIC,
    treatment_date DATE
);

CREATE TABLE billing (
    bill_id INT PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    treatment_id INT REFERENCES treatments(treatment_id),
    bill_date DATE,
    amount NUMERIC,
    payment_method TEXT,
    payment_status TEXT
);


--step 2

--1️⃣ 
Total Patients Registered Per Month

SELECT
    DATE_TRUNC('month', registration_date) AS month,
    COUNT(*) AS total_patients
FROM patients
GROUP BY month
ORDER BY month;

--2️⃣ Appointments Per Doctor (Workload)
SELECT
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY doctor_name, d.specialization
ORDER BY total_appointments DESC;

--3️⃣ Appointment Status Distribution

SELECT
    status,
    COUNT(*) AS count
FROM appointments
GROUP BY status;

--4️⃣ Most Common Treatment Types

SELECT
    treatment_type,
    COUNT(*) AS frequency
FROM treatments
GROUP BY treatment_type
ORDER BY frequency DESC;

--5️⃣ Revenue Generated Per Month

SELECT
    DATE_TRUNC('month', bill_date) AS month,
    SUM(amount) AS total_revenue
FROM billing
GROUP BY month
ORDER BY month;

--6️⃣ Revenue by Treatment Type

SELECT
    t.treatment_type,
    SUM(b.amount) AS revenue
FROM billing b
JOIN treatments t ON b.treatment_id = t.treatment_id
GROUP BY t.treatment_type
ORDER BY revenue DESC;

--7️⃣ Patient Demographics (Gender Split)
SELECT
    gender,
    COUNT(*) AS total
FROM patients
GROUP BY gender;

--8️⃣ Patients with Most Visits

SELECT
    p.first_name || ' ' || p.last_name AS patient_name,
    COUNT(a.appointment_id) AS visit_count
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
GROUP BY patient_name
ORDER BY visit_count DESC
LIMIT 10;

--9️⃣ Doctor Specialization Demand

SELECT
    d.specialization,
    COUNT(a.appointment_id) AS appointments
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization
ORDER BY appointments DESC;
