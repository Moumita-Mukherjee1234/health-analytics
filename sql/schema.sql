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

