plan(Plan) :-
    findall(Employee, employee(Employee), Employees),
    findall(workstation(ID, Min, Max), workstation(ID, Min, Max), Workstations),
    assign_employees_to_shifts(Employees, Workstations, Plan),
    valid_plan(Plan).


assign_employees_to_shifts(Employees, Workstations, [Morning, Evening, Night]) :-
    assign_to_shift(Morning, Employees, RemainingMorning, Workstations, morning),
    assign_to_shift(Evening, RemainingMorning, RemainingEvening, Workstations, evening),
    assign_to_shift(Night, RemainingEvening, _, Workstations, night).


assign_to_shift([], Employees, Employees, _, _).


assign_to_shift([workstation(ID, EmployeesAssigned)|Rest], EmployeesIn, EmployeesOut, Workstations, ShiftType) :-
    workstation(ID, Min, Max),
    findall(Employee, (member(Employee, EmployeesIn), possible_employee(Employee, ID, ShiftType)), PossibleEmployees),
    select_employees_for_workstation([], PossibleEmployees, 0, Min, Max, EmployeesAssigned),
    subtract(EmployeesIn, EmployeesAssigned, RemainingEmployees),
    assign_to_shift(Rest, RemainingEmployees, EmployeesOut, Workstations, ShiftType).


select_employees_for_workstation(CurrentList, _, Length, Min, Max, CurrentList) :-
    Length >= Min, Length =< Max, !.


select_employees_for_workstation(CurrentList, PossibleEmployees, Length, Min, Max, FinalList) :-
    member(Employee, PossibleEmployees),
    \+ member(Employee, CurrentList),
    append(CurrentList, [Employee], NewList),
    NewLength is Length + 1,
    select_employees_for_workstation(NewList, PossibleEmployees, NewLength, Min, Max, FinalList).


possible_employee(Employee, Workstation, Shift) :-
    \+ avoid_workstation(Employee, Workstation),
    \+ avoid_shift(Employee, Shift),
    \+ workstation_idle(Workstation, Shift).


valid_plan([Morning, Evening, Night]) :-
    valid_shift(Morning),
    valid_shift(Evening),
    valid_shift(Night).


valid_shift([]).
valid_shift([workstation(ID, Employees)|Rest]) :-
    workstation(ID, Min, Max),
    length(Employees, Count),
    Count >= Min, Count =< Max,
    valid_shift(Rest).
