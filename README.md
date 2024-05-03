# Database-Design-SQL-for-Data-Analysis
Hospital GP Management Database Design Proposal and Implementation in Microsoft SQL Server Management Studio using T-SQL

Imagine you are employed as a database developer consultant for a hospital. They are currently in the process of developing a new database system which they require for storing information on their patients, doctors, medical records (past appointments, diagnoses, medicines, medicine prescribed date, allergies), appointments, and departments. In your initial consultation with the hospital, you have gathered the information below. Please read the below carefully and continue to the task description.

Client Requirements
When a patient wants to register to the GP in the hospital, they need to provide their full name, address, date of birth and insurance. Also, they must create the username and password to allow them to sign into the patient portal. The system will store the patient’s data. Optionally, they can also provide an email address and telephone number. The patients will then book an appointment through patient’s portal. System checks doctor’s availability. Appointment details are stored, including date, time, department, status (pending, cancelled, or completed) and doctor.
When the patient arrives for the appointment, the doctors should check and review patient's medical record including past appointments, diagnoses, medicines, allergies. Doctor updates medical record with new diagnoses, and medicines. When a patient finishes his appointment and has seen the doctor, their status must be changed to completed and they can write a review/feedback for the doctor. If the patient has cancelled the appointment, he/she must rebook the appointment again. If the patient leaves the hospital system, the hospital wants to retain their information on the system, but they should keep a record of the date the patient left.

Task Details

As the database consultant, you are required to design the database system based on the information provided above, along with a number of associated database objects, such as stored procedures, user-defined functions, views and triggers. Your submission will take the form of working T-SQL statements required for the steps outlined below, a backup of the database created, and a report explaining and justifying your design decisions, and the process you followed to complete the tasks. You should include screenshots and the T-SQL statements within the report itself.
Part1:

1.You should design and normalise your proposed database into 3NF, fully explaining and justifying your database design decisions and documenting the process you have gone through to implement this design using T-SQL statements in Microsoft SQL Server Management Studio, using screenshots to support your explanation. All tables and
views must be created using T-SQL statements, which should be included in your report. Clearly highlight which column(s) are primary keys or foreign keys. You should also explain the data type used for each column and justify the reason for choosing this. You should also consider using constraints when creating your database to help ensure data integrity. You must include a database diagram as part of your submission. If you have made any additional assumptions aside from the information above when designing your database, you should clearly state these.
Create tables according to the scenario explained above which should include details on patients, doctors, medical records, appointments, and departments. Populate (Insert) the tables with the appropriate number of records (at least 7). You should also ensure the data you input allows you to adequately test that all the following queries.

Part2:
2.Add the constraint to check that the appointment date is not in the past.

3.List all the patients with older than 40 and have Cancer in diagnosis.

4.The hospital also requires stored procedures or user-defined functions to do the following things:

a)Search the database of the hospital for matching character strings by name of medicine. Results should be sorted with most recent medicine prescribed date first.
b)Return a full list of diagnosis and allergies for a specific patient who has an appointment today (i.e., the system date when the query is run)
c)Update the details for an existing doctor
d)Delete the appointment who status is already completed.

5.The hospitals wants to view the appointment date and time, showing all previous and current appointments for all doctors, and including details of the department (the doctor is associated with), doctor’s specialty and any associate review/feedback given for a doctor. You should create a view containing all the required information.

6.Create a trigger so that the current state of an appointment can be changed to available when it is cancelled.

7.Write a select query which allows the hospital to identify the number of completed appointments with the specialty of doctors as ‘Gastroenterologists’.

8.Within your report, you will also need to provide your client with advice and guidance on:

Data integrity and concurrency

Database security

Database backup and recovery

Generic information on these topics, which is not applied to the given scenario, is likely to score poorly.
To get more than a satisfactory work, you must use all of the below at least once in your database:

Views

Stored procedures

System functions and user defined functions

Triggers

SELECT queries which make use of joins and sub-queries.
