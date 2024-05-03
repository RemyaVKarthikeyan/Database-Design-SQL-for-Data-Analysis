
--Task 1 Part 1 Q 1
-- Create the Hospital_GP_Management_Database database
CREATE DATABASE Hospital_GP_Management_Database;
GO

-- Use the Hospital_GP_Management_Database database
USE Hospital_GP_Management_Database;
GO

-- Create Patient Table
CREATE TABLE Patient (
    patient_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    middle_name NVARCHAR(50),
    last_name NVARCHAR(50) NOT NULL,
    dob DATE NOT NULL,
    insurance NVARCHAR(50),
    gender NVARCHAR(50) NOT NULL, -- Assuming 'M' for Male ,'F' for Female and 'Others' for Non-binary
    blood_group NVARCHAR (10),
    address_id INT,
    date_left DATE,
    CONSTRAINT CHK_Gender CHECK (Gender IN ('M', 'F' , 'Others')),
    CONSTRAINT CHK_BloodGroup CHECK (blood_group IN ('A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'I dont know'))
);
GO
-- Alter the Patient table to modify the address_id column
ALTER TABLE Patient
DROP COLUMN address_id;


	SELECT * 
FROM Patient;

-- Create Patient Address Table
CREATE TABLE Address (
    address_id INT IDENTITY NOT NULL PRIMARY KEY,
    address1 nvarchar(50) NOT NULL, 
	address2 nvarchar(50) NULL,
	city NVARCHAR(50) NULL,
    county NVARCHAR(50) NULL,
    postcode NVARCHAR(10) NOT NULL,
);
GO
-- Step 1: Add the patient_id column to the Address table
ALTER TABLE Address
ADD patient_id INT NULL;

-- Step 2: Add a foreign key constraint to link the patient_id column in the Address table to the patient_id column in the Patient table
ALTER TABLE Address
ADD CONSTRAINT FK_Address_Patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id);

-- Update the patient_id column with the values from the address_id column
UPDATE Address
SET patient_id = address_id;


	SELECT * 
FROM Address;



-- Create PatientPortalInfo Table
CREATE TABLE PatientPortalInfo (
    username NVARCHAR(50) NOT NULL PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id),
    pass_word NVARCHAR(50),
    email_address NVARCHAR(100) UNIQUE,
    telephone_number NVARCHAR(20),
    CONSTRAINT CHK_EmailOrPhoneNumber CHECK (
        (email_address IS NOT NULL AND email_address LIKE '%_@_%._%')
        OR
        (telephone_number IS NOT NULL)
    )
);
GO


-- Alter the table to change the pass_word column data type
ALTER TABLE PatientPortalInfo
ALTER COLUMN pass_word BINARY(64);

-- Convert existing passwords from NVARCHAR to NVARBINARY
UPDATE PatientPortalInfo
SET pass_word = CONVERT(BINARY(64), pass_word);

-- Confirm the changes
SELECT * FROM PatientPortalInfo;




	SELECT * 
FROM PatientPortalInfo;

-- Create Department Table
CREATE TABLE Department (
    department_id TINYINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    specialization NVARCHAR(100),
    building_name NVARCHAR(10),
    telephone_no VARCHAR(20)
);
GO

	SELECT * 
FROM Department;

-- Create Doctor Table
CREATE TABLE Doctor (
    doctor_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    first_name NVARCHAR(50) NOT NULL,
    middle_name NVARCHAR(50),
    last_name NVARCHAR(50) NOT NULL,
    sub_specialization NVARCHAR(100),
    room_no NVARCHAR(10),
    department_id TINYINT FOREIGN KEY REFERENCES Department(department_id)
);
GO

	SELECT * 
FROM Doctor;

-- Create DoctorSchedule Table
CREATE TABLE DoctorSchedule (
    schedule_id INT NOT NULL PRIMARY KEY,
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id),
    day_of_week NVARCHAR(10),
    available_timing TIME,
    bookings_remaining TINYINT
);
GO

ALTER TABLE DoctorSchedule
DROP COLUMN available_timing;

ALTER TABLE DoctorSchedule
ADD start_time TIME,
    end_time TIME; 

		SELECT * 
FROM DoctorSchedule;

-- Create PastAppointment Table
CREATE TABLE PastAppointment (
    pastappointment_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id),
    date DATE,
    time TIME,
    department_id TINYINT FOREIGN KEY REFERENCES Department(department_id),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id),
    status NVARCHAR(20)
);
GO
-- Add Constraint to Check Past Appointment Date is in the Past and Status is Completed
ALTER TABLE PastAppointment
ADD CONSTRAINT CHK_PastAppointmentStatus CHECK (date < CAST(GETDATE() AS DATE) AND status = 'completed');

-- Alter the table to make the date column not null
ALTER TABLE PastAppointment
ALTER COLUMN date DATE NOT NULL;

-- Alter the table to make the time column not null
ALTER TABLE PastAppointment
ALTER COLUMN time TIME NOT NULL;



		SELECT * 
FROM PastAppointment;

-- Create MedicalRecord Table
CREATE TABLE MedicalRecord (
    record_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id)
);
GO

-- Alter the MedicalRecord table to include a column for pastappointment_id
ALTER TABLE MedicalRecord
ADD pastappointment_id INT FOREIGN KEY REFERENCES PastAppointment(pastappointment_id);

	SELECT * 
FROM MedicalRecord;

-- Create Diagnosis Table
CREATE TABLE Diagnosis (
    diagnosis_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    record_id INT FOREIGN KEY REFERENCES MedicalRecord(record_id),
    diagnosis NVARCHAR(100),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id) 
);
GO

	SELECT * 
FROM Diagnosis;

-- Create Medicine Table
CREATE TABLE Medicine (
    medicine_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    record_id INT FOREIGN KEY REFERENCES MedicalRecord(record_id),
    medicine_name NVARCHAR(100),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id) 
);
GO
	SELECT * 
FROM Medicine;

-- Create Allergy Table
CREATE TABLE Allergy (
    allergy_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    record_id INT FOREIGN KEY REFERENCES MedicalRecord(record_id),
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id),
    allergy NVARCHAR(100),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id) 
);
GO

	SELECT * 
FROM Allergy;

-- Create ReviewFeedback Table
CREATE TABLE ReviewFeedback (
    review_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id),
    review_text NVARCHAR(1000),
    rating INT,
    CONSTRAINT CK_RatingRange CHECK (rating BETWEEN 1 AND 5) -- Constraint for rating range
);
GO


	SELECT * 
FROM ReviewFeedback;

ALTER TABLE ReviewFeedback
ADD pastappointment_id INT FOREIGN KEY REFERENCES PastAppointment(pastappointment_id);

	SELECT * 
FROM ReviewFeedback;

-- Create CurrentAppointment Table
CREATE TABLE CurrentAppointment (
    currentappointment_id INT IDENTITY (1,1) NOT NULL PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES Patient(patient_id),
    date DATE,
    time TIME,
    department_id TINYINT FOREIGN KEY REFERENCES Department(department_id),
    doctor_id INT FOREIGN KEY REFERENCES Doctor(doctor_id),
    status VARCHAR(20)
);
-- Alter the table to make the date column not null
ALTER TABLE CurrentAppointment
ALTER COLUMN date DATE NOT NULL;

-- Alter the table to make the time column not null
ALTER TABLE CurrentAppointment
ALTER COLUMN time TIME NOT NULL;

	SELECT * 
FROM CurrentAppointment;

-- Task 1 part 1 Q2
-- Add constraint to check that the appointment date is not in the past
ALTER TABLE CurrentAppointment
ADD CONSTRAINT CheckFutureDate
CHECK (date >= CAST(GETDATE() AS DATE));


ALTER TABLE CurrentAppointment
ADD CONSTRAINT CheckStatus
CHECK (status IN ('booked', 'pending', 'available', 'cancelled', 'completed'));




		SELECT * 
FROM CurrentAppointment;

