# Dependencies
Conifer caches shadows and recomputes them in response to external changes. Conifer detects changes by tracking dependencies which components declare through **dynamic properties**. Conifer provides several built-in dynamic property types but libraries such as database and network frameworks can define their own for use in components.

An `@Observed` property observes changes in an observable object, i.e., an object that conforms to Combine's `ObservableObject` protocol.

	struct WelcomeBanner : UIElement {
		
		@Observed
		var sessionManager: SessionManager
		
		var body: some UIElement {
			if let user = sessionManager.loggedInUser {
				Text("Welcome back, \(user.name)!")
			} else {
				Text("Howdy, stranger!")
			}
		}
		
	}

A `@Contextual` property evaluates to a contextual value set on the shadow's closest ancestor. This a dependency injection mechanism for global or widespread properties for which argument passing results in cumbersome and cluttered code. The body is recomputed whenever the contextual value changes.

	struct AlertBanner : UIElement {
		
		@Contextual(\.colourScheme)
		var colourScheme
		
		var body: some UIElement {
			Text("Danger ahead! Pay attention!")
				.colour(colourScheme == .light ? .black : .white)
		}
		
	}
	
	struct DeletionForm : UIElement {
		var body: some UIElement {
			Form {
				AlertBanner()
				Button("Delete Account")
			}.context(\.colourScheme, .dark)
		}
	}

A `@Source` property observes changes in a shadow. `@Source` properties are used for deriving new representations of component trees, such as a HTML element tree from a UI element tree.

	struct AlertBannerElement : HTMLElement {
		
		@Source
		var alertBanner: Shadow<AlertBanner>
		
		var body: some HTMLElement {
			Element(tag: "div", attributes: ["class": "alert"]) {
				for child in alertBanner {
					htmlElements(for: child)
				}
			}
		}
		
	}
