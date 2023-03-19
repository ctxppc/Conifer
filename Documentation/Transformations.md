# Transformations
A **transformation** maps a component tree to another component tree. For instance, a transformation can map a component such as

	let source = Department(name: "Sales") {
		Employee(name: "John")
		Section(name: "Procurement") {
			Employee(name: "Rach")
			Employee(name: "Tom")
		}
		Section(name: "Complaints") {
			Employee(name: "Lisa")
		}
	}

into a component such as

	let target = Payroll {
		Member(name: "John", department: "Sales", section: nil)
		Member(name: "Rach", department: "Sales", section: "Procurement")
		Member(name: "Tom", department: "Sales", section: "Procurement")
		Member(name: "Lisa", department: "Sales", section: "Complaints")
	}

Such a transformation could look like:

	struct PayrollList : PayrollItem {
		var body: some PayrollItem {
			Payroll {
				ForAll(.children[typed: Department.self]) { dept in
					ForAll(.children[typed: Section.self], in: dept) { sect in
						ForAll(.children[typed: Employee.self], in: sect) { emp in
							Employee(name: emp.name, department: dept.name, section: sect.name)
						}
					}
					ForAll(.children[typed: Employee.self], in: dept) { emp in
						Employee(name: emp.name, department: dept.name, section: nil)
					}
				}
			}
		}
	}

A transformation is expressed as any other component but with `ForAll` transformers. A `ForAll` transformer selects components using a given selector, provides these components to a closure, and evaluates to the component returned by the closure.

The transformation can be performed using `Shadow(of:transformingFrom:)`:

	let targetShadow: UntypedShadow = try await Shadow(of: PayrollList(), transformingFrom: source)	// shadow over Payroll

`Shadow(of:)` throws an error if the provided component contains transformers such as `ForAll`s.