-- Populate the Patient table with 20 records
INSERT INTO Patient (first_name, middle_name, last_name, dob, insurance, gender, blood_group, address_id, date_left)
VALUES 
    ('John', 'Doe', 'Abraham', '1979-02-15', 'Aviva', 'M', 'A+', 1, NULL),
    ('Alice', 'Smith', 'Johnson', '1980-05-20', 'Axa Health', 'F', 'B-', 2, NULL),
    ('Michael', 'Lee', 'Wong', '1975-09-10', 'Saga', 'M', 'O-', 3, NULL),
    ('Emma', NULL, 'Wilson', '1972-12-30', 'Aviva', 'F', 'AB+', 4, NULL),
    ('William', 'Robert', 'Taylor', '1985-07-25', 'Bupa', 'M', 'A-', 5, NULL),
    ('Sophia', 'Rose', 'Brown', '1990-03-18', 'WPA', 'F', 'B+', 6, NULL),
    ('James', NULL, 'Anderson', '1982-11-05', 'Axa Health', 'Others', 'O+', 7, '2023-04-10'),
    ('Olivia', 'Grace', 'Martinez', '1977-06-22', 'Aviva', 'F', 'A-', 8, '2022-09-15'),
    ('Daniel', NULL, 'Hernandez', '1970-08-12', 'Saga', 'M', 'AB-', 9, '2023-01-28'),
    ('Ava', 'Elizabeth', 'Lopez', '1973-04-08', 'Bupa', 'F', 'B+', 10, '2023-03-20'),
    ('Liam', NULL, 'Gonzalez', '1976-10-03', 'WPA', 'M', 'O-', 11, NULL),
    ('Mia', 'Grace', 'Rodriguez', '1988-01-17', 'Aviva', 'F', 'AB+', 12, NULL),
    ('Ethan', 'Lucas', 'Miller', '1974-03-27', 'Bupa', 'M', 'B-', 13, NULL),
    ('Charlotte', NULL, 'King', '1979-08-05', 'WPA', 'Others', 'A+', 14, '2023-02-14'),
    ('Alexander', NULL, 'Wright', '1983-05-12', 'Saga', 'M', 'O+', 15, NULL),
    ('Amelia', 'Claire', 'Turner', '1971-11-28', 'Axa Health', 'F', 'AB-', 16, NULL),
    ('Benjamin', 'Owen', 'Adams', '1986-06-09', 'Aviva', 'M', 'B+', 17, NULL),
    ('Harper', 'Faith', 'Scott', '1978-09-19', 'WPA', 'F', 'O-', 18, '2023-05-30'),
    ('Mason', 'Jacob', 'Morris', '1984-04-02', 'Bupa', 'M', 'A-', 19, NULL),
    ('Evelyn', 'Marie', 'Bailey', '1976-01-13', 'Saga', 'F', 'B-', 20, NULL);

	-- Update the date_left for patients except those with patient_id 8 and 18
UPDATE Patient
SET date_left = NULL
WHERE patient_id NOT IN (8, 18);

		SELECT * 
FROM Patient;


	-- Populate the Address table with 20 records matching the address_id in the Patient table
INSERT INTO Address (address1, address2, city, county, postcode)
VALUES 
    ('123 Main Street', NULL, 'London', 'Greater London', 'E1 6AN'),
    ('456 Elm Street', 'Apt 101', 'Manchester', 'Greater Manchester', 'M1 1AB'),
    ('789 Oak Street', NULL, 'Birmingham', 'West Midlands', 'B1 2CD'),
    ('101 Pine Street', NULL, 'Leeds', 'West Yorkshire', 'LS1 1XY'),
    ('111 Maple Street', 'Suite 201', 'Glasgow', 'Glasgow City', 'G1 1YZ'),
    ('222 Cedar Street', NULL, 'Liverpool', 'Merseyside', 'L1 1ZW'),
    ('333 Birch Street', NULL, 'Bristol', 'Bristol', 'BS1 1ZA'),
    ('444 Walnut Street', 'Flat 3B', 'Sheffield', 'South Yorkshire', 'S1 1WB'),
    ('555 Cherry Street', NULL, 'Edinburgh', 'City of Edinburgh', 'EH1 1ZA'),
    ('666 Willow Street', 'Unit 5', 'Newcastle upon Tyne', 'Tyne and Wear', 'NE1 1WA'),
    ('777 Spruce Street', NULL, 'Nottingham', 'Nottinghamshire', 'NG1 1WN'),
    ('888 Oakwood Street', NULL, 'Leicester', 'Leicestershire', 'LE1 1WL'),
    ('999 Ash Street', 'Floor 2', 'Brighton', 'East Sussex', 'BN1 1WP'),
    ('123 Birchwood Avenue', NULL, 'Cambridge', 'Cambridgeshire', 'CB1 1WD'),
    ('456 Beechwood Avenue', NULL, 'Oxford', 'Oxfordshire', 'OX1 1WP'),
    ('789 Elmwood Avenue', 'Room 10', 'York', 'North Yorkshire', 'YO1 1WQ'),
    ('101 Cedarwood Avenue', NULL, 'Cardiff', 'Cardiff', 'CF1 1WR'),
    ('111 Willowwood Avenue', 'Suite 15A', 'Belfast', 'Belfast', 'BT1 1WS'),
    ('222 Pinecrest Avenue', NULL, 'Dublin', 'Dublin', 'D1 1WT'),
    ('333 Maplewood Avenue', NULL, 'Aberdeen', 'Aberdeenshire', 'AB1 1WU');

		SELECT * 
FROM Address;

-- Insert data into the Patient table
INSERT INTO Patient (first_name, middle_name, last_name, dob, insurance, gender, blood_group, address_id, date_left)
VALUES 
    ('John', 'Doe', 'Abraham', '1979-02-15', 'Aviva', 'M', 'A+', 1, NULL),
    ('Alice', 'Smith', 'Johnson', '1980-05-20', 'Axa Health', 'F', 'B-', 2, NULL),
    ('Michael', 'Lee', 'Wong', '1975-09-10', 'Saga', 'M', 'O-', 3, NULL),
    ('Emma', NULL, 'Wilson', '1972-12-30', 'Aviva', 'F', 'AB+', 4, NULL),
    ('William', 'Robert', 'Taylor', '1985-07-25', 'Bupa', 'M', 'A-', 5, NULL),
    ('Sophia', 'Rose', 'Brown', '1990-03-18', 'WPA', 'F', 'B+', 6, NULL),
    ('James', NULL, 'Anderson', '1982-11-05', 'Axa Health', 'Others', 'O+', 7, '2023-04-10'),
    ('Olivia', 'Grace', 'Martinez', '1977-06-22', 'Aviva', 'F', 'A-', 8, '2022-09-15'),
    ('Daniel', NULL, 'Hernandez', '1970-08-12', 'Saga', 'M', 'AB-', 9, '2023-01-28'),
    ('Ava', 'Elizabeth', 'Lopez', '1973-04-08', 'Bupa', 'F', 'B+', 10, '2023-03-20'),
    ('Liam', NULL, 'Gonzalez', '1976-10-03', 'WPA', 'M', 'O-', 11, NULL),
    ('Mia', 'Grace', 'Rodriguez', '1988-01-17', 'Aviva', 'F', 'AB+', 12, NULL),
    ('Ethan', 'Lucas', 'Miller', '1974-03-27', 'Bupa', 'M', 'B-', 13, NULL),
    ('Charlotte', NULL, 'King', '1979-08-05', 'WPA', 'Others', 'A+', 14, '2023-02-14'),
    ('Alexander', NULL, 'Wright', '1983-05-12', 'Saga', 'M', 'O+', 15, NULL),
    ('Amelia', 'Claire', 'Turner', '1971-11-28', 'Axa Health', 'F', 'AB-', 16, NULL),
    ('Benjamin', 'Owen', 'Adams', '1986-06-09', 'Aviva', 'M', 'B+', 17, NULL),
    ('Harper', 'Faith', 'Scott', '1978-09-19', 'WPA', 'F', 'O-', 18, '2023-05-30'),
    ('Mason', 'Jacob', 'Morris', '1984-04-02', 'Bupa', 'M', 'A-', 19, NULL),
    ('Evelyn', 'Marie', 'Bailey', '1976-01-13', 'Saga', 'F', 'B-', 20, NULL);

	  SELECT * 
FROM Patient;

-- Populate the PatientPortalInfo table with 20 records
INSERT INTO PatientPortalInfo (username, patient_id, pass_word, email_address, telephone_number)
SELECT 
    CONCAT(SUBSTRING(P.first_name, 1, 1), P.last_name) AS username,
    P.patient_id,
    SUBSTRING(CONVERT(NVARCHAR(100),HASHBYTES('SHA1', CONCAT(P.first_name, P.last_name, P.patient_id))),1,10) AS pass_word,
    CONCAT(SUBSTRING(P.first_name, 1, 1), P.last_name, '@example.com') AS email_address,
    CONCAT('07', LEFT(CONVERT(NVARCHAR, P.patient_id), 2), ' ', SUBSTRING(CONVERT(NVARCHAR, P.patient_id), 3, 8)) AS telephone_number
FROM 
    Patient AS P;

	-- Update passwords in PatientPortalInfo table
UPDATE PatientPortalInfo
SET pass_word = SUBSTRING(
    CONVERT(NVARCHAR(100),HASHBYTES('SHA1', pass_word)), 
    1, 
    10
)
WHERE pass_word LIKE '%[^a-zA-Z0-9$#]%';

-- Update telephone numbers and nullify email addresses and phone numbers
UPDATE PatientPortalInfo
SET 
    telephone_number = CONCAT('07', RIGHT('0000000000' + CAST(telephone_number AS VARCHAR(10)), 10))
WHERE LEN(telephone_number) < 10 OR telephone_number IS NULL;

-- Nullify email addresses and phone numbers for specific records
UPDATE PatientPortalInfo
SET 
    email_address = NULL
WHERE username IN ('JAbraham');


UPDATE PatientPortalInfo
SET 
    telephone_number = NULL
WHERE username IN ('AJohnson', 'JAnderson', 'CKing', 'MMorris');


		SELECT * 
FROM PatientPortalInfo;

-- Modify the Department table to increase the size of the building_name column
ALTER TABLE Department
ALTER COLUMN building_name NVARCHAR(50); -- Change the size as needed, here set to 50 characters

