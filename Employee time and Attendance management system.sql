CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Department VARCHAR(50),
    HourlyRate DECIMAL(10, 2)
);
INSERT INTO Employees (EmployeeID, Name, Department, HourlyRate) VALUES (1, 'John Doe', 'IT', 25.00);
INSERT INTO Employees (EmployeeID, Name, Department, HourlyRate) VALUES (2, 'Jane Smith', 'HR', 20.00);
INSERT INTO Employees (EmployeeID, Name, Department, HourlyRate) VALUES (3, 'Michael Brown', 'Finance', 30.00);
INSERT INTO Employees (EmployeeID, Name, Department, HourlyRate) VALUES (4, 'Emily Davis', 'Marketing', 22.50);
INSERT INTO Employees (EmployeeID, Name, Department, HourlyRate) VALUES (5, 'Robert Wilson', 'IT', 27.50);
SELECT * FROM Employees;

CREATE TABLE Attendance (
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT,
    ClockIn TIMESTAMP,
    ClockOut TIMESTAMP,
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert records into Attendance table
INSERT INTO Attendance (EmployeeID, ClockIn, ClockOut)
VALUES (1, TO_TIMESTAMP('2025-01-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-01 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Attendance (EmployeeID, ClockIn, ClockOut)
VALUES (2, TO_TIMESTAMP('2025-01-02 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-02 17:30:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Attendance (EmployeeID, ClockIn, ClockOut)
VALUES (3, TO_TIMESTAMP('2025-01-03 09:15:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-03 18:15:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Attendance (EmployeeID, ClockIn, ClockOut)
VALUES (4, TO_TIMESTAMP('2025-01-04 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-04 17:00:00', 'YYYY-MM-DD HH24:MI:SS'));

INSERT INTO Attendance (EmployeeID, ClockIn, ClockOut)
VALUES (5, TO_TIMESTAMP('2025-01-05 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-05 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));


SELECT * FROM Attendance;
SELECT * FROM Employees;
CREATE TABLE Payroll (
    PayrollID INT PRIMARY KEY,
    EmployeeID INT,
    TotalHours DECIMAL(10, 2),
    OvertimeHours DECIMAL(10, 2),
    GrossPay DECIMAL(10, 2),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Insert records into Payroll table
BEGIN
    INSERT INTO Payroll (PayrollID, EmployeeID, TotalHours, OvertimeHours, GrossPay)
    VALUES (1, 1, 9, 1, 250.00);  -- John Doe worked 9 hours, 1 hour overtime
    
    INSERT INTO Payroll (PayrollID, EmployeeID, TotalHours, OvertimeHours, GrossPay)
    VALUES (2, 2, 9, 0, 180.00);  -- Jane Smith worked 9 hours, no overtime
    
    INSERT INTO Payroll (PayrollID, EmployeeID, TotalHours, OvertimeHours, GrossPay)
    VALUES (3, 3, 9, 1, 315.00);  -- Michael Brown worked 9 hours, 1 hour overtime
    
    INSERT INTO Payroll (PayrollID, EmployeeID, TotalHours, OvertimeHours, GrossPay)
    VALUES (4, 4, 9, 0, 202.50);  -- Emily Davis worked 9 hours, no overtime
    
    INSERT INTO Payroll (PayrollID, EmployeeID, TotalHours, OvertimeHours, GrossPay)
    VALUES (5, 5, 9, 1, 315.00);  -- Robert Wilson worked 9 hours, 1 hour overtime
END;
/
---Calculate Total Working Hours and Overtime
SELECT 
    A.EmployeeID,
    SUM(EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn))) AS TotalHours,
    SUM(
        CASE 
            WHEN EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn)) > 8 THEN 
                EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn)) - 8
            ELSE 0
        END
    ) AS OvertimeHours
FROM Attendance A
GROUP BY A.EmployeeID;
CREATE OR REPLACE PROCEDURE GenerateAttendanceReport IS
BEGIN
    FOR rec IN (
        SELECT 
            E.EmployeeID, 
            E.Name, 
            SUM(EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn)) + 
                (EXTRACT(MINUTE FROM (A.ClockOut - A.ClockIn)) / 60)) AS TotalHours,
            SUM(
                CASE 
                    WHEN (EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn)) + 
                          (EXTRACT(MINUTE FROM (A.ClockOut - A.ClockIn)) / 60)) > 8 THEN 
                        (EXTRACT(HOUR FROM (A.ClockOut - A.ClockIn)) + 
                         (EXTRACT(MINUTE FROM (A.ClockOut - A.ClockIn)) / 60)) - 8
                    ELSE 0
                END
            ) AS OvertimeHours
        FROM Employees E
        JOIN Attendance A ON E.EmployeeID = A.EmployeeID
        GROUP BY E.EmployeeID, E.Name
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Employee: ' || rec.Name || 
            ', Total Hours: ' || rec.TotalHours || 
            ', Overtime: ' || rec.OvertimeHours
        );
    END LOOP;
END;
/
SET SERVEROUTPUT ON;
EXEC GenerateAttendanceReport;


---Function: Calculate Payroll
CREATE OR REPLACE FUNCTION CalculatePayroll(emp_id INT) RETURN NUMBER IS
    total_hours DECIMAL(10, 2);
    overtime_hours DECIMAL(10, 2);
    hourly_rate DECIMAL(10, 2);
    gross_pay DECIMAL(10, 2);
BEGIN
    SELECT 
        SUM(EXTRACT(HOUR FROM (ClockOut - ClockIn))),
        SUM(
            CASE 
                WHEN EXTRACT(HOUR FROM (ClockOut - ClockIn)) > 8 THEN 
                    EXTRACT(HOUR FROM (ClockOut - ClockIn)) - 8
                ELSE 0
            END
        )
    INTO total_hours, overtime_hours
    FROM Attendance
    WHERE EmployeeID = emp_id;

    SELECT HourlyRate INTO hourly_rate FROM Employees WHERE EmployeeID = emp_id;

    gross_pay := (total_hours * hourly_rate) + (overtime_hours * hourly_rate * 1.5);

    RETURN gross_pay;
END;
/
SELECT CalculatePayroll(1) FROM dual;

--Trigger: Update Attendance Records on Clock-Out
CREATE OR REPLACE TRIGGER UpdateAttendance
AFTER INSERT OR UPDATE ON Attendance
FOR EACH ROW
BEGIN
    IF :NEW.ClockOut IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('Attendance record updated for Employee ID: ' || :NEW.EmployeeID);
    END IF;
END;
/
SET SERVEROUTPUT ON;

SELECT * FROM Attendance WHERE AttendanceID = 6;
INSERT INTO Attendance (AttendanceID, EmployeeID, ClockIn, ClockOut)
VALUES (7, 1, TO_TIMESTAMP('2025-01-06 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2025-01-06 18:00:00', 'YYYY-MM-DD HH24:MI:SS'));

SELECT constraint_name, constraint_type
FROM user_constraints
WHERE table_name = 'ATTENDANCE';

-- Insert an attendance record to test the trigger

SELECT AttendanceID FROM Attendance;
