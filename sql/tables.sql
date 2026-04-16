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



--day 8 kpis

--1️⃣ Average Appointments by Specialization (Dept Proxy)
SELECT
    d.specialization,
    ROUND(COUNT(a.appointment_id)::numeric / COUNT(DISTINCT d.doctor_id), 2) AS avg_appointments_per_doctor
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization
ORDER BY avg_appointments_per_doctor DESC;


--2️⃣ Repeat Visit Rate (Readmission Proxy)

--Patients who visited more than once.

SELECT
    COUNT(*) FILTER (WHERE visit_count > 1) * 100.0 / COUNT(*) AS repeat_visit_percentage
FROM (
    SELECT patient_id, COUNT(*) AS visit_count
    FROM appointments
    GROUP BY patient_id
) sub;


--3️⃣ Daily Hospital Load (Occupancy Proxy)

--How many patients visit per day.

SELECT
    appointment_date,
    COUNT(*) AS total_visits
FROM appointments
GROUP BY appointment_date
ORDER BY appointment_date;


--4️⃣ Revenue Per Day
SELECT
    bill_date,
    SUM(amount) AS daily_revenue
FROM billing
GROUP BY bill_date
ORDER BY bill_date;


--5️⃣ Average Treatment Cost by Type
SELECT
    treatment_type,
    ROUND(AVG(cost), 2) AS avg_cost
FROM treatments
GROUP BY treatment_type
ORDER BY avg_cost DESC;


--6️⃣ Payment Success Rate
SELECT
    payment_status,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM billing
GROUP BY payment_status;


--7️⃣ Most Demanded Specializations
SELECT
    d.specialization,
    COUNT(a.appointment_id) AS appointments
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
GROUP BY d.specialization
ORDER BY appointments DESC;



--step 3

--1️⃣ Doctor Efficiency Ratio

--How many patients each doctor handles vs experience.

SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name AS doctor_name,
    d.specialization,
    d.years_experience,
    COUNT(a.appointment_id) AS total_patients,
    ROUND(COUNT(a.appointment_id)::numeric / d.years_experience, 2) AS efficiency_ratio
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id
ORDER BY efficiency_ratio DESC;


--2️⃣ Peak Hours for Hospital Visits
SELECT
    appointment_time,
    COUNT(*) AS visits
FROM appointments
GROUP BY appointment_time
ORDER BY visits DESC;

--Insight: Busiest time slots.


--3️⃣ Doctor Load by Date
SELECT
    appointment_date,
    doctor_id,
    COUNT(*) AS daily_patients
FROM appointments
GROUP BY appointment_date, doctor_id
ORDER BY appointment_date;
--4️⃣ Specialization Pressure (Resource Demand)
SELECT
    d.specialization,
    COUNT(a.appointment_id) AS total_appointments,
    COUNT(DISTINCT d.doctor_id) AS total_doctors,
    ROUND(COUNT(a.appointment_id)::numeric / COUNT(DISTINCT d.doctor_id),2) AS load_per_doctor
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY load_per_doctor DESC;


--5️⃣ Create Dashboard-Ready View (Very Important)

--This single view will be used in Power BI.

CREATE OR REPLACE VIEW hospital_dashboard_view AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.status,
    p.gender,
    d.specialization,
    t.treatment_type,
    t.cost,
    b.amount,
    b.payment_status
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN treatments t ON a.appointment_id = t.appointment_id
JOIN billing b ON t.treatment_id = b.treatment_id;