-- Now, you can re-run the insert statement
INSERT INTO Department (specialization, building_name, telephone_no)
VALUES 
    ('Oncology', 'Main Building', '123-456-7890'),
    ('Gastroenterology', 'East Wing', '234-567-8901'),
    ('Cardiology', 'West Wing', '345-678-9012'),
    ('Neurology', 'North Wing', '456-789-0123'),
    ('Orthopedics', 'South Wing', '567-890-1234'),
    ('Pediatrics', 'Children''s Hospital', '678-901-2345'),
    ('Obstetrics and Gynecology', 'Specialty Clinic', '789-012-3456'),
    ('Pulmonology', 'Clinic Building', '890-123-4567'),
    ('Dermatology', 'Dermatology Center', '901-234-5678'),
    ('Ophthalmology', 'Eye Center', '012-345-6789'),
    ('Urology', 'Urology Clinic', '123-456-7890'),
    ('ENT', 'ENT Clinic', '234-567-8901'),
    ('Psychiatry', 'Psychiatry Center', '345-678-9012'),
    ('Radiology', 'Radiology Department', '456-789-0123'),
    ('Anesthesiology', 'Anesthesiology Unit', '567-890-1234');

		SELECT * 
FROM Department;

-- Populate the Doctor table with  records
INSERT INTO Doctor (first_name, middle_name, last_name, sub_specialization, room_no, department_id)
VALUES
('John', 'Smith', 'Ava', 'medical oncology', '101', 16),
('Alice', 'Daniel', 'Johnson', 'radiation oncology', '102', 16),
('Michael', 'Long', 'Lee', 'surgical oncology', '103', 16),
('Emma', 'Adams', 'Wilson', 'surgical oncology', '104', 16),
('William', 'Adams', 'Taylor', 'radiation oncology', '105', 16),
('Sophia', 'Addison', 'Brown', 'Gastrointestinal Endoscopy', '231', 17),
('James', 'Adrian', 'Martinez', 'Pancreatology', '232', 17),
('Olivia', 'Alexander', 'Hernandez', 'Gastrointestinal Endoscopy', '233', 17),
('Daniel', 'Alice', 'Lopez', 'Hepatology', '234', 17),
('Ava', 'Allen', 'Gonzalez', 'Gastrointestinal Endoscopy', '235', 17),
('Ethan', 'Allison', 'Walker', 'Interventional Cardiology', '502', 18),
('Mia', 'Amelia', 'Perez', 'Electrophysiology', '503', 18),
('Benjamin', 'Amelia', 'Hall', 'Electrophysiology', '504', 18),
('Isabella', 'Andrews', 'Young', 'Heart Failure', '505', 18),
('Jacob', 'Aria', 'Allen', 'Heart Failure', '506', 18),
('Amelia', 'Aubrey', 'Lewis', 'Clinical Neurophysiology', '100', 19),
('Alexander', 'Aurora', 'King', 'Neurocritical Care', '101', 19),
('Charlotte', 'Avery', 'Wright', 'Neuroimmunology', '102', 19),
('William', 'Baker', 'Hill', 'Clinical Neurophysiology', '103', 19),
('Sophia', 'Barnes', 'Green', 'Neurocritical Care', '104', 19),
('Matthew', 'Bell', 'Adams', 'Sports Medicine', '367', 20),
('Emily', 'Benjamin', 'Russell', 'Joint Replacement Surgery', '368', 20),
('Daniel', 'Blackburn', 'Hughes', 'Joint Replacement Surgery', '369', 20),
('Olivia', 'Bowman', 'Evans', 'Sports Medicine', '370', 20),
('Mason', 'Brooklyn', 'Cole', 'Orthopedic Trauma', '371', 20),
('Elizabeth', 'Brown', 'Long', 'Pediatric Neurology', '258', 21),
('Logan', 'Butler', 'Baker', 'Pediatric Cardiology', '259', 21),
('Grace', 'Carter', 'Rivera', 'Pediatric Neurology', '260', 21),
('Jackson', 'Castillo', 'Parker', 'Pediatric Oncology', '261', 21),
('Chloe', 'Charlotte', 'Howard', 'Pediatric Oncology', '262', 21),
('Sebastian', 'Chloe', 'Stewart', 'Gynecologic Oncology', '226', 22),
('Avery', 'Cole', 'Morris', 'Reproductive Endocrinology', '227', 22),
('Madison', 'Cook', 'Scott', 'Maternal-Fetal Medicine', '228', 22),
('Carter', 'Daniel', 'Sanchez', 'Reproductive Endocrinology', '229', 22),
('Scarlett', 'David', 'Morales', 'Gynecologic Oncology', '230', 22),
('Ryan', 'Davidson', 'Foster', 'Sleep Medicine', '301', 23),
('Sofia', 'Day', 'Powell', 'Interventional Pulmonology', '302', 23),
('Elijah', 'Dixon', 'Sullivan', 'Pulmonary Hypertension', '303', 23),
('Liam', 'Eli', 'Butler', 'Pulmonary Hypertension', '304', 23),
('Aria', 'Elijah', 'Gomez', 'Sleep Medicine', '305', 23),
('Grayson', 'Elizabeth', 'Reed', 'Interventional Pulmonology', '306', 23),
('Amelia', 'Ella', 'Cook', 'Cosmetic Dermatology', '557', 24),
('Lucas', 'Emily', 'Morgan', 'Cosmetic Dermatology', '558', 24),
('Harper', 'Emma', 'Fisher', 'Mohs Surgery', '559', 24),
('Zoe', 'Ethan', 'Thompson', 'Mohs Surgery', '560', 24),
('Nathan', 'Evan', 'Bell', 'Pediatric Dermatology', '561', 24),
('Ella', 'Evans', 'Harrison', 'Cornea and Refractive Surgery', '247', 25),
('Landon', 'Ferguson', 'Gibson', 'Cornea and Refractive Surgery', '248', 25),
('Levi', 'Fisher', 'Fuller', 'Cornea and Refractive Surgery', '249', 25),
('Mia', 'Fletcher', 'Ford', 'Vitreoretinal Surgery', '250', 25),
('Lincoln', 'Ford', 'Fletcher', 'Oculoplastics', '251', 25),
('Layla', 'Foster', 'Fowler', 'Female Urology', '441', 26),
('Jayden', 'Fowler', 'Griffin', 'Andrology', '442', 26),
('Peyton', 'Fuller', 'Wheeler', 'Urologic Oncology', '443', 26),
('Aubrey', 'Gibson', 'Kennedy', 'Urologic Oncology', '444', 26),
('Evan', 'Gomez', 'Porter', 'Female Urology', '445', 26),
('Luna', 'Gonzalez', 'Day', 'Otology', '665', 27),
('Eli', 'Grace', 'Bowman', 'Head and Neck Surgery', '666', 27),
('Hannah', 'Grayson', 'Davidson', 'Rhinology', '667', 27),
('Zoe', 'Green', 'Andrews', 'Otology', '668', 27),
('Brooklyn', 'Griffin', 'Stone', 'Rhinology', '669', 27),
('Jack', 'Hall', 'Hudson', 'Child and Adolescent Psychiatry', '854', 28),
('Addison', 'Hannah', 'Dixon', 'Forensic Psychiatry', '855', 28),
('Adrian', 'Harper', 'Richardson', 'Geriatric Psychiatry', '856', 28),
('Aurora', 'Harrison', 'Barnes', 'Geriatric Psychiatry', '857', 28),
('Luke', 'Hernandez', 'Wallace', 'Forensic Psychiatry', '858', 28),
('Isabella', 'Hess', 'Castillo', 'Interventional Radiology', '552', 29),
('David', 'Hill', 'Myers', 'Diagnostic Radiology', '553', 29),
('Paisley', 'Howard', 'Woods', 'Nuclear Medicine', '554', 29),
('Jonathan', 'Hudson', 'Sullivan', 'Nuclear Medicine', '555', 29),
('Stella', 'Hughes', 'Adams', 'Diagnostic Radiology', '556', 29),
('Julian', 'Isabella', 'Jenkins', 'Perioperative Medicine', '438', 30),
('Allison', 'Isabella', 'Ferguson', 'Perioperative Medicine', '437', 30),
('Josiah', 'Jack', 'Lawson', 'Pain Medicine', '436', 30),
('Naomi', 'Jackson', 'Blackburn', 'Critical Care Medicine', '435', 30),
('Jaxon', 'Jacob', 'Hess', 'Critical Care Medicine', '434', 30);


		SELECT * 
FROM Doctor;



