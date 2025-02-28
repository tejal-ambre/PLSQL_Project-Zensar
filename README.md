# PLSQL_Project-Zensar
Description:The provided code establishes a database system for managing employee information, attendance records, and payroll calculations using SQL. It begins by creating the Employees table, which stores essential details like EmployeeID, Name, Department, and HourlyRate, followed by the insertion of five sample employee records. The Attendance table is then created to track clock-in and clock-out times for employees, with a foreign key linking it to the Employees table.<br>
Sample attendance data is added for demonstration purposes. To manage payroll, a Payroll table is defined to store details such as TotalHours, OvertimeHours, and GrossPay, and sample records are inserted to illustrate payroll calculations.<br>
The code includes a query to calculate total working hours and overtime hours for employees using aggregate functions and conditional logic.<br>
A stored procedure, GenerateAttendanceReport, is implemented to calculate and display total hours and overtime for each employee using cursors and output messages.<br>
A function, Calculate Payroll, is also defined to compute an employee's gross pay based on total hours, overtime, and their hourly rate, with overtime compensated at 1.5 times the regular rate. Additionally, a trigger named UpdateAttendance outputs a message whenever an attendance record is updated or a clock-out time is added, ensuring real-time feedback during updates.<br>
To validate the functionality, the code tests procedures, functions, and triggers by inserting and updating records, while queries retrieve and display data from the tables. Data integrity is maintained through primary and foreign key constraints, and server output is enabled to display execution messages.<br>
Overall, the code demonstrates the practical application of SQL in managing payroll and attendance systems, incorporating robust data handling, calculations, and automation to streamline operations.