-- Populate the DoctorSchedule table with matching data from Doctor table
INSERT INTO DoctorSchedule (schedule_id, doctor_id, day_of_week, start_time, end_time, bookings_remaining) VALUES
(1, 1, 'Monday', '09:00:00', '12:00:00', 10),
(2, 1, 'Tuesday', '08:30:00', '11:30:00', 8),
(3, 2, 'Monday', '10:00:00', '13:00:00', 12),
(4, 2, 'Tuesday', '09:30:00', '12:30:00', 7),
(5, 3, 'Wednesday', '08:00:00', '11:00:00', 9),
(6, 3, 'Thursday', '10:30:00', '13:30:00', 11),
(7, 4, 'Thursday', '08:30:00', '11:30:00', 6),
(8, 4, 'Friday', '09:00:00', '12:00:00', 14),
(9, 5, 'Friday', '11:00:00', '14:00:00', 5),
(10, 5, 'Monday', '09:30:00', '12:30:00', 13),
(11, 6, 'Tuesday', '10:00:00', '13:00:00', 8),
(12, 6, 'Wednesday', '08:00:00', '11:00:00', 10),
(13, 7, 'Thursday', '09:30:00', '12:30:00', 9),
(14, 7, 'Friday', '10:30:00', '13:30:00', 11),
(15, 8, 'Monday', '08:30:00', '11:30:00', 7),
(16, 8, 'Tuesday', '09:00:00', '12:00:00', 13),
(17, 9, 'Wednesday', '10:00:00', '13:00:00', 6),
(18, 9, 'Thursday', '08:00:00', '11:00:00', 12),
(19, 10, 'Friday', '09:00:00', '12:00:00', 8),
(20, 10, 'Monday', '10:30:00', '13:30:00', 10),
(21, 11, 'Tuesday', '08:30:00', '11:30:00', 9),
(22, 11, 'Wednesday', '10:00:00', '13:00:00', 7),
(23, 12, 'Thursday', '08:00:00', '11:00:00', 11),
(24, 12, 'Friday', '10:30:00', '13:30:00', 8),
(25, 13, 'Monday', '09:30:00', '12:30:00', 10),
(26, 13, 'Tuesday', '10:30:00', '13:30:00', 12),
(27, 14, 'Wednesday', '08:30:00', '11:30:00', 7),
(28, 14, 'Thursday', '09:00:00', '12:00:00', 9),
(29, 15, 'Friday', '10:00:00', '13:00:00', 12),
(30, 15, 'Monday', '08:00:00', '11:00:00', 10),
(31, 16, 'Tuesday', '09:30:00', '12:30:00', 9),
(32, 16, 'Wednesday', '10:30:00', '13:30:00', 7),
(33, 17, 'Thursday', '08:30:00', '11:30:00', 12),
(34, 17, 'Friday', '09:00:00', '12:00:00', 8),
(35, 18, 'Monday', '10:00:00', '13:00:00', 11),
(36, 18, 'Tuesday', '08:00:00', '11:00:00', 9),
(37, 19, 'Wednesday', '09:30:00', '12:30:00', 6),
(38, 19, 'Thursday', '10:30:00', '13:30:00', 12),
(39, 20, 'Friday', '08:30:00', '11:30:00', 8),
(40, 20, 'Monday', '09:00:00', '12:00:00', 10),
(41, 21, 'Tuesday', '10:00:00', '13:00:00', 12),
(42, 21, 'Wednesday', '08:00:00', '11:00:00', 9),
(43, 22, 'Thursday', '09:30:00', '12:30:00', 7),
(44, 22, 'Friday', '10:30:00', '13:30:00', 11),
(45, 23, 'Monday', '08:30:00', '11:30:00', 6),
(46, 23, 'Tuesday', '09:00:00', '12:00:00', 14),
(47, 24, 'Wednesday', '11:00:00', '14:00:00', 5),
(48, 24, 'Thursday', '09:30:00', '12:30:00', 13),
(49, 25, 'Friday', '10:00:00', '13:00:00', 8),
(50, 25, 'Monday', '08:00:00', '11:00:00', 10),
(51, 26, 'Tuesday', '09:30:00', '12:30:00', 9),
(52, 26, 'Wednesday', '10:30:00', '13:30:00', 11),
(53, 27, 'Thursday', '08:30:00', '11:30:00', 7),
(54, 27, 'Friday', '09:00:00', '12:00:00', 13),
(55, 28, 'Monday', '10:00:00', '13:00:00', 6),
(56, 28, 'Tuesday', '08:00:00', '11:00:00', 12),
(57, 29, 'Wednesday', '09:30:00', '12:30:00', 8),
(58, 29, 'Thursday', '10:30:00', '13:30:00', 10),
(59, 30, 'Friday', '08:30:00', '11:30:00', 7),
(60, 30, 'Monday', '09:00:00', '12:00:00', 9),
(61, 31, 'Tuesday', '10:00:00', '13:00:00', 11),
(62, 31, 'Wednesday', '08:00:00', '11:00:00', 8),
(63, 32, 'Thursday', '09:30:00', '12:30:00', 10),
(64, 32, 'Friday', '10:30:00', '13:30:00', 12),
(65, 33, 'Monday', '08:30:00', '11:30:00', 7),
(66, 33, 'Tuesday', '09:00:00', '12:00:00', 9),
(67, 34, 'Wednesday', '10:00:00', '13:00:00', 6),
(68, 34, 'Thursday', '08:00:00', '11:00:00', 11),
(69, 35, 'Friday', '09:30:00', '12:30:00', 8),
(70, 35, 'Monday', '10:30:00', '13:30:00', 10),
(71, 36, 'Tuesday', '08:30:00', '11:30:00', 7),
(72, 36, 'Wednesday', '09:00:00', '12:00:00', 13),
(73, 37, 'Thursday', '10:00:00', '13:00:00', 6),
(74, 37, 'Friday', '08:00:00', '11:00:00', 12),
(75, 38, 'Monday', '09:00:00', '12:00:00', 8),
(76, 38, 'Tuesday', '10:30:00', '13:30:00', 11),
(77, 39, 'Wednesday', '08:30:00', '11:30:00', 7),
(78, 39, 'Thursday', '09:00:00', '12:00:00', 9),
(79, 40, 'Friday', '10:00:00', '13:00:00', 12),
(80, 40, 'Monday', '08:00:00', '11:00:00', 10),
(81, 41, 'Tuesday', '09:30:00', '12:30:00', 9),
(82, 41, 'Wednesday', '10:30:00', '13:30:00', 7),
(83, 42, 'Thursday', '08:30:00', '11:30:00', 12),
(84, 42, 'Friday', '09:00:00', '12:00:00', 8),
(85, 43, 'Monday', '10:00:00', '13:00:00', 11),
(86, 43, 'Tuesday', '08:00:00', '11:00:00', 9),
(87, 44, 'Wednesday', '09:30:00', '12:30:00', 6),
(88, 44, 'Thursday', '10:30:00', '13:30:00', 12),
(89, 45, 'Friday', '08:30:00', '11:30:00', 8),
(90, 45, 'Monday', '09:00:00', '12:00:00', 10);

	SELECT * 
FROM DoctorSchedule;


-- Insert data into the PastAppointment table
INSERT INTO PastAppointment (patient_id, date, time, department_id, doctor_id, status) 
VALUES
(1, '2023-09-04', '10:00:00', 16, 1, 'completed'),
(19, '2023-09-05', '10:00:00', 17, 6, 'completed'),
(2, '2023-10-10', '09:00:00', 18, 11, 'completed'),
(13, '2023-10-16', '09:00:00', 17, 8, 'completed'),
(15, '2023-10-23', '10:00:00', 16, 2, 'completed'),
(1, '2023-11-07', '10:00:00', 16, 2, 'completed'),
(9, '2023-11-14', '11:00:00', 19, 16, 'completed'),
(7, '2023-11-15', '10:00:00', 19, 19, 'completed'),
(15, '2023-12-07', '09:00:00', 18, 14, 'completed'),
(1, '2023-12-12', '09:00:00', 16, 1, 'completed'),
(15, '2023-12-18', '11:00:00', 16, 2, 'completed'),
(6, '2023-12-20', '10:00:00', 18, 11, 'completed'),
(3, '2023-12-27', '08:00:00', 17, 6, 'completed'),
(5, '2024-01-03', '11:00:00', 19, 16, 'completed'),
(15, '2024-01-08', '10:00:00', 16, 1, 'completed'),
(10, '2024-01-11', '10:00:00', 18, 14, 'completed'),
(4, '2024-02-05', '09:00:00', 17, 8, 'completed'),
(10, '2024-02-07', '11:00:00', 19, 16, 'completed'),
(17, '2024-02-09', '11:00:00', 20, 25, 'completed'),
(3, '2024-03-01', '09:00:00', 17, 10, 'completed');


	SELECT * 
FROM PastAppointment;


-- Insert data into the MedicalRecord table
INSERT INTO MedicalRecord (patient_id, pastappointment_id) VALUES
(1, 1),
(19, 2),
(2, 3),
(13, 4),
(15, 5),
(1, 6),
(9, 7),
(7, 8),
(15, 9),
(1, 10),
(15, 11),
(6, 12),
(3, 13),
(5, 14),
(15, 15),
(10, 16),
(4, 17),
(10, 18),
(17, 19),
(3, 20);


	SELECT * 
FROM MedicalRecord

-- Insert data into the Diagnosis table
INSERT INTO Diagnosis (record_id, diagnosis, doctor_id) VALUES
(1, 'Cancer', 1),
(2, 'Abdominal pain', 6),
(3, 'Chest pain', 11),
(4, 'Heartburn', 8),
(5, 'Cancer', 2),
(6, 'Cancer', 2),
(7, 'Balance problem', 16),
(8, 'Slurred speech', 19),
(9, 'Heart problem', 14),
(10, 'Cancer', 1),
(11, 'Cancer', 2),
(12, 'Heart problem', 11),
(13, 'Nausea', 6),
(14, 'Balance problem', 16),
(15, 'Cancer', 1),
(16, 'Chest pain', 14),
(17, 'Abdominal pain', 8),
(18, 'Slurred speech', 16),
(19, 'Joint pain', 25),
(20, 'Nausea', 10);


	SELECT * 
FROM Diagnosis

-- Insert data into the Medicine table
INSERT INTO Medicine (record_id, medicine_name, doctor_id) VALUES
(1, 'Paclitaxel', 1),
(2, 'Acetaminophen', 6),
(3, 'Acetaminophen', 11),
(4, 'Omeprazole', 8),
(5, 'Paclitaxel', 2),
(6, 'Paclitaxel', 2),
(7, 'Carbamazepine', 16),
(8, 'Carbamazepine', 19),
(9, 'Omeprazole', 14),
(10, 'Paclitaxel', 1),
(11, 'Paclitaxel', 2),
(12, 'Omeprazole', 11),
(13, 'Metoclopramide', 6),
(14, 'Carbamazepine', 16),
(15, 'Paclitaxel', 1),
(16, 'Acetaminophen', 14),
(17, 'Acetaminophen', 8),
(18, 'Carbamazepine', 16),
(19, 'Acetaminophen', 25),
(20, 'Metoclopramide', 10);



	SELECT * 
FROM Medicine

-- Insert data into the Allergy table
INSERT INTO Allergy (record_id, patient_id, allergy, doctor_id)
VALUES
(1, 1, 'carboplatin', 1),
(2, 19, 'sulfasalazine', 6),
(3, 2, 'amoxicillin', 11),
(4, 13, 'amoxicillin', 8),
(5, 15, 'carboplatin', 2),
(6, 1, 'carboplatin', 2),
(7, 9, 'morphine', 16),
(8, 7, 'morphine', 19),
(9, 15, 'morphine', 14),
(10, 1, 'carboplatin', 1),
(11, 15, 'carboplatin', 2),
(12, 6, 'morphine', 11),
(13, 3, 'morphine', 6),
(14, 5, 'ampicillin', 16),
(15, 15, 'carboplatin', 1),
(16, 10, 'amoxicillin', 14),
(17, 4, 'sulfasalazine', 8),
(18, 10, 'ampicillin', 16),
(19, 17, 'amoxicillin', 25),
(20, 3, 'morphine', 10);


	SELECT * 
FROM Allergy


-- Insert data into the ReviewFeedback table
INSERT INTO ReviewFeedback (patient_id, doctor_id, review_text, rating, pastappointment_id)
VALUES
    (1, 1, 'Attentive, thorough, and compassionate', 4, 1),
    (19, 6, 'Highly recommend!', 4, 2),
    (2, 11, NULL, 1, 3),
    (13, 8, 'Attentive, knowledgeable, and caring', 4, 4),
    (15, 2, 'Grateful for the positive experience', 4, 5),
    (1, 2, NULL, NULL, 6),
    (9, 16, 'Professional, knowledgeable, and empathetic', 4, 7),
    (7, 19, NULL, NULL, 8),
    (15, 14, 'Approachable, patient, and understanding.', 4, 9),
    (1, 1, NULL, NULL, 10),
    (15, 2, 'Excellent care from Dr', 5, 11),
    (6, 11, NULL, NULL, 12),
    (3, 6, 'Made me feel comfortable and well-informed.', 4, 13),
    (5, 16, 'Dr. provided exceptional care', 5, 14),
    (15, 1, NULL, 2, 15),
    (10, 14, 'Friendly, informative, and genuinely concerned', 5, 16),
    (4, 8, NULL, NULL, 17),
    (10, 16, 'Fantastic!', 5, 18),
    (17, 25, 'A truly wonderful doctor', 5, 19),
    (3, 10, NULL, 1, 20);


	SELECT * 
FROM ReviewFeedback

-- Insert data into CurrentAppointment table
INSERT INTO CurrentAppointment (patient_id, date, time, department_id, doctor_id, status)
VALUES
(1, '2024-04-02', '10:00:00', 16, 1, 'booked'),
(3, '2024-04-02', '10:30:00', 16, 1, 'booked'),
(6, '2024-04-02', '11:00:00', 16, 1, 'booked'),
(7, '2024-04-02', '11:00:00', 16, 1, 'pending'),
(15, '2024-04-02', '10:00:00', 16, 2, 'booked'),
(9, '2024-04-09', '10:00:00', 19, 16, 'booked'),
(13, '2024-04-09', '10:00:00', 19, 16, 'booked'),
(12, '2024-04-02', '11:00:00', 16, 1, 'pending'),
(1, '2024-04-09', '10:00:00', 19, 16, 'pending'),
(15, '2024-04-10', '09:00:00', 18, 14, 'booked'),
(2, '2024-04-08', '09:00:00', 16, 1, 'booked'),
(10, '2024-04-02', '10:00:00', 19, 6, 'booked'),
(6, '2024-04-03', '10:00:00', 18, 11, 'booked'),
(5, '2024-04-03', '10:00:00', 19, 19, 'booked'),
(3, '2024-04-03', '10:00:00', 18, 14, 'booked'),
(4, '2024-04-04', '11:00:00', 19, 19, 'booked'),
(9, '2024-04-04', '11:00:00', 19, 19, 'booked'),
(17, '2024-04-04', '10:00:00', 18, 14, 'booked'),
(13, '2024-04-05', '11:00:00', 20, 25, 'booked'),
(10, '2024-04-05', '11:00:00', 17, 10, 'booked');

	SELECT * 
FROM CurrentAppointment

INSERT INTO CurrentAppointment (patient_id, date, time, department_id, doctor_id, status)
VALUES
(1, '2022-06-02', '10:00:00', 18, 20, 'booked')

-- Task 1 part 1 Q3
--List all the patients with older than 40 and have Cancer in diagnosis.
SELECT DISTINCT 
    p.patient_id, 
    CONCAT(p.first_name, ' ', COALESCE(p.middle_name, ''), ' ', p.last_name) AS fullname, 
    DATEDIFF(YEAR, p.dob, GETDATE()) AS age, p.gender,
    d.diagnosis
FROM 
    Patient p
JOIN 
    MedicalRecord mr ON p.patient_id = mr.patient_id
JOIN 
    Diagnosis d ON mr.record_id = d.record_id
WHERE 
    DATEDIFF(YEAR, p.dob, GETDATE()) > 40 AND 
    d.diagnosis = 'Cancer';

		
SELECT * 
FROM Patient

SELECT * 
FROM MedicalRecord

SELECT * 
FROM Diagnosis

-- Task 1 Part 1 Q 4(a)
--Search the database of the hospital for matching character strings by name of medicine. 
--Results should be sorted with most recent medicine prescribed date first.
CREATE PROCEDURE SearchMedicineByName
    @medicineName NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.patient_id, 
        p.first_name + ' ' + COALESCE(p.middle_name, '') + ' ' + p.last_name AS FullName, 
        m.medicine_name,
        pa.date AS PrescriptionDate
    FROM 
        Patient p
    JOIN 
        MedicalRecord mr ON p.patient_id = mr.patient_id
    JOIN 
        PastAppointment pa ON mr.pastappointment_id = pa.pastappointment_id
    JOIN 
        Medicine m ON mr.record_id = m.record_id
    WHERE 
       m.medicine_name LIKE '%' + @medicineName + '%'
    ORDER BY 
        pa.date DESC;
END;

EXEC SearchMedicineByName 'et';

-- Task 1 Part 1 Q 4(a)
--Search the database of the hospital for matching character strings by name of medicine. 
--Results should be sorted with most recent medicine prescribed date first.
CREATE FUNCTION dbo.SearchMedicineByNameFunction(@medicineName NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        p.patient_id, 
        p.first_name + ' ' + COALESCE(p.middle_name, '') + ' ' + p.last_name AS FullName, 
        m.medicine_name,
        pa.date AS PrescriptionDate
    FROM 
        Patient p
    JOIN 
        MedicalRecord mr ON p.patient_id = mr.patient_id
    JOIN 
        PastAppointment pa ON mr.pastappointment_id = pa.pastappointment_id
    JOIN 
        Medicine m ON mr.record_id = m.record_id
    WHERE 
        m.medicine_name LIKE '%' + @medicineName + '%'
);

SELECT *
FROM dbo.SearchMedicineByNameFunction('et')
ORDER BY PrescriptionDate DESC;

-- Task 1 Part 1 Q 4(b)
--Return a full list of diagnosis and allergies for a specific patient who has an appointment today (i.e., the system date when the query is run)
CREATE PROCEDURE GetDiagnosisAndAllergiesForPatient
    @patientId INT
AS
BEGIN
    DECLARE @appointmentDate DATE = CAST(GETDATE() AS DATE);
    
    SELECT 
        p.patient_id,
        CONCAT(p.first_name, ' ', ISNULL(p.middle_name, ''), ' ', p.last_name) AS PatientName, p.gender, p.blood_group,
        d.diagnosis,
        a.allergy
    FROM 
        Patient p
    LEFT JOIN 
        MedicalRecord mr ON p.patient_id = mr.patient_id
    LEFT JOIN 
        Diagnosis d ON mr.record_id = d.record_id
    LEFT JOIN 
        Allergy a ON mr.record_id = a.record_id
    LEFT JOIN 
        CurrentAppointment ca ON p.patient_id = ca.patient_id
    WHERE 
        p.patient_id = @patientId
        AND ca.date = @appointmentDate;
END;

EXEC GetDiagnosisAndAllergiesForPatient @patientId = 15; -- Replace patientId with the desired value

-- Task 1 Part 1 Q 4(b)
--Return a full list of diagnosis and allergies for a specific patient who has an appointment today (i.e., the system date when the query is run)
CREATE PROCEDURE GetDiagnosisAndAllergiesForCurrentPatient
    @patientId INT
AS
BEGIN
    DECLARE @appointmentDate DATE = CAST(GETDATE() AS DATE);
    
    IF EXISTS (SELECT 1 FROM CurrentAppointment WHERE patient_id = @patientId AND date = @appointmentDate)
    BEGIN
        SELECT DISTINCT
            p.patient_id,
            CONCAT(p.first_name, ' ', ISNULL(p.middle_name, ''), ' ', p.last_name) AS PatientName, 
            p.gender, 
            p.blood_group,
            ca.currentappointment_id AS CurrentAppointmentID,
            d.diagnosis,
            a.allergy
        FROM 
            Patient p
        LEFT JOIN 
            MedicalRecord mr ON p.patient_id = mr.patient_id
        LEFT JOIN 
            Diagnosis d ON mr.record_id = d.record_id
        LEFT JOIN 
            Allergy a ON mr.record_id = a.record_id
        LEFT JOIN 
            CurrentAppointment ca ON p.patient_id = ca.patient_id
        WHERE 
            p.patient_id = @patientId
            AND ca.date = @appointmentDate;
    END
    ELSE
    BEGIN
        PRINT 'No appointment for this patient today';
    END
END;

EXEC GetDiagnosisAndAllergiesForCurrentPatient @patientId = 19;

-- Task 1 Part 1 Q 4(b)
--Return a full list of diagnosis and allergies for a specific patient who has an appointment today (i.e., the system date when the query is run)
CREATE FUNCTION GetDiagnosisAndAllergiesForCurrentPatientFunction
(
    @patientId INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT
        p.patient_id,
        CONCAT(p.first_name, ' ', ISNULL(p.middle_name, ''), ' ', p.last_name) AS PatientName, 
        p.gender, 
        p.blood_group,
        ca.currentappointment_id AS CurrentAppointmentID,
        d.diagnosis,
        a.allergy
    FROM 
        Patient p
    LEFT JOIN 
        MedicalRecord mr ON p.patient_id = mr.patient_id
    LEFT JOIN 
        Diagnosis d ON mr.record_id = d.record_id
    LEFT JOIN 
        Allergy a ON mr.record_id = a.record_id
    LEFT JOIN 
        CurrentAppointment ca ON p.patient_id = ca.patient_id
    WHERE 
        p.patient_id = @patientId
        AND ca.date = CAST(GETDATE() AS DATE)
);
SELECT * FROM GetDiagnosisAndAllergiesForCurrentPatientFunction(19);

-- Task 1 Part 1 Q 4(c)
--Update the details for an existing doctor
CREATE PROCEDURE UpdateDoctorDetails
    @doctorId INT,
    @roomNo NVARCHAR(10) = NULL,
    @subSpecialization NVARCHAR(100) = NULL,
    @departmentId TINYINT = NULL,
    @dayOfWeek NVARCHAR(10) = NULL,
    @startTime TIME = NULL,
    @endTime TIME = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
         -- Update doctor's room number and sub-specialization
        IF @roomNo IS NOT NULL OR @subSpecialization IS NOT NULL
        BEGIN
            UPDATE Doctor
            SET 
                room_no = ISNULL(@roomNo, room_no),
                sub_specialization = ISNULL(@subSpecialization, sub_specialization)
            WHERE 
                doctor_id = @doctorId;
        END
		-- Update doctor's department
        IF @departmentId IS NOT NULL
        BEGIN
            UPDATE Doctor
            SET 
                department_id = @departmentId
            WHERE 
                doctor_id = @doctorId;
        END
		-- Update doctor's schedule
        IF @dayOfWeek IS NOT NULL AND @startTime IS NOT NULL AND @endTime IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM DoctorSchedule WHERE doctor_id = @doctorId AND day_of_week = @dayOfWeek)
            BEGIN
                UPDATE DoctorSchedule
                SET 
                    start_time = @startTime,
                    end_time = @endTime
                WHERE 
                    doctor_id = @doctorId
                    AND day_of_week = @dayOfWeek;
            END
            ELSE
            BEGIN
                INSERT INTO DoctorSchedule (doctor_id, day_of_week, start_time, end_time)
                VALUES (@doctorId, @dayOfWeek, @startTime, @endTime);
            END
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

	EXEC UpdateDoctorDetails 
	@doctorId = 45,
    @roomNo = '560',
    @subSpecialization = 'Mohs Surgery ',
	@departmentId = 24,
	@dayOfWeek = 'Friday',
    @startTime = '08:30:00',
    @endTime = '11:30:00';

	CREATE PROCEDURE UpdateDoctorDetails1
    @doctorId INT,
    @roomNo NVARCHAR(10) = NULL,
    @subSpecialization NVARCHAR(100) = NULL,
    @departmentId TINYINT = NULL,
    @dayOfWeek NVARCHAR(10) = NULL,
    @startTime TIME = NULL,
    @endTime TIME = NULL
AS
BEGIN
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE; -- Setting transaction isolation level
    
    BEGIN TRY
        BEGIN TRANSACTION;
         -- Update doctor's room number and sub-specialization
        IF @roomNo IS NOT NULL OR @subSpecialization IS NOT NULL
        BEGIN
            UPDATE Doctor
            SET 
                room_no = ISNULL(@roomNo, room_no),
                sub_specialization = ISNULL(@subSpecialization, sub_specialization)
            WHERE 
                doctor_id = @doctorId;
        END
		-- Update doctor's department
        IF @departmentId IS NOT NULL
        BEGIN
            UPDATE Doctor
            SET 
                department_id = @departmentId
            WHERE 
                doctor_id = @doctorId;
        END
		-- Update doctor's schedule
        IF @dayOfWeek IS NOT NULL AND @startTime IS NOT NULL AND @endTime IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM DoctorSchedule WHERE doctor_id = @doctorId AND day_of_week = @dayOfWeek)
            BEGIN
                UPDATE DoctorSchedule
                SET 
                    start_time = @startTime,
                    end_time = @endTime
                WHERE 
                    doctor_id = @doctorId
                    AND day_of_week = @dayOfWeek;
            END
            ELSE
            BEGIN
                INSERT INTO DoctorSchedule (doctor_id, day_of_week, start_time, end_time)
                VALUES (@doctorId, @dayOfWeek, @startTime, @endTime);
            END
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;

	EXEC UpdateDoctorDetails1 
	@doctorId = 45,
    @roomNo = '560',
    @subSpecialization = 'Mohs Surgery ',
	@departmentId = 24,
	@dayOfWeek = 'Friday',
    @startTime = '08:30:00',
    @endTime = '11:30:00';

CREATE LOGIN hospital_user WITH PASSWORD = 'pass123word';

	-- Create a new user
CREATE USER hospital_user FOR LOGIN hospital_user;

-- Create a new role
CREATE ROLE hospital_staff;

-- Grant SELECT permission on the Doctor table to the role
GRANT SELECT ON dbo.Doctor TO hospital_staff;

-- Grant EXECUTE permission on the UpdateDoctorDetails stored procedure to the role
GRANT EXECUTE ON dbo.UpdateDoctorDetails TO hospital_staff;

-- Add the user to the role
ALTER ROLE hospital_staff ADD MEMBER hospital_user;

select * from CurrentAppointment
select * from PastAppointment
select * from MedicalRecord
select * from Diagnosis

--Task 1 Part 1 Q 4(d)
--Delete the appointment who status is already completed.
--Stored procedure to delete the appointment whose status is already completed in CurrentAppointment table
CREATE PROCEDURE CompleteAppointmentsAndMoveToPastAppointment
AS
BEGIN
    DECLARE @CurrentDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @CurrentTime TIME = CAST(GETDATE() AS TIME);
    
    -- Update appointments in CurrentAppointment table to 'completed'
    UPDATE CurrentAppointment
    SET status = 'completed'
    WHERE date <= @CurrentDate
    AND (date < @CurrentDate OR time <= @CurrentTime);

    -- Insert completed appointments into PastAppointment table
    INSERT INTO PastAppointment (patient_id, date, time, department_id, doctor_id, status)
    SELECT patient_id, date, time, department_id, doctor_id, 'completed'
    FROM CurrentAppointment
    WHERE status = 'completed'
    AND (date < @CurrentDate OR (date = @CurrentDate AND time <= @CurrentTime));
    
 -- Delete completed appointments from CurrentAppointment table
    DELETE FROM CurrentAppointment
    WHERE status = 'completed'
    AND (date < @CurrentDate OR (date = @CurrentDate AND time <= @CurrentTime));
END

EXEC CompleteAppointmentsAndMoveToPastAppointment;

GRANT EXECUTE ON dbo.CompleteAppointmentsAndMoveToPastAppointment TO hospital_user;

SELECT * 
FROM Doctor

SELECT * 
FROM DoctorSchedule

SELECT * 
FROM Patient

SELECT * 
FROM MedicalRecord

SELECT * 
FROM PastAppointment

SELECT * 
FROM Medicine


SELECT * 
FROM ReviewFeedback


-- Task 1 Part 1 Q 5
--View showing view the appointment date and time, showing all previous and current appointments for all doctors, 
--and including details of the department (the doctor is associated with), doctor’s specialty and any associate 
--review/feedback given for a doctor.
--First view
	DROP VIEW IF EXISTS AllDoctorsAppointmentDetailsView;
	CREATE VIEW AllDoctorsAppointmentDetailsView AS
SELECT 
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
    dep.specialization AS Department,
    d.sub_specialization AS DoctorSubSpecialization,
    appt.date AS AppointmentDate,
    appt.time AS AppointmentTime,
    CASE WHEN pa.pastappointment_id IS NOT NULL THEN rf.review_text ELSE NULL END AS ReviewText,
    CASE WHEN pa.pastappointment_id IS NOT NULL THEN rf.rating ELSE NULL END AS Rating
FROM 
    Doctor d
LEFT JOIN 
    Department dep ON d.department_id = dep.department_id
LEFT JOIN (
    SELECT doctor_id, date, time
    FROM CurrentAppointment
    UNION ALL
    SELECT doctor_id, date, time
    FROM PastAppointment
) AS appt ON d.doctor_id = appt.doctor_id
LEFT JOIN 
    ReviewFeedback rf ON d.doctor_id = rf.doctor_id
LEFT JOIN 
    PastAppointment pa ON d.doctor_id = pa.doctor_id AND pa.date = appt.date
WHERE
    (pa.pastappointment_id = rf.pastappointment_id OR pa.pastappointment_id IS NULL)
    AND appt.date IS NOT NULL
    AND appt.time IS NOT NULL;

SELECT * FROM AllDoctorsAppointmentDetailsView;


-- Task 1 Part 1 Q 5
--View showing view the appointment date and time, showing all previous and current appointments for all doctors, 
--and including details of the department (the doctor is associated with), doctor’s specialty and any associate 
--review/feedback given for a doctor.
--Additional views
DROP VIEW IF EXISTS AllDoctorsAppointmentDetailsView_1;
CREATE VIEW AllDoctorsAppointmentDetailsView_1 AS
SELECT 
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
    dep.specialization AS Department,
    d.sub_specialization AS DoctorSubSpecialization,
    appt.date AS AppointmentDate,
    appt.time AS AppointmentTime,
    CASE WHEN pa.pastappointment_id IS NOT NULL THEN rf.review_text ELSE NULL END AS ReviewText,
    CASE WHEN pa.pastappointment_id IS NOT NULL THEN rf.rating ELSE NULL END AS Rating
FROM 
    Doctor d
LEFT JOIN 
    Department dep ON d.department_id = dep.department_id
LEFT JOIN (
    SELECT doctor_id, date, time
    FROM CurrentAppointment
    UNION ALL
    SELECT doctor_id, date, time
    FROM PastAppointment
) AS appt ON d.doctor_id = appt.doctor_id
LEFT JOIN 
    ReviewFeedback rf ON d.doctor_id = rf.doctor_id
LEFT JOIN 
    PastAppointment pa ON d.doctor_id = pa.doctor_id AND pa.date = appt.date
WHERE
    pa.pastappointment_id = rf.pastappointment_id OR pa.pastappointment_id IS NULL;

	SELECT * FROM AllDoctorsAppointmentDetailsView_1;

-- Task 1 Part 1 Q 5
--View showing view the appointment date and time, showing all previous and current appointments for all doctors, 
--and including details of the department (the doctor is associated with), doctor’s specialty and any associate 
--review/feedback given for a doctor.
--Additional views
DROP VIEW IF EXISTS AllDoctorsAppointmentDetailsView_2;
CREATE VIEW AllDoctorsAppointmentDetailsView_2 AS
SELECT 
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
    dep.specialization AS Department,
    d.sub_specialization AS DoctorSubSpecialization,
    COUNT(appt.date) AS TotalAppointments,
    MAX(appt.date) AS LatestAppointmentDate,
    MAX(appt.time) AS LatestAppointmentTime,
    AVG(rf.rating) AS AverageRating
FROM 
    Doctor d
LEFT JOIN 
    Department dep ON d.department_id = dep.department_id
LEFT JOIN (
    SELECT doctor_id, date, time
    FROM CurrentAppointment
    UNION ALL
    SELECT doctor_id, date, time
    FROM PastAppointment
) AS appt ON d.doctor_id = appt.doctor_id
LEFT JOIN 
    ReviewFeedback rf ON d.doctor_id = rf.doctor_id
LEFT JOIN 
    PastAppointment pa ON d.doctor_id = pa.doctor_id AND pa.date = appt.date
WHERE
    (pa.pastappointment_id = rf.pastappointment_id OR pa.pastappointment_id IS NULL)
    AND appt.date IS NOT NULL
    AND appt.time IS NOT NULL
GROUP BY
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name),
    dep.specialization,
    d.sub_specialization;

	SELECT * FROM AllDoctorsAppointmentDetailsView_2;

		SELECT * FROM PastAppointment
		SELECT * FROM Department
		SELECT * FROM Doctor


--Task 1 Part 1 Q 6
--Create a trigger so that the current state of an appointment can be changed to available when it is cancelled.
--Update the 'booked' status to 'cancelled'
UPDATE CurrentAppointment
SET status = 'cancelled'
WHERE currentappointment_id = 1; -- Updating the status of currentappointment_id =6

--Creating trigger to automate the change of 'pending' status of the appointment for same 
--doctor from same department on the same day of appointment cancellation

CREATE TRIGGER trg_CancelledAppointment
ON CurrentAppointment
AFTER UPDATE
AS
BEGIN
    -- Check if the status of any appointment has been changed to 'cancelled'
    IF UPDATE(status)
    BEGIN
        -- Update pending appointments for the same doctor, department, and day to 'available'
        UPDATE ca
        SET status = 'available'
        FROM CurrentAppointment ca
        JOIN inserted i ON ca.doctor_id = i.doctor_id
                        AND ca.department_id = i.department_id
                        AND ca.date = i.date
        WHERE ca.status = 'pending';
    END
END;


-- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
--count alone
			SELECT COUNT(*) AS Completed_Appointments
FROM PastAppointment pa
JOIN Doctor d ON pa.doctor_id = d.doctor_id
JOIN Department dept ON d.department_id = dept.department_id
WHERE dept.specialization = 'Gastroenterology'
    AND pa.status = 'completed';

-- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
--count and department specialization
	SELECT  
    pa.department_id,
    dept.specialization AS DepartmentSpecialization,
    COUNT(*) AS Completed_Appointments
FROM 
    PastAppointment pa
JOIN 
    Doctor d ON pa.doctor_id = d.doctor_id
JOIN 
    Department dept ON d.department_id = dept.department_id
WHERE 
    dept.specialization = 'Gastroenterology'
    AND pa.status = 'completed'
GROUP BY
    pa.department_id, dept.specialization;

-- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
-- past appointments for doctors having specialization 'Gastroenterology'
SELECT pa.*
FROM PastAppointment pa
JOIN Doctor d ON pa.doctor_id = d.doctor_id
JOIN Department dept ON d.department_id = dept.department_id
WHERE dept.specialization = 'Gastroenterology'
  AND pa.status = 'completed';

 -- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
--past appointments corresponding to count with doctors name 
SELECT 
    pa.pastappointment_id, pa.patient_id, pa.date, pa.department_id, dept.specialization AS DepartmentSpecialization,
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
    d.sub_specialization AS DoctorSubSpecialization,
    pa.status
FROM 
    PastAppointment pa
JOIN 
    Doctor d ON pa.doctor_id = d.doctor_id
JOIN 
    Department dept ON d.department_id = dept.department_id
WHERE 
    dept.specialization = 'Gastroenterology'
    AND pa.status = 'completed';

-- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
-- count displayed in message, and results in table. 
DECLARE @Count INT;

SELECT 
    pa.pastappointment_id, pa.patient_id, pa.date, pa.department_id, dept.specialization AS DepartmentSpecialization,
    d.doctor_id,
    CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
    d.sub_specialization AS DoctorSubSpecialization,
    pa.status
FROM 
    PastAppointment pa
JOIN 
    Doctor d ON pa.doctor_id = d.doctor_id
JOIN 
    Department dept ON d.department_id = dept.department_id
WHERE 
    dept.specialization = 'Gastroenterology'
    AND pa.status = 'completed'; 

SELECT @Count = COUNT(*)
FROM 
    PastAppointment pa
JOIN 
    Doctor d ON pa.doctor_id = d.doctor_id
JOIN 
    Department dept ON d.department_id = dept.department_id
WHERE 
    dept.specialization = 'Gastroenterology'
    AND pa.status = 'completed'; 

PRINT 'The number of completed appointments of doctors having the specialization  ''Gastroenterology'' is ' + CAST(@Count AS VARCHAR);

-- Task 1 Part 1 Q 7
--identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.
--stored procedure for same
CREATE PROCEDURE GetGastroenterologyAppointments
AS
BEGIN
    DECLARE @Count INT;
	    -- Retrieve appointment details for Gastroenterology department
    SELECT 
        pa.pastappointment_id, pa.patient_id, pa.date, pa.department_id, dept.specialization AS DepartmentSpecialization,
        d.doctor_id,
        CONCAT(d.first_name, ' ', ISNULL(d.middle_name, ''), ' ', d.last_name) AS DoctorName,
        d.sub_specialization AS DoctorSubSpecialization,
        pa.status
    FROM 
        PastAppointment pa
    JOIN 
        Doctor d ON pa.doctor_id = d.doctor_id
    JOIN 
        Department dept ON d.department_id = dept.department_id
    WHERE 
        dept.specialization = 'Gastroenterology'
        AND pa.status = 'completed'; 

    -- Retrieve count of completed appointments for Gastroenterology department
    SELECT @Count = COUNT(*)
    FROM 
        PastAppointment pa
    JOIN 
        Doctor d ON pa.doctor_id = d.doctor_id
    JOIN 
        Department dept ON d.department_id = dept.department_id
    WHERE 
        dept.specialization = 'Gastroenterology'
        AND pa.status = 'completed'; 
		    -- Print the count of completed appointments
    PRINT 'The number of completed appointments of doctors having the specialization ''Gastroenterology'' is ' + CAST(@Count AS VARCHAR);
END
EXEC GetGastroenterologyAppointments;



--Additional stored procedures
--Retrieve patient history
CREATE PROCEDURE sp_GetPatientHistory
@patient_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Retrieve past appointments
    SELECT pa.date AS appointment_date, pa.time AS appointment_time, d.department_id, d.specialization AS department, doc.doctor_id, CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name, pa.status
    FROM PastAppointment pa
    INNER JOIN Department d ON pa.department_id = d.department_id
    INNER JOIN Doctor doc ON pa.doctor_id = doc.doctor_id
    WHERE pa.patient_id = @patient_id;
    
    -- Retrieve diagnosis
    SELECT d.diagnosis_id, d.diagnosis, doc.doctor_id, CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name
    FROM Diagnosis d
    INNER JOIN Doctor doc ON d.doctor_id = doc.doctor_id
    WHERE d.record_id IN (SELECT record_id FROM MedicalRecord WHERE patient_id = @patient_id);
    
    -- Retrieve prescribed medicines
    SELECT m.medicine_name, doc.doctor_id, CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name
    FROM Medicine m
    INNER JOIN Doctor doc ON m.doctor_id = doc.doctor_id
    WHERE m.record_id IN (SELECT record_id FROM MedicalRecord WHERE patient_id = @patient_id);
    
    -- Retrieve allergies
    SELECT a.allergy, doc.doctor_id, CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name
    FROM Allergy a
    INNER JOIN Doctor doc ON a.doctor_id = doc.doctor_id
    WHERE a.record_id IN (SELECT record_id FROM MedicalRecord WHERE patient_id = @patient_id);
    
    -- Retrieve review feedback
    SELECT rf.review_id, rf.review_text, rf.rating, doc.doctor_id, CONCAT(doc.first_name, ' ', doc.last_name) AS doctor_name
    FROM ReviewFeedback rf
    INNER JOIN Doctor doc ON rf.doctor_id = doc.doctor_id
    WHERE rf.patient_id = @patient_id;
END


EXEC sp_GetPatientHistory @patient_id = 1;

--Additional stored procedure
--retrieve patients of a particular doctor
CREATE PROCEDURE sp_GetDoctorPatients
    @doctor_id INT
AS
BEGIN
    SELECT DISTINCT p.*
    FROM Patient p
    INNER JOIN MedicalRecord mr ON p.patient_id = mr.patient_id
    INNER JOIN PastAppointment pa ON pa.patient_id = p.patient_id
    WHERE pa.doctor_id = @doctor_id;
END;

EXEC sp_GetDoctorPatients @doctor_id = 1;


--Additional functions
--Retrieve the patients who visited GP of the hospital in a specifc year and month with department and doctor visited

	  SELECT * 
FROM PastAppointment;


CREATE FUNCTION fn_GetPatientsVisitedByMonthYearDeptDate
(
    @year INT,
    @month INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT DISTINCT P.*, PA.date AS visit_date, D.specialization AS department, CONCAT(DO.first_name, ' ', DO.last_name) AS doctor
    FROM PastAppointment PA
    INNER JOIN Patient P ON P.patient_id = PA.patient_id
    INNER JOIN Doctor DO ON PA.doctor_id = DO.doctor_id
    INNER JOIN Department D ON PA.department_id = D.department_id
    WHERE YEAR(PA.date) = @year AND MONTH(PA.date) = @month
);

SELECT * FROM fn_GetPatientsVisitedByMonthYearDeptDate(2023, 10);

--Additional Function
--Retrieve the list of patients who left the hospital 
CREATE FUNCTION fn_GetPatientsLeftHospitalWithDetails
(
)
RETURNS TABLE
AS
RETURN
(
    SELECT P.*, A.address1, A.address2, A.city, A.county, A.postcode,
           COALESCE(PPI.email_address, PPI.telephone_number) AS contact_info
    FROM Patient P
    INNER JOIN Address A ON P.patient_id = A.patient_id
    LEFT JOIN PatientPortalInfo PPI ON P.patient_id = PPI.patient_id
    WHERE P.date_left IS NOT NULL
);

-- Execute the function
SELECT * FROM fn_GetPatientsLeftHospitalWithDetails();

--Additional Views
-- Review text and rating of a specific doctor
CREATE VIEW DoctorReviewTexts AS
SELECT 
    R.review_id,
    R.review_text,
    R.rating,
    P.patient_id,
    CONCAT(P.first_name, ' ', COALESCE(P.middle_name, ''), ' ', P.last_name) AS patient_name,
    R.doctor_id
FROM 
    ReviewFeedback R
INNER JOIN 
    Patient P ON R.patient_id = P.patient_id;

	SELECT *
FROM DoctorReviewTexts
WHERE doctor_id = 6;

--Additional Trigger
-- A trigger that keeps the patients left to a new table 'RemovedPatients'
CREATE TABLE RemovedPatients (
    patient_id INT PRIMARY KEY,
    first_name NVARCHAR(50),
    middle_name NVARCHAR(50),
    last_name NVARCHAR(50),
    dob DATE,
    insurance NVARCHAR(50),
    gender NVARCHAR(50),
    blood_group NVARCHAR(10),
    date_left DATE
);
CREATE TRIGGER trg_PatientRemoval
ON Patient
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(date_left)
    BEGIN
        INSERT INTO RemovedPatients (patient_id, first_name, middle_name, last_name, dob, insurance, gender, blood_group, date_left)
        SELECT patient_id, first_name, middle_name, last_name, dob, insurance, gender, blood_group, date_left
        FROM inserted
        WHERE date_left IS NOT NULL;
    END
END;

UPDATE Patient
SET date_left = '2022-09-15'
WHERE patient_id = 8;
UPDATE Patient
SET date_left = '2023-05-30'
WHERE patient_id = 18;

SELECT *
FROM RemovedPatients

--creating schema, and granting, revoking privileges to login users namely hospital_user and non_hospital_user respectively
CREATE SCHEMA Patient;
GO
ALTER SCHEMA Patient TRANSFER dbo.Patient 
ALTER SCHEMA Patient TRANSFER dbo.Address
ALTER SCHEMA Patient TRANSFER dbo.PatientPortalInfo

CREATE LOGIN hospital_user WITH PASSWORD = 'pass123word';

CREATE USER hospital_user FOR LOGIN hospital_user;

GRANT SELECT ON SCHEMA :: Patient TO hospital_user;

GRANT SELECT, INSERT, DELETE, UPDATE ON Patient.Address
TO hospital_user WITH GRANT OPTION;

CREATE LOGIN non_hospital_user WITH PASSWORD = 'pass321word';

CREATE USER non_hospital_user FOR LOGIN non_hospital_user;

GRANT SELECT ON SCHEMA :: Patient TO non_hospital_user;

REVOKE INSERT, DELETE, UPDATE ON Patient.Address TO non_hospital_user;


-- Transfer table dbo.Patient from schema Patient to schema dbo
ALTER SCHEMA dbo TRANSFER Patient.Patient;

-- Transfer table dbo.Address from schema Patient to schema dbo
ALTER SCHEMA dbo TRANSFER Patient.Address;

-- Transfer table dbo.PatientPortalInfo from schema Patient to schema dbo
ALTER SCHEMA dbo TRANSFER Patient.PatientPortalInfo;

DROP SCHEMA Patient;

--code to get a list of non-clustered indexes in a database
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS ColumnName,
    ic.index_column_id AS ColumnOrder
FROM 
    sys.indexes AS i
INNER JOIN 
    sys.index_columns AS ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN 
    sys.columns AS c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE 
    i.type_desc = 'NONCLUSTERED'
ORDER BY 
    TableName, IndexName, ColumnOrder;

BACKUP DATABASE Hospital_GP_Management_Database
TO DISK ='C:\Hospital_GP_Management_Database_Restore\Hospital_GP_Management_Database_full.bak'
WITH CHECKSUM


RESTORE VERIFYONLY
FROM DISK ='C:\Hospital_GP_Management_Database_Restore\Hospital_GP_Management_Database_full.bak'
WITH CHECKSUM;